import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign Up dengan email dan password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (metadata != null) data.addAll(metadata);
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: data.isNotEmpty ? data : null,
      );
      
      return response;
    } on AuthException catch (e) {
      // Rethrow with more specific error message
      throw AuthException(e.message);
    } catch (e) {
      // Handle other exceptions
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Sign In dengan email dan password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get Current User
  User? get currentUser => _supabase.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _supabase.auth.currentUser != null;

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // Update User Profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? avatarUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (metadata != null) updates.addAll(metadata);

    return await _supabase.auth.updateUser(
      UserAttributes(data: updates),
    );
  }

  // Get user role from metadata
  String? get userRole {
    final user = currentUser;
    if (user == null) return null;
    return user.userMetadata?['role'] as String?;
  }

  // Check if user has specific role
  bool hasRole(String role) {
    final currentRole = userRole;
    return currentRole != null && currentRole == role;
  }

  // Check if user has any of the roles
  bool hasAnyRole(List<String> roles) {
    final currentRole = userRole;
    return currentRole != null && roles.contains(currentRole);
  }
}
