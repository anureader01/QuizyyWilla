 import 'package:quizbit_2/core/utils/datetimeparser.dart';

class ProfileModel {

  final int id;
  String name;
  final String email;
  int money;
  String game_title;
  String profile_pic_url;
  int quiz_attempts;
  List<dynamic> quiz_owned;
  List<dynamic> topic_asked;
  DateTime last_login_at;
  DateTime created_at;
  String user_id;




ProfileModel({
required this.id,
required this.name,
required this.email,
required this.money,
required this.game_title,
required this.profile_pic_url,
required this.quiz_attempts,
required this.quiz_owned,
required this.topic_asked,
required this.last_login_at,
required this.created_at,
required this.user_id,
});


factory ProfileModel.fromJon(Map<String, dynamic> json){
return ProfileModel(
  id: json['id'],
  name: json['name'], 
  email: json['email'], 
  money:  (json['money'] as num).toInt() , 
  game_title: json['game_title'], 
  profile_pic_url: json['profile_pic_url'], 
  quiz_attempts: json['quiz_attempts'], 
  quiz_owned: json['quiz_owned'], 
  topic_asked: json['topic_asked'], 
  last_login_at: parseDate(json['last_login_at']) , 
  created_at: parseDate(json['created_at'],), 
  user_id: json['user_id']
  );

}


Map<String, dynamic> toJson(ProfileModel profile){
  return {


'id': profile.id,
'name': profile.name,
'email': profile.email,
'money': profile.money,
'game_title': profile.game_title,
'profile_pic_url': profile.profile_pic_url,
'quiz_attempts': profile.quiz_attempts,
'quiz_owned': profile.quiz_owned,
'topic_asked': profile.topic_asked,
'last_login_at': profile.last_login_at.toIso8601String(),
'created_at': profile.created_at.toIso8601String(),
'user_id': profile.user_id,

  };
}

}
