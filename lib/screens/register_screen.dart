import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'main_shell.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  File? _profileImage;
  String _selectedCountryCode = '+44';
  String _selectedFlag = '🇬🇧';

  final List<Map<String, String>> _countries = [
    {'flag': '🇬🇧', 'code': '+44', 'name': 'United Kingdom'},
    {'flag': '🇮🇳', 'code': '+91', 'name': 'India'},
    {'flag': '🇺🇸', 'code': '+1', 'name': 'United States'},
    {'flag': '🇨🇦', 'code': '+1', 'name': 'Canada'},
    {'flag': '🇦🇺', 'code': '+61', 'name': 'Australia'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final countryName = _countries.firstWhere(
      (element) => element['code'] == _selectedCountryCode && element['flag'] == _selectedFlag,
      orElse: () => _countries.first,
    )['name']!;

    final response = await AuthService.register(
      fullname: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      mobile: _mobileController.text.trim(),
      country: countryName,
      photo: _profileImage,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (response.isSuccess && response.data != null) {
      await SessionService.saveUser(response.data!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(response.message)),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainShell(user: response.data!),
        ),
        (route) => false,
      );
    } else {
      _showErrorDialog(response.message);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 28),
            SizedBox(width: 10),
            Text('Registration Error', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Figma Pixel-Perfect Background Layer
          Positioned.fill(
            child: CustomPaint(
              painter: _RegisterBgPainter(),
              child: Image.asset(
                'assets/screens_bg/02 Create Account.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

          // Main Screen Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.12),

                    // Heading Title: "Create Account"
                    const Text(
                      'Create\nAccount',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Photo Picker Placeholder matching Figma (Left aligned, blue dashed camera icon from asset)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: _profileImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _profileImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.asset(
                                  'assets/images/Upload Photo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.primaryLight,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 36,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name Input
                    CustomTextField(
                      controller: _nameController,
                      hintText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.textHint, size: 20),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Input
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textHint, size: 20),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Input
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textHint, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Input with Country Code Selector matching Figma
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<Map<String, String>>(
                              value: _countries.firstWhere(
                                (element) => element['code'] == _selectedCountryCode && element['flag'] == _selectedFlag,
                                orElse: () => _countries.first,
                              ),
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary, size: 20),
                              items: _countries.map((country) {
                                return DropdownMenuItem<Map<String, String>>(
                                  value: country,
                                  child: Row(
                                    children: [
                                      Text(country['flag']!, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 6),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFlag = value['flag']!;
                                    _selectedCountryCode = value['code']!;
                                  });
                                }
                              },
                            ),
                          ),
                          Container(
                            height: 24,
                            width: 1,
                            color: AppColors.inputBorder,
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _mobileController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Your number',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                fillColor: Colors.transparent,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter mobile number';
                                }
                                if (value.trim().length < 8) {
                                  return 'Enter a valid mobile number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),



                    const SizedBox(height: 32),

                    // Primary Button: "Done"
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Done'),
                    ),
                    const SizedBox(height: 16),

                    // Secondary Cancel Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Link to Login Screen
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top-left soft pastel light blue shape
    final lightPaint = Paint()
      ..color = const Color(0xFFDCE8FE)
      ..style = PaintingStyle.fill;
    final pathLight = Path();
    pathLight.moveTo(0, 0);
    pathLight.lineTo(size.width * 0.65, 0);
    pathLight.cubicTo(
      size.width * 0.55,
      size.height * 0.15,
      0,
      size.height * 0.28,
      0,
      size.height * 0.28,
    );
    pathLight.close();
    canvas.drawPath(pathLight, lightPaint);

    // 2. Right side main vibrant blue shape
    final bluePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final pathRight = Path();
    pathRight.moveTo(size.width * 0.68, 0);
    pathRight.cubicTo(
      size.width * 0.50,
      size.height * 0.18,
      size.width * 0.65,
      size.height * 0.42,
      size.width,
      size.height * 0.38,
    );
    pathRight.lineTo(size.width, 0);
    pathRight.close();
    canvas.drawPath(pathRight, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
