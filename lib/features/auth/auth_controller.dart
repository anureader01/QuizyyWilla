import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/features/auth/auth_repository.dart';
import 'package:quizbit_2/models/profileModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final AuthRepository _authRepository;
  AuthController() : _authRepository = AuthRepository(SupabaseService().client);
  bool isLoading = false;
  String? errorMessage;

  Future<bool> signUp(String email, String password) async {
    isLoading = true;
    try {
      await _authRepository.signUp(email, password);
      isLoading = false;
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    try {
      await _authRepository.login(email, password);
      print("HIIIIIIIIIIIII");
      isLoading = false;
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      return false;
    }
  }

  Future<bool> logout() async {
    isLoading = true;
    try {
      await _authRepository.logout();
      isLoading = false;
      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      return false;
    }
  }

  Future<ProfileModel> getProfile(String profile_id) async {
    final profile = await _authRepository.getProfile(profile_id);
    return profile!;
  }

  Future<void> handleUserProfile() async {
    print("HANDLING USER PROFILE NOW 1122");
    final user = _authRepository.getCurrentUser();
    print("CURRENT USER");
    print(user);

    if (user == null) return;
    print("USER NOT NULL");

    final profile = await _authRepository.getProfileByEmail(user.email!);
    print("PROFILE FETCHED");
    print(profile);

    if (profile == null) {
      print("NULL PROFILE FOUDN");
      await _authRepository.createProfile(
        userId: user.id,
        name: "User1234",
        email: user.email!,
      );
    } else {
      //STORE IT IN GLOBAL

      await _authRepository.updateLastLogin(user.id);

      ProfileSession.setProfile(profile);
    }
  }

  Future<void> refereshProfileSession() async {
    print("HANDLING USER PROFILE NOW 1122");
    final user = _authRepository.getCurrentUser();
    print("CURRENT USER");
    print(user);

    if (user == null) return;
    print("USER NOT NULL");

    final profile = await _authRepository.getProfileByEmail(user.email!);
    print("PROFILE FETCHED");
    print(profile);

    ProfileSession.setProfile(profile!);
  }


  Future<({bool sucess, String? error})> sendResetOTP(String email ) async{
    try {

          final profileModel = await _authRepository.getProfileByEmail(email);
    if(profileModel == null){
return (sucess: false , error: "User is not registered yet. Please sign up first.");
  
    }
      await _authRepository.sendResetCode(email);
      return (sucess: true, error: null);
    } on AuthException catch (e) {
      return (sucess: false, error: e.toString());
    }
  }


  
  Future<({bool sucess, String? error})> verifyOTP({required String email, required String otp }) async{
    try {
      await _authRepository.verifyResetCode(email: email, code: otp);
      return (sucess: true, error: null);
    } on AuthException catch (e) {
      return (sucess: false, error: e.toString());
    }
  }



  
  
  Future<({bool sucess, String? error})> updateNewPassword(String newPassword) async{
    try {
      await _authRepository.updatePassword(newPassword);
      return (sucess: true, error: null);
    } on AuthException catch (e) {
      return (sucess: false, error: e.toString());
    }
  }



}

