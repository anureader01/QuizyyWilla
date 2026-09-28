import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:quizbit_2/features/quizdetail/quizdetail_screen.dart';
import 'package:quizbit_2/models/quizModel.dart';

class CustomSlideshow extends StatefulWidget {
  final List<QuizModel> quizModels;
  const CustomSlideshow({super.key, required this.quizModels});

  @override
  State<CustomSlideshow> createState() => _CustomSlideshowState();
}

class _CustomSlideshowState extends State<CustomSlideshow> {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kSoft = Color(0xFFEFEAE2);

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.quizModels.isEmpty) {
      return Container(
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: kSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            "No quizzes available",
            style: TextStyle(
              color: Color(0xFF8A8A95),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 230,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeOutCubic,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            viewportFraction: 0.88,
            onPageChanged: (index, _) {
              setState(() => _currentIndex = index);
            },
          ),
          items: widget.quizModels.map((quiz) {
            return Builder(
              builder: (BuildContext context) {
                return _SlideCard(quiz: quiz);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        // ---- Page indicators ----
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.quizModels.length, (i) {
            final isActive = i == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 22 : 6,
              decoration: BoxDecoration(
                color: isActive ? kAccent : kSoft,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SlideCard extends StatelessWidget {
  final QuizModel quiz;
  const _SlideCard({required this.quiz});

  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);

  String _levelLabel(int? level) {
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
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizDetailScreen(quizModel: quiz),
        ),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kDark.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ---- Cover image ----
              Image.network(
                quiz.quiz_cover_img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: kDark,
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        size: 40, color: Colors.white24),
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: kDark,
                    child: const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: kAccent,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // ---- Gradient overlay for readability ----
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kDark.withOpacity(0.4),
                      kDark.withOpacity(0.1),
                      kDark.withOpacity(0.85),
                      kDark.withOpacity(0.95),
                    ],
                    stops: const [0.0, 0.35, 0.75, 1.0],
                  ),
                ),
              ),

              // ---- Top row: level + rating ----
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating (glass pill)
                    _GlassPill(
                      icon: Icons.star_rounded,
                      label: (quiz.rating ?? 0).toStringAsFixed(1),
                    ),
                    // Level (orange for hard, light for others)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: quiz.level == 3
                            ? kAccent
                            : Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 12,
                            color: quiz.level == 3 ? Colors.white : kDark,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _levelLabel(quiz.level),
                            style: TextStyle(
                              color: quiz.level == 3 ? Colors.white : kDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ---- Bottom content ----
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Featured tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "FEATURED",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Title
                    Text(
                      quiz.quiz_title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Views
                    Row(
                      children: [
                        Icon(Icons.people_alt_rounded,
                            size: 13, color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          "${quiz.views} plays",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Divider line
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.15),
                    ),
                    const SizedBox(height: 10),

                    // Prize + Entry row
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            icon: Icons.emoji_events_rounded,
                            label: "TOP PRIZE",
                            value: "₹${quiz.top_prize}",
                            iconColor: kAccent,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Stat(
                            icon: Icons.payments_rounded,
                            label: "ENTRY",
                            value: "₹${quiz.entry_fees}",
                            iconColor: Colors.white.withOpacity(0.7),
                          ),
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

// ─────────────────────────────────────────────────────────────
// Pieces
// ─────────────────────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _SlideCard.kAccent, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
