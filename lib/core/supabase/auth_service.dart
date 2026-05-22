import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AuthService {
  Future<void> signInWithGoogleTokens({
    required String idToken,
    required String accessToken,
  }) async {
    await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    // Upsert profile immediately after login
    final user = supabase.auth.currentUser;
    if (user != null) {
      await supabase.from('profiles').upsert(
        {
          'id': user.id,
          'username': user.userMetadata?['full_name'] as String? ?? '',
          'avatar_url': user.userMetadata?['avatar_url'] as String? ?? '',
        },
        onConflict: 'id',
      );
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
}
