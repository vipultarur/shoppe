import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiResponse<T> {
  final bool isSuccess;
  final String message;
  final T? data;

  ApiResponse({
    required this.isSuccess,
    required this.message,
    this.data,
  });
}

class AuthService {
  static const String baseUrl = 'https://shoply-kj50.onrender.com/api/auth';

  /// Login method using identifier (email/username) and password
  static Future<ApiResponse<UserModel>> login({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final payload = {
      'identifier': identifier.trim(),
      'password': password,
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = body['token'] as String?;
        final userMap = body['user'] ?? body['data'] ?? body;
        final user = UserModel.fromJson(userMap as Map<String, dynamic>, token: token);
        return ApiResponse(
          isSuccess: true,
          message: body['message'] ?? 'Login successful!',
          data: user,
        );
      } else {
        final errorMsg = body['message'] ?? body['error'] ?? 'Login failed. Please check credentials.';
        return ApiResponse(
          isSuccess: false,
          message: errorMsg,
        );
      }
    } on SocketException {
      return ApiResponse(
        isSuccess: false,
        message: 'Network error. Please check your internet connection.',
      );
    } on FormatException {
      return ApiResponse(
        isSuccess: false,
        message: 'Invalid response format from server.',
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Registration method
  static Future<ApiResponse<UserModel>> register({
    required String fullname,
    required String email,
    required String password,
    required String mobile,
    required String country,
    File? photo,
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final request = http.MultipartRequest('POST', url);
      request.fields['fullname'] = fullname.trim();
      request.fields['email'] = email.trim();
      request.fields['password'] = password;
      request.fields['mobile'] = mobile.trim();
      request.fields['country'] = country.trim();

      if (photo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo.path),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final token = body['token'] as String?;
        final userMap = body['user'] ?? body['data'] ?? body;
        final user = UserModel.fromJson(userMap as Map<String, dynamic>, token: token);
        return ApiResponse(
          isSuccess: true,
          message: body['message'] ?? 'Account created successfully!',
          data: user,
        );
      } else {
        final errorMsg = body['message'] ?? body['error'] ?? 'Registration failed. Please try again.';
        return ApiResponse(
          isSuccess: false,
          message: errorMsg,
        );
      }
    } on SocketException {
      return ApiResponse(
        isSuccess: false,
        message: 'Network error. Please check your internet connection.',
      );
    } on FormatException {
      return ApiResponse(
        isSuccess: false,
        message: 'Invalid response format from server.',
      );
    } catch (e) {
      return ApiResponse(
        isSuccess: false,
        message: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
