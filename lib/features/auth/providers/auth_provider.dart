import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<UserModel?> {
  late AuthService _service;

  @override
  Future<UserModel?> build() async {
    _service = ref.read(authServiceProvider);
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
}
