class RatingCommentmodel {
  final String? id;
  final String? profileId;
  final String? userName;
  final String? user_profile_pic;
  final String? comment;
  final double rating;
  final DateTime? created_at;

  RatingCommentmodel({
    this.id,
    this.profileId,
    this.comment,
    this.userName,
    this.user_profile_pic,
    required this.rating,
    this.created_at

  });


  factory RatingCommentmodel.fromMap(Map<String, dynamic> data){
    return RatingCommentmodel(id: data['id']?.toString(),
    profileId: data['profile_id'],
    comment:  (data['comment'] ?? "") as String,
    userName:  (data['userName'] ?? "") as String,
    user_profile_pic:  (data['user_profile_pic'] ?? "") as String,
    rating: (data['rating'] as num).toDouble(),
    created_at : data['created_at'] != null ? DateTime.parse(data['created_at']) : null
    );
  }
}
