import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/features/quizdetail/ratingRepository.dart';
import 'package:quizbit_2/models/ratingCommentModel.dart';

class RatingController {
  final Ratingrepository _ratingrepository;
  RatingController()
    : _ratingrepository = Ratingrepository(SupabaseService().client);


   Future<RatingCommentmodel?>  fetchMyRating(String quizId) async{
      if(!ProfileSession.isLoggedIn) return null;
      return _ratingrepository.getMyRating(quizId: quizId, profileId: ProfileSession.profile!.user_id);

    }
 Future<List<RatingCommentmodel>>  fetchAllRating(String quizId) async{
      return _ratingrepository.getRatingsForQuiz(quizId);
    }

   
   Future<RatingCommentmodel> submitRating({
      required String quizId,
      required double rating,
      String? comment,
      RatingCommentmodel? existing
    }) async {

      if(!ProfileSession.isLoggedIn) throw Exception("USER NOT LOGGED IN");
 print("COMMETN IN CONTROLLER IS $comment");
if(existing != null && existing.id != null){
  return _ratingrepository.updateRating(quizId: quizId, ratingId: existing.id!, rating: rating, comment: comment ?? "");
}

return _ratingrepository.createRating(quizId: quizId, profileId: ProfileSession.profile!.user_id, rating: rating, comment: comment ?? "");
    }
}
