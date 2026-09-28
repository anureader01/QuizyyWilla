import 'package:quizbit_2/models/profileModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardRepository {
  final SupabaseClient _client;
  LeaderboardRepository(this._client);

  Future<List<ProfileModel>> fetchTop3() async {
    final data = await _client
        .from("profile")
        .select()
        .order('money', ascending: false)
        .limit(3);

    return data.map((e) => ProfileModel.fromJon(e)).toList();
  }


  Future<List<ProfileModel>> fetchTop4Home() async {
    final data = await _client
        .from("profile")
        .select()
        .order('quiz_attempts', ascending: false)
        .limit(4);

    return data.map((e) => ProfileModel.fromJon(e)).toList();
  }




  Future<List<ProfileModel>> fetchTop3Local({

        required double lat,
    required double lng,
  }) async {
    final response = await _client.rpc('get_local_leaderboard', params: {
      'user_lng' : lng,
      'user_lat' : lat,
      'limit_count' : 3,
      'offset_count' : 0
    });

 final data = response as List<dynamic>;

  return data
      .map<ProfileModel>((e) => ProfileModel.fromJon(e))
      .toList();
  }


  Future<List<ProfileModel>> fetchUsers({
    required int offset,
    int limit = 10,
  }) async {
    final data = await _client
        .from("profile")
        .select()
        .order("money", ascending: false)
        .range(offset, offset + limit - 1);

    return data.map((e) => ProfileModel.fromJon(e)).toList();
  }




  Future<List<ProfileModel>>  fetchLocalUsers({
    required double lat,
    required double lng,
    required int offset,
     int limit = 10
  }) async{
    final response = await _client.rpc('get_local_leaderboard', params: {
      'user_lng' : lng,
      'user_lat' : lat,
      'limit_count' : limit,
      'offset_count' : offset
    });

 final data = response as List<dynamic>;

  return data
      .map<ProfileModel>((e) => ProfileModel.fromJon(e))
      .toList();

  }
}

