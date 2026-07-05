import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioClientProvider));
});

class AuthService {
  final DioClient _client;
  final _storage = const FlutterSecureStorage();
  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  AuthService(this._client);

  Future<UserModel> login(String email, String password) async {
    try {
      final res = await _client.dio.post('/mobile/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _saveSession(res.data);
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_messageFrom(e, {
        401: 'Incorrect email or password.',
        404: 'No account found with that email.',
      }));
    }
  }

  Future<UserModel> register(String name, String email, String password) async {
    try {
      final res = await _client.dio.post('/mobile/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      await _saveSession(res.data);
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_messageFrom(e, {
        409: 'An account with this email already exists.',
      }));
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Failed to get Google ID token');

      final res = await _client.dio.post('/mobile/auth/google', data: {'idToken': idToken});
      await _saveSession(res.data);
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_messageFrom(e, {}));
    }
  }

  String _messageFrom(DioException e, Map<int, String> overrides) {
    final code = e.response?.statusCode;
    if (code != null && overrides.containsKey(code)) return overrides[code]!;
    final serverMsg = e.response?.data is Map ? e.response!.data['error'] as String? : null;
    return serverMsg ?? 'Something went wrong. Please try again.';
  }

  Future<void> logout() async {
    await _googleSignIn.signOut().catchError((_) {});
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.userKey);
  }

  Future<UserModel?> getStoredUser() async {
    final json = await _storage.read(key: AppConstants.userKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    await _storage.write(key: AppConstants.tokenKey, value: data['token'] as String);
    await _storage.write(
      key: AppConstants.userKey,
      value: jsonEncode(data['user']),
    );
  }
}
