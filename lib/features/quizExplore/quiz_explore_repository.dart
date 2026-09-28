import 'package:quizbit_2/features/quizExplore/quiz_explore_enum.dart';
import 'package:quizbit_2/models/quizModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizExploreRepository {
  final SupabaseClient _client;
  QuizExploreRepository(this._client);

  getQuizzes({
    required QuizCategory category,
    String? tag,

int from  = 0,
int to  = 10,   
  
  }) async{
    var query  =  _client.from('quiz').select();
String orderColumn;
bool ascending;

    switch(category){
      case QuizCategory.mostPlayed:
        orderColumn = 'views';
        ascending = false;
        break;

      case QuizCategory.newThisWeek:

        final weekAgo = DateTime.now().subtract(Duration(days: 7)).toIso8601String();
        query = query.gt('created_at', weekAgo);
        orderColumn = 'views';
        ascending = false;
        break;



        
      case QuizCategory.recentlyAdded:
        orderColumn = 'created_at';
        ascending = false;
        break;

      case QuizCategory.highestPrize:
        orderColumn = 'top_prize';
        ascending = false;
        break;
      case QuizCategory.lowestEntryFees:
        orderColumn = 'entry_fees';
        ascending = true;
        break;

      case QuizCategory.byTag:
      if(tag == null || tag.isEmpty){
        throw ArgumentError('tag is required');
      }
      print("GIVEN TAG IS");
      print(tag);
        query = query.contains('tags', [tag]);
        orderColumn = 'views';
        ascending = false;
        break;
    }

    final res = await query.order(orderColumn, ascending: ascending ).range(from, to);
print("TAG RESPONSE");
print(res);
    return (res as List).map((e)=> QuizModel.fromJon(e as Map<String, dynamic>)).toList();
  }

}
