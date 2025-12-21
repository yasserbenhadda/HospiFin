import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        if (token != null) {
          await _storage.write(key: 'auth_token', value: token);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }
}
