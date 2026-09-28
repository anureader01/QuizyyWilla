import 'package:quizbit_2/models/profileModel.dart';

class ProfileSession {

  static ProfileModel? _profile;


  static void setProfile(ProfileModel profile){
    _profile = profile;
  }


static ProfileModel? get profile => _profile;

static bool get isLoggedIn => _profile !=null;

static void clear(){
  _profile = null;
}

}
