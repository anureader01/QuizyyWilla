import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/features/leaderboard/leaderboard_repository.dart';
import 'package:quizbit_2/models/profileModel.dart';

class LeaderboardController {
  final LeaderboardRepository _leaderboardRepo;
  LeaderboardController()
    : _leaderboardRepo = LeaderboardRepository(SupabaseService().client);

  int offset = 5;
  int localOffset = 5;
  List<ProfileModel> top3 = [];
  List<ProfileModel> top3Local = [];

  List<ProfileModel> users = [];
  List<ProfileModel> localUsers = [];

  bool isLoading = false;
  bool isLocalLoading = false;
  bool hasMore = true;
  bool hasMoreLocal = true;

  Future<void> loadTop3() async {
    top3 = await _leaderboardRepo.fetchTop3();
  }


  
  Future<List<ProfileModel>> loadTop4Home() async {
   return await _leaderboardRepo.fetchTop4Home();
  }



  Future<void> loadTop3Local({
      required double lat,
  required double lng,
  }) async {
    top3Local = await _leaderboardRepo.fetchTop3Local(lat: lat, lng: lng);
  }


   Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    final newUsers = await _leaderboardRepo.fetchUsers(offset: offset);

    if (newUsers.isEmpty) {
      hasMore = false;
    } else {
      users.addAll(newUsers);
      offset += newUsers.length;
    }

    isLoading = false;
  }




 Future<void> loadLocal({
  required double lat,
  required double lng,

}) async {
  print("LOAD LOCAL FUNCTION CHCKING");
  print(isLocalLoading);
  print(hasMoreLocal);
  if(isLocalLoading || !hasMoreLocal) return;
  isLocalLoading = true;
  print("LAT LONG LAT LONG");
  print(lat);
  print(lng);
  final newUsers = await _leaderboardRepo.fetchLocalUsers(lat: lat, lng: lng, offset: localOffset);

  print("NEW USER LOCAL FETCHING");
  print(newUsers.length);
  if(newUsers.isEmpty) {
    hasMoreLocal = false;
  }else{
    localUsers.addAll(newUsers);
    localOffset += newUsers.length;
  }


  isLocalLoading = false;
  
}


  Future<void> init() async{
    await loadTop3();
    await loadMore();
    // await loadLocal(lat: lat, lng: lng);
    // await loadTop3Local(lat: lat, lng: lng);
  
  }





}

