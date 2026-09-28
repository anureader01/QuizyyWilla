import 'package:quizbit_2/models/profileModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  Future<void> createProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    await _client.from('profile').insert({
      'user_id': userId,
      'name': name,
      'email': email,
      'money': 12000,
      'game_title': 'Newbie',
      'profile_pic_url':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR4g_2Qj3LsNR-iqUAFm6ut2EQVcaou4u2YXw&s',
      'quiz_attempts': 0,
      'quiz_owned': [],
      'topic_asked': [],
      'last_login_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<ProfileModel?> getProfile(String profile_id) async {
    final data = await _client
        .from('profile')
        .select()
        .eq('user_id', profile_id)
        .maybeSingle();
    print("data data data data");
    print(data);
    if (data == null) return null;
    return ProfileModel.fromJon(data);
  }

  Future<ProfileModel?> getProfileByEmail(String email) async {
    final data = await _client
        .from('profile')
        .select()
        .eq('email', email)
        .maybeSingle();
    print("data data data data");
    print(data);
    if (data == null) return null;
    return ProfileModel.fromJon(data);
  }

  Future<void> updateLastLogin(String userId) async {
    await _client
        .from('profile')
        .update({'last_login_at': DateTime.now().toIso8601String()})
        .eq('user_id', userId);
  }

  Future<void> sendResetCode(String email) async {

      await _client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    await _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email.trim(),
      token: code.trim(),
    );
  }



  Future<void> updatePassword(String newPassword) async{
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }
}

