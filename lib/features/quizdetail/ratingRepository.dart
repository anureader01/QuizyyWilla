import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/models/ratingCommentModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Ratingrepository {
  final SupabaseClient _client;
  Ratingrepository(this._client);


  Future<List<String>> _fetchCommentIds(String quizId) async{
final res = await _client.from('quiz').select('comment_id').eq('quiz_id', quizId).single();

final raw = res['comment_id'];
if(raw == null) return [];
return (raw as List).map((e)=> e.toString()).toList();
  }



   Future<RatingCommentmodel?> getMyRating({
    required String quizId,
    required String profileId,
  }) async {
    final ids  = await _fetchCommentIds(quizId);
    if(ids.isEmpty) return null;

    final res = await _client.from('rating_comment').select().inFilter('id', ids).eq('profile_id', profileId).maybeSingle();


    if(res == null) return null;
    return RatingCommentmodel.fromMap(res);
  }



   Future<List<RatingCommentmodel>> getRatingsForQuiz(String quizId) async{
    final ids = await _fetchCommentIds(quizId);
    if(ids.isEmpty) return [];

    final res = await _client.from('rating_comment').select().inFilter('id', ids).order('created_at', ascending: false);

return (res as List).map((e)=> RatingCommentmodel.fromMap(e as Map<String, dynamic>)).toList();
  }




   Future<RatingCommentmodel> createRating({
    required String quizId,
    required String profileId,
    required double rating,
    String? comment,
  }) async{

    print("COMMETN IN REPOSTIORY IS $comment");
    final inserted = await _client.from('rating_comment').insert({

      'profile_id' : profileId,
      'rating' : rating,
      'comment' : comment,
      'userName' : ProfileSession.profile!.name,
      'user_profile_pic' : ProfileSession.profile!.profile_pic_url,
    }).select().single();

    final newId = inserted['id'] as String;

    final ids = await _fetchCommentIds(quizId);

    ids.add(newId);


    await _client.from('quiz').update({
      'comment_id' : ids,
      'rating' : await _computeAverage(ids),
      'updated_at': DateTime.now().toIso8601String(),
      'userName' : ProfileSession.profile!.name,
      'user_profile_pic' : ProfileSession.profile!.profile_pic_url,
    }).eq('quiz_id', quizId);

    return RatingCommentmodel.fromMap(inserted);
  }



  Future<RatingCommentmodel> updateRating({
    required String quizId,
    required String ratingId,
    required double rating,
    String? comment
  }) async {

    final updated = await _client.from('rating_comment').update({
      'rating' : rating,
      'comment' : comment
    }).eq('id', ratingId).select().single();
 final newId = updated['id'] as String;

    final ids = await _fetchCommentIds(quizId);

    ids.add(newId);


    await _client.from('quiz').update({
      'comment_id' : ids,
      'rating' : await _computeAverage(ids),
      'updated_at': DateTime.now().toIso8601String()
    }).eq('quiz_id', quizId);

return RatingCommentmodel.fromMap(updated);
  }


  Future<double> _computeAverage(List<String> ids) async{
    if(ids.isEmpty) return 0;
    final rows = await _client.from('rating_comment').select('rating').inFilter('id',ids);

    final list = rows as List;
    if(list.isEmpty) return 0;

    final total = list.fold<double>(0, (sum, r) => sum + (r['rating'] as num).toDouble());

return double.parse((total/list.length).toStringAsFixed(2));
  }
}
