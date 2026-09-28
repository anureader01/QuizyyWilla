import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/features/home/home_repository.dart';
import 'package:quizbit_2/models/quizModel.dart';

class HomeController {
    final HomeRepository _homeRepository;
  HomeController()
    : _homeRepository = HomeRepository(SupabaseService().client);

List<QuizModel> weekelyDhamaka = [];
List<QuizModel> mostPlayed = [];
List<QuizModel> quickPlay = [];
List<QuizModel> highStakes = [];
List<QuizModel> youMayLike = [];
List<QuizModel> random3Quiz = [];

QuizModel? newlyAdded;

bool isLoading = false;


loadHome() async{

  // try {
    isLoading = true;
    final results = await Future.wait([
      _homeRepository.getWeeklyDhamaka(),
      _homeRepository.getMostPlayed(),
      _homeRepository.getQuickPlay(),
      _homeRepository.getHighStakes(),
      _homeRepository.getNewlyAdded(),
      _homeRepository.fetch3Random()
    ]);

    weekelyDhamaka = results[0] as List<QuizModel>;
    mostPlayed = results[1] as List<QuizModel>;
    quickPlay = results[2] as List<QuizModel>;
    highStakes = results[3] as List<QuizModel>;
    newlyAdded = results[4] as QuizModel;
    random3Quiz = results[5] as List<QuizModel>;
    print("CONTROLLER newlyAdded");
    print(newlyAdded);
  // } catch (e) {
  //   print("HOME LOAD ERROR $e");
  // } finally {
  //   isLoading = false;
  // }
    isLoading = false;
}


loadYouMayLike() async{
final yML =   await _homeRepository.getYouMayLike();
youMayLike.addAll(yML);
}



}
