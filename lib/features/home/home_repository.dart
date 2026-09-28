import 'package:quizbit_2/models/quizModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepository {
  final SupabaseClient _client;
  HomeRepository(this._client);

  Future<List<QuizModel>> getWeeklyDhamaka() async {
    final data = await _client
        .from('quiz')
        .select()
        .order('views', ascending: false)
        .limit(10);

    return data.map<QuizModel>((e) => QuizModel.fromJon(e)).toList();
  }




  Future<List<QuizModel>> getMostPlayed() async {
    final data = await _client
        .from('quiz')
        .select()
        .order('views', ascending: false)
        .limit(10);

    return data.map<QuizModel>((e) => QuizModel.fromJon(e)).toList();
  }


  

  Future<QuizModel> getNewlyAdded() async {
    final data = await _client
        .from('quiz')
        .select()
        .order('created_at', ascending: false)
        .limit(1).maybeSingle();
        print("NEWLY ADDED data");
        print(data);

    return QuizModel.fromJon(data!);
  }



  
  Future<List<QuizModel>> getQuickPlay() async {
    final data = await _client
        .from('quiz')
        .select()
        .lte('entry_fees', 20)
        .limit(5);

    return data.map<QuizModel>((e) => QuizModel.fromJon(e)).toList();
  }




  Future<List<QuizModel>> getHighStakes() async {
    final data = await _client
        .from('quiz')
        .select()
        .order('top_prize',  ascending: false)
        .limit(5);

    return data.map<QuizModel>((e) => QuizModel.fromJon(e)).toList();
  }



  
  Future<List<QuizModel>> getYouMayLike() async {
    final data = await _client
        .from('quiz')
        .select()
       
        .limit(20);

final list = data.map<QuizModel>((e) => QuizModel.fromJon(e)).toList();
list.shuffle();

    return list.take(5).toList();
  }



    
  Future<List<QuizModel>> fetch3Random() async {
    final data = await _client
        .from('quiz')
        .select()
       
        .limit(30);

final list = data.map<QuizModel>((e) => QuizModel.fromJon(e)).toList();
list.shuffle();

    return list.take(3).toList();
  }
}

