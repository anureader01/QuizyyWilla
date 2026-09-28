import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/features/quiz/questionModel.dart';
import 'package:quizbit_2/models/quizModel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizRepository {
  final SupabaseClient _client;
  QuizRepository(this._client);
  final String apiKey = dotenv.env["GEMINI_API_KEY"]!;

 Future<String?> generateQuestion(String prompt) async {
  try {
    final model = "gemini-3.1-flash-lite";

    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": prompt,
              },
            ],
          },
        ],
      }),
    );

    print("=================================");
    print("GEMINI STATUS CODE: ${response.statusCode}");
    print("GEMINI RESPONSE: ${response.body}");
    print("=================================");

    if (response.statusCode != 200) {
      return null;
    }

    return response.body;
  } catch (e) {
    print("GEMINI EXCEPTION: $e");
    return null;
  }
}








  Future<String?> geminiAPIaCall(String prompt) async {
    try {
      final model = "gemini-3.1-flash-lite";
      // final model = "gemini-2.5-flash";

      final url =
          "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey";

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},

        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
              ],
            },
          ],
        }),
      );

    if (response.statusCode != 200) {
  print("GEMINI STATUS CODE: ${response.statusCode}");
  print("GEMINI ERROR BODY: ${response.body}");
  return null;
}

      return response.body;
    } catch (e) {
      print("Exception $e");
      return null;
    }
  }



  Questionmodel getFallbackQuestion() {
    return Questionmodel(
      question: "Which planes is knows as Red Planet?",
      option1: "Jupiter",
      option2: "Mars",
      option3: "Venus",
      option4: "Saturn",
      correctOpt: "Mars",
      queMoney: 0,
      explanation: "Mars is closest.",
    );
  }

  Future<bool> deduct_money(String userId, double money) async {
    final response = await _client.rpc(
      'deduct_money',
      params: {'p_user_id': userId, 'p_amount': money},
    );

    return response as bool;
  }

  Future<void> addMoney(String userId, double amount) async {
    print("AMOUNT TO BE ADDED : $amount to $userId");
    await _client.rpc(
      "add_money",
      params: {'p_user_id': userId, 'p_amount': amount},
    );
  }

  Future<void> addQuizHistory(
    QuizModel quizModel,
    double winnings,
    List<String> lifeline_used,
    DateTime started_at,
  ) async {
    await _client.from("quiz_history").insert({
      "quiz_id": quizModel.quiz_id,
      "user_id": ProfileSession.profile!.id,
      "money_won": winnings,
      "lifeline_used": lifeline_used,
      "started_at": started_at.toIso8601String(),
      "finished_at": DateTime.now().toIso8601String(),
    });
  }

  increaseViews(String quizId, String quizTitle) async {
    //CHALLENGE - CREATE RPC AND CALL IT FROM HERE FOR INCREMENTING VIEWS
    //FETCH VIWES
    final response = await _client
        .from('quiz')
        .select('views')
        .eq('quiz_id', quizId)
        .single();
    int currentViews = (response['views'] ?? 0) as int;
    //UPDATE QUIZ BY VIEWS + 1
    await _client
        .from('quiz')
        .update({'views': currentViews + 1})
        .eq('quiz_id', quizId);




        
  
  final profileRes = await _client.from('profile').select().eq('user_id', ProfileSession.profile!.user_id).single();

  final currentQuizOwned = (profileRes['quiz_owned'] as List).map((e)=>e.toString()).toList();
  final currentQuizAttempts = (profileRes['quiz_attempts'] as int);


currentQuizOwned.add(quizTitle);
  await _client.from('profile').update({'quiz_owned' : currentQuizOwned, 'quiz_attempts' : currentQuizAttempts + 1}).eq('user_id', ProfileSession.profile!.user_id);
  }

  Future<void> addQueHistory({
    required QuizModel quizModel,
    required double winnings,
    required List<String> lifeline_used,
    required Questionmodel queModel,
    required String user_selected_option,
  }) async {
    await _client.from("quiz_questions_history").insert({
      "quiz_id": quizModel.quiz_id,
      "user_id": ProfileSession.profile!.id,
      "question": queModel.question,
      "options": [
        queModel.option1,
        queModel.option2,
        queModel.option3,
        queModel.option4,
      ],
      "correct_option": queModel.correctOpt,
      "user_selected": user_selected_option,
      "prize": winnings,
      "lifeline_used": lifeline_used,
      "created_at": DateTime.now().toIso8601String(),
    });
  }
}

