import 'dart:convert';

import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/core/session/LifeLineSession.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/features/quiz/questionModel.dart';
import 'package:quizbit_2/features/quiz/quiz_repository.dart';
import 'package:quizbit_2/models/quizModel.dart';

class QuizController {
  final QuizRepository _quizRepository;
  QuizController() : _quizRepository = QuizRepository(SupabaseService().client);

  Future<Questionmodel> generateWithRetry({
    required String topic,
    required int difficutly,
    required int base_prize,
  }) async {
    String prompt =
        """Generate exactly ONE quiz question in STRICT JSON format.

Rules:
- Return ONLY JSON (no explanation outside JSON)
- Exactly 4 options
- One correct answer
- Keep it concise
- Do NOT repeat previously common questions — aim for variety in subtopics, phrasing, and concepts
- Randomization seed: ${DateTime.now().millisecondsSinceEpoch}

Variation strategy (pick based on seed):
- Vary subtopic focus within the main topic
- Vary option structure: mix plausible distractors differently each time

Format:
{
  "question": "",
  "options": ["", "", "", ""],
  "correctAnswer": "",
  "explanation": ""
}

Topic: $topic
Difficulty: $difficutly""";

    int retry = 0;

    while (retry < 3) {
      try {
        print("======================================");
        print("GENERATING QUESTION");
        print("ATTEMPT: ${retry + 1}");
        print("TOPIC: $topic");
        print("DIFFICULTY: $difficutly");
        print("======================================");

        final raw = await _quizRepository.generateQuestion(prompt);

        // Gemini ne response nahi diya
        if (raw == null) {
          print("GEMINI RESPONSE IS NULL");

          retry++;

          if (retry < 3) {
            print("RETRYING...");
            await Future.delayed(
              const Duration(seconds: 1),
            );
          }

          continue;
        }

        print("RAW GEMINI RESPONSE:");
        print(raw);

        final decoded = jsonDecode(raw);

        final text =
            decoded["candidates"][0]['content']['parts'][0]['text'] as String;

        print("TEXT RECEIVED:");
        print(text);

        final cleanded = text
            .replaceAll("```json", "")
            .replaceAll("```", "")
            .trim();

        print("CLEANED DATA:");
        print(cleanded);

        final jsonData = jsonDecode(cleanded);

        print("DECODED JSON:");
        print(jsonData);

        final options = jsonData["options"] as List;

        // Check karo ki exactly 4 options aaye hain
        if (options.length != 4) {
          throw Exception(
            "Gemini did not return exactly 4 options",
          );
        }

        print("QUESTION GENERATED SUCCESSFULLY:");
        print(jsonData["question"]);

        return Questionmodel(
          question: jsonData["question"],
          option1: options[0],
          option2: options[1],
          option3: options[2],
          option4: options[3],
          correctOpt: jsonData["correctAnswer"],
          queMoney: base_prize,
          explanation: jsonData["explanation"],
        );
      } catch (e) {
        print("QUESTION GENERATION ERROR:");
        print(e);

        retry++;

        if (retry < 3) {
          print("RETRYING QUESTION GENERATION...");

          await Future.delayed(
            const Duration(seconds: 1),
          );
        }
      }
    }

    // Agar 3 attempts ke baad bhi Gemini fail ho gaya
    print("======================================");
    print("ALL 3 ATTEMPTS FAILED");
    print("USING FALLBACK QUESTION");
    print("======================================");

    return _quizRepository.getFallbackQuestion();
  }

  Future<String> generateHint(String question, List<String> options) async {
    final prompt =
        """
Give me a helpful hint for the question without revealing thr answer in two lines:

Question : $question,
Options : ${options.join(",")}

Rules:
- Return ONLY JSON (no explanation outside JSON)
- Exactly 1 field in json named hint
""";

    final raw = await _quizRepository.geminiAPIaCall(prompt);
    // final raw = null;

    if (raw == null) {
      return "The distance from earth to mars is very less";
    }

    final decoded = jsonDecode(raw);

    final text =
        decoded["candidates"][0]['content']['parts'][0]['text'] as String;

    print("text recieved");
    print(text);

    final cleanded = text
        .replaceAll("```json", "")
        .replaceAll("```", "")
        .trim();

    print("CLEADNED DATA $cleanded");

    final jsonData = jsonDecode(cleanded);

    print(jsonData);

    return jsonData["hint"];
  }

  Future<bool> startQuiz(
    double entryFee,
    String quizId,
    String quizTitle,
  ) async {
    final userId = ProfileSession.profile!.user_id;

    final success = await _quizRepository.deduct_money(
      userId,
      entryFee,
    );

    if (!success) {
      final errorMessage = "Insufficient Balance";
      return false;
    }

    LifeLineSession.reset();

    await _quizRepository.increaseViews(
      quizId,
      quizTitle,
    );

    return true;
  }

  Future<void> endQuiz(double winnings) async {
    final userId = ProfileSession.profile!.user_id;

    await _quizRepository.addMoney(
      userId,
      winnings,
    );
  }

  Future<void> addQuizToHistory(
    QuizModel quizModel,
    List<String> lifeline_used,
    DateTime started_at,
    double winnings,
  ) async {
    await _quizRepository.addQuizHistory(
      quizModel,
      winnings,
      lifeline_used,
      started_at,
    );
  }

  Future<void> addQueHistory({
    required String user_selected_option,
    required QuizModel quizModel,
    required List<String> lifeline_used,
    required double winnings,
    required Questionmodel queModel,
  }) async {
    await _quizRepository.addQueHistory(
      queModel: queModel,
      lifeline_used: lifeline_used,
      quizModel: quizModel,
      user_selected_option: user_selected_option,
      winnings: winnings,
    );
  }
}
