import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_enum.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_repository.dart';
import 'package:quizbit_2/models/quizModel.dart';

class QuizExploreController {
  final QuizExploreRepository _quizExploreRepository;
  QuizExploreController()
    : _quizExploreRepository = QuizExploreRepository(SupabaseService().client);

  static const int _pagesize = 10;

  final List<QuizModel> quizzes = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = false;

  String? error;

 Future<void> loadInitial({required QuizCategory category, String? tag}) async {
    quizzes.clear();

    hasMore = true;
    error = null;
    isLoading = true;

    try {
      final list = await _quizExploreRepository.getQuizzes(
        category: category,
        tag: tag,
        from: 0,
        to: _pagesize - 1,
      );

      quizzes.addAll(list);
      hasMore = list.length == _pagesize;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }


  loadMore(
    {
      required QuizCategory category,
      String? tag,
    }
  ) async{
    if(isLoadingMore || !hasMore) return;
    isLoadingMore = true;
    try {
      final from = quizzes.length;
      final to = from + _pagesize - 1;
      final list = await _quizExploreRepository.getQuizzes(category: category, tag: tag, from:  from, to: to);

      quizzes.addAll(list);
      hasMore = list.length == _pagesize;
    } catch (e) {
      error = e.toString();
    }finally{
      isLoadingMore = false;
    }
  }
}

