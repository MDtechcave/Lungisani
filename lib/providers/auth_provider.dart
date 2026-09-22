import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Current session stream
final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isLoggedIn;
});

// Current user ID
final currentUserIdProvider = Provider<String?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUserId;
});

// Current user profile
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentProfile();
});

// Auth notifier using Notifier (Riverpod 3.x)
class AuthNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String suburb,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authServiceProvider).register(
          email: email,
          password: password,
          fullName: fullName,
          suburb: suburb,
        ));
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authServiceProvider).login(
          email: email,
          password: password,
        ));
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        ref.read(authServiceProvider).logout());
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AsyncValue<void>>(AuthNotifier.new);
