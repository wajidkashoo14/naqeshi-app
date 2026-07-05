import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

// Callback set by AuthNotifier so DioClient can trigger logout without circular dependency
typedef LogoutCallback = Future<void> Function();
LogoutCallback? _onUnauthorized;

void registerUnauthorizedCallback(LogoutCallback cb) => _onUnauthorized = cb;

class DioClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid — clear session and trigger logout
          await _storage.delete(key: AppConstants.tokenKey);
          await _storage.delete(key: AppConstants.userKey);
          await _onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}
