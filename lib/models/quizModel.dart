import 'package:quizbit_2/core/utils/datetimeparser.dart';

class QuizModel{
  final String quiz_id;
  final String quiz_title;
  final String quiz_verti_img;
  final String quiz_cover_img;
  final double entry_fees;
  final int level;
  final double top_prize;
  final double greed_factor;
  final double base_prize;
  final String quiz_des;
  final List<String> tags;
  final int views;
  final DateTime created_at;
  final DateTime? updated_at;
  final List<String> comment_id;
  final double rating;

  QuizModel({





required this.quiz_id,
required this.quiz_title,
required this.quiz_verti_img,
required this.quiz_cover_img,
required this.entry_fees,
required this.level,
required this.top_prize,
required this.greed_factor,
required this.base_prize,
required this.quiz_des,
required this.tags,
required this.views,
required this.created_at,
required this.updated_at,
required this.comment_id,
required this.rating,





  });


  factory QuizModel.fromJon(Map<String, dynamic> json) {
  return QuizModel(
    quiz_id: json['quiz_id'],
    quiz_title: json['quiz_title'],
    quiz_verti_img: json['quiz_verti_img'],
    quiz_cover_img: json['quiz_cover_img'],

    entry_fees: (json['entry_fees'] as num).toDouble(),

    level: json['level'],

    top_prize: (json['top_prize'] as num).toDouble(),

    greed_factor: (json['greed_factor'] as num).toDouble(),

    base_prize: (json['base_prize'] as num).toDouble(),

    quiz_des: json['quiz_des'],

    tags: List<String>.from(json['tags'] ?? []),

    views: json['views'],

    created_at: parseDate(json['created_at']),

    updated_at: parseDate(
      json['updated_at'] ?? DateTime.now().toIso8601String(),
    ),

    comment_id: List<String>.from(json['comment_id'] ?? []),

    rating: (json['rating'] as num).toDouble(),
  );
}
}
