import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../supabase_config.dart';

class AuthService {
  final _auth = supabase.auth;

  // Current user
  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String? get currentUserId => currentUser?.id;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  // Register
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required String suburb,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await supabase.from('profiles').upsert({
        'id': response.user!.id,
        'full_name': fullName,
        'suburb': suburb,
      });
    }

    return response;
  }

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user profile
  Future<Profile?> getCurrentProfile() async {
    if (currentUserId == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', currentUserId!)
        .single();

    return Profile.fromJson(data);
  }

  // Update profile
  Future<void> updateProfile({
    String? fullName,
    String? suburb,
    String? ward,
  }) async {
    if (currentUserId == null) return;

    await supabase.from('profiles').update({
      if (fullName != null) 'full_name': fullName,
      if (suburb != null) 'suburb': suburb,
      if (ward != null) 'ward': ward,
    }).eq('id', currentUserId!);
  }
}
