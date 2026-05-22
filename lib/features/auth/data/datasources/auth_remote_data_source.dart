import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../../../../core/supabase/auth_service.dart';

/// Auth remote data source.
///
/// Google Sign-In and Email/Password via Supabase are ACTIVE.
class AuthRemoteDataSource {
  // dio field kept for DI compatibility; not used during migration
  AuthRemoteDataSource({dynamic dio});

  static const String _tag = '[AuthRemoteDataSource]';

  // ── ACTIVE: Supabase Google Sign-In ──────────────────────────────────────

  Future<Map<String, dynamic>> googleSignIn({
    required String idToken,
    required String accessToken,
  }) async {
    await AuthService().signInWithGoogleTokens(
      idToken: idToken,
      accessToken: accessToken,
    );
    // Return dummy tokens — real session is managed by Supabase SDK
    return {
      'access': 'supabase_managed',
      'refresh': 'supabase_managed',
      'user': {'id': 'supabase_managed', 'username': 'google_user'},
    };
  }

  Future<void> logout({required String refreshToken}) async {
    await AuthService().signOut();
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': '$firstName $lastName'.trim(),
        'username': username,
      },
    );

    if (response.user == null) {
      throw Exception('Registration failed');
    }

    // Upsert profile
    await Supabase.instance.client.from('profiles').upsert(
      {
        'id': response.user!.id,
        'username': username,
      },
      onConflict: 'id',
    );

    return {
      'access': 'supabase_managed',
      'refresh': 'supabase_managed',
      'user': {
        'id': response.user!.id,
        'username': username,
      },
    };
  }

  Future<Map<String, dynamic>> login({
    required String username, // Note: The UI passes email in the 'email' parameter to AuthRepository, but AuthRepository calls this as username
    required String password,
  }) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: username, // Actually an email
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    return {
      'access': 'supabase_managed',
      'refresh': 'supabase_managed',
      'user': {
        'id': response.user!.id,
        'username': response.user!.userMetadata?['full_name'] ?? 'User',
      },
    };
  }

  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user found');
    }

    final fullName = '$firstName $lastName'.trim();

    // 1. Update Auth metadata
    await client.auth.updateUser(
      UserAttributes(
        data: {'full_name': fullName},
      ),
    );

    // 2. Update profiles table
    await client.from('profiles').upsert(
      {
        'id': user.id,
        'username': fullName,
      },
      onConflict: 'id',
    );

    return UserModel(
      id: user.id,
      username: fullName,
      email: user.email ?? '',
      firstName: firstName,
      lastName: lastName,
    );
  }

  Future<String> refreshToken({required String refreshToken}) async {
    debugPrint('$_tag refreshToken() — stubbed (Supabase manages session)');
    return 'supabase_managed';
  }

  Future<void> deleteAccount() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user != null) {
      try {
        await client.rpc('delete_own_user_account');
      } catch (e) {
        debugPrint('$_tag deleteAccount RPC error: $e');
        // Fallback to basic profiles delete if the RPC function isn't found/configured
        try {
          await client.from('profiles').delete().eq('id', user.id);
        } catch (pe) {
          debugPrint('$_tag deleteAccount profiles fallback delete error (non-fatal): $pe');
        }
      }
      await client.auth.signOut();
    }
  }

  Future<void> patchProfileOffsets(Map<String, dynamic> data) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      debugPrint('$_tag patchProfileOffsets ignored: no authenticated user');
      return;
    }

    final Map<String, dynamic> updateData = {
      'id': user.id,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (data.containsKey('manual_offsets')) {
      updateData['manual_offsets'] = data['manual_offsets'];
    }
    if (data.containsKey('calculation_method') && data['calculation_method'] != null) {
      updateData['calculation_method'] = data['calculation_method'];
    }
    if (data.containsKey('use_hanafi') && data['use_hanafi'] != null) {
      updateData['use_hanafi'] = data['use_hanafi'];
    }
    if (data.containsKey('intent_level') && data['intent_level'] != null) {
      updateData['intent_level'] = data['intent_level'];
      updateData['intent_explicitly_set'] = true;
    }
    if (data.containsKey('sunnah_enabled') && data['sunnah_enabled'] != null) {
      updateData['sunnah_enabled'] = data['sunnah_enabled'];
    }
    if (data.containsKey('pause_notifications_until')) {
      updateData['pause_notifications_until'] = data['pause_notifications_until'];
    }

    await client.from('user_settings').upsert(
      updateData,
      onConflict: 'id',
    );
  }

  Future<Map<String, dynamic>> getUserConfig() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return {};

    final response = await client
        .from('user_settings')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response ?? {};
  }

  Future<void> requestPasswordReset({required String email}) async {
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    // In Supabase, the user arrives via a magic link that establishes a session,
    // and then they call updateUser to set the new password.
    // If we're using a token manually (e.g., OTP), we would call verifyOTP.
    // Assuming the user is already logged in via the recovery link:
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<bool> verifyEmail({String? token}) async {
    // Supabase handles this automatically via magic links
    return true;
  }
}
