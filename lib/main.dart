import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/session_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialUser = await SessionService.getUser();
  runApp(GroceryApp(initialUser: initialUser));
}

class GroceryApp extends StatelessWidget {
  final UserModel? initialUser;

  const GroceryApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoppe - Online Grocery App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: initialUser != null ? MainShell(user: initialUser!) : const WelcomeScreen(),
    );
  }
}

