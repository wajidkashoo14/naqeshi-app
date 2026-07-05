import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/network/dio_client.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late AuthService _service;

  @override
  Future<UserModel?> build() async {
    _service = ref.read(authServiceProvider);
    // Register callback so DioClient can trigger logout on 401
    registerUnauthorizedCallback(() async {
      state = const AsyncData(null);
    });
    return _service.getStoredUser();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.login(email, password));
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.register(name, email, password));
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.signInWithGoogle());
  }

  Future<void> logout() async {
    await _service.logout();
    state = const AsyncData(null);
  }

  void updateUser(UserModel user) {
    state = AsyncData(user);
  }

  void clearError() {
    state = const AsyncData(null);
  }
}
