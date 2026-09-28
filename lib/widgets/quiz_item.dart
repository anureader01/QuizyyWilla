import 'package:flutter/material.dart';
import 'package:quizbit_2/models/quizModel.dart';
import 'package:quizbit_2/features/quizdetail/quizdetail_screen.dart';

class QuizItem extends StatelessWidget {
  final QuizModel quizModel;
  const QuizItem({super.key, required this.quizModel});

  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kSoft = Color(0xFFEFEAE2);

  String _difficultyLabel(int level) {
    switch (level) {
      case 3:
        return "HARD";
      case 2:
        return "MEDIUM";
      default:
        return "EASY";
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = quizModel.quiz_verti_img;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetailScreen(quizModel: quizModel),
          ),
        );
      },
      child: Container(
        width: 170,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: kDark,
          boxShadow: [
            BoxShadow(
              color: kDark.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ---- Background image ----
              Image.network(
                coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kDark,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Colors.white24, size: 32),
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: kDark,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ---- Gradient overlay for legibility ----
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kDark.withOpacity(0.55),
                      kDark.withOpacity(0.15),
                      kDark.withOpacity(0.85),
                      kDark.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.35, 0.75, 1.0],
                  ),
                ),
              ),

              // ---- Top row: level badge ----
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Entry fees pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.payments_rounded,
                              size: 11, color: kAccent),
                          const SizedBox(width: 4),
                          Text(
                            "₹${quizModel.entry_fees}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Level badge — orange only for HARD, light for others
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: quizModel.level == 3
                            ? kAccent
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _difficultyLabel(quizModel.level),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: quizModel.level == 3 ? Colors.white : kDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Bottom content ----
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quizModel.quiz_title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top prize
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded,
                                size: 13, color: kAccent),
                            const SizedBox(width: 3),
                            Text(
                              "₹${quizModel.top_prize}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        // Player count
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_alt_rounded,
                                size: 13,
                                color: Colors.white.withOpacity(0.7)),
                            const SizedBox(width: 3),
                            Text(
                              "${quizModel.views}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.85),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
