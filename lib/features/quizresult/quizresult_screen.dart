import 'package:flutter/material.dart';
import 'package:quizbit_2/core/session/LifeLineSession.dart';
import 'package:quizbit_2/features/home/home_screen.dart';
import 'package:quizbit_2/features/leaderboard/leaderboard_screen.dart';
import 'package:quizbit_2/features/quiz/questionModel.dart';
import 'package:quizbit_2/features/quiz/quiz_controller.dart';
import 'package:quizbit_2/features/quiz/quiz_screen.dart';
import 'package:quizbit_2/models/quizModel.dart';

class QuizresultScreen extends StatefulWidget {
  final String selectedOption;
  final Questionmodel nextQueModel;
  final Questionmodel curreQueModel;
  final QuizModel currQuizModel;
  final String prev_explanation;
  final String topic;
  final int difficutly;
  final String correctAns;
  final int winnings;
  final List<String> lifeline_used;
  final DateTime quiz_start_time;

  const QuizresultScreen({
    super.key,
    required this.curreQueModel,
    required this.correctAns,
    required this.prev_explanation,
    required this.difficutly,
    required this.nextQueModel,
    required this.selectedOption,
    required this.topic,
    required this.winnings,
    required this.currQuizModel,
    required this.lifeline_used,
    required this.quiz_start_time,
  });

  @override
  State<QuizresultScreen> createState() => _QuizresultScreenState();
}

class _QuizresultScreenState extends State<QuizresultScreen>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);
  static const Color kCorrect = Color(0xFF4CAF7C);
  static const Color kWrong = Color(0xFFE74C3C);

  final QuizController quizController = QuizController();

  late final AnimationController _iconController;
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _iconScale;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeOutCubic),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);

    // Stagger start
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 200),
        () => mounted ? _fadeController.forward() : null);

    addQueHistory();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> addQueHistory() async {
    await quizController.addQueHistory(
      user_selected_option: widget.selectedOption,
      quizModel: widget.currQuizModel,
      lifeline_used: LifeLineSession.lifeLineUsed(),
      winnings: widget.winnings.toDouble(),
      queModel: widget.curreQueModel,
    );
  }

  Widget _animated(Widget child, {double delay = 0}) {
    final start = delay.clamp(0.0, 0.85);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _fadeController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kWrong.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: kWrong, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                "Exit Quiz?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Your progress will be lost and no money will be credited.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: kDark,
                        backgroundColor: kSoft,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Stay",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kWrong,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Exit",
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUserWon =
        widget.selectedOption.trim() == widget.correctAns.trim();
    final stateColor = isUserWon ? kCorrect : kWrong;
    final creditAmount =
        (widget.winnings / widget.currQuizModel.greed_factor).toInt();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog();
        if (shouldExit == true && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: kBg,
        bottomNavigationBar: _bottomCta(isUserWon, creditAmount),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ---- Result hero ----
                _resultHero(isUserWon, stateColor),

                const SizedBox(height: 32),

                // ---- Selected answer card ----
                _animated(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _selectedAnswerCard(isUserWon, stateColor),
                  ),
                  delay: 0.1,
                ),

                const SizedBox(height: 14),

                // ---- Correct answer (only if wrong) ----
                if (!isUserWon)
                  _animated(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _correctAnswerCard(),
                    ),
                    delay: 0.15,
                  ),

                if (!isUserWon) const SizedBox(height: 14),

                // ---- Winnings card (only if correct) ----
                if (isUserWon)
                  _animated(
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _winningsCard(),
                    ),
                    delay: 0.15,
                  ),

                if (isUserWon) const SizedBox(height: 14),

                // ---- Explanation ----
                _animated(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _explanationCard(),
                  ),
                  delay: 0.2,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULT HERO
  // ============================================================
  Widget _resultHero(bool isUserWon, Color stateColor) {
    return Column(
      children: [
        // ---- Animated icon with pulsing rings ----
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing outer ring
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  return Container(
                    width: 140 + (_pulse.value * 50),
                    height: 140 + (_pulse.value * 50),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stateColor.withOpacity(0.08 * (1 - _pulse.value)),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) {
                  return Container(
                    width: 110 + (_pulse.value * 30),
                    height: 110 + (_pulse.value * 30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stateColor.withOpacity(0.12 * (1 - _pulse.value)),
                    ),
                  );
                },
              ),
              // Static inner disc
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stateColor.withOpacity(0.1),
                ),
              ),
              // Main icon (bounces in)
              ScaleTransition(
                scale: _iconScale,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: stateColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: stateColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    isUserWon ? Icons.check_rounded : Icons.close_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ---- Status pill ----
        _animated(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: stateColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUserWon
                      ? Icons.celebration_rounded
                      : Icons.sentiment_dissatisfied_rounded,
                  size: 13,
                  color: stateColor,
                ),
                const SizedBox(width: 5),
                Text(
                  isUserWon ? "CORRECT" : "INCORRECT",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: stateColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          delay: 0.05,
        ),

        const SizedBox(height: 10),

        // ---- Headline ----
        _animated(
          Text(
            isUserWon ? "Brilliant!" : "Not quite",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: kDark,
              letterSpacing: 0.3,
            ),
          ),
          delay: 0.05,
        ),

        const SizedBox(height: 6),

        // ---- Subtitle ----
        _animated(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              isUserWon
                  ? "You got it right — keep climbing"
                  : "Better luck on the next one",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: kMuted,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          delay: 0.05,
        ),
      ],
    );
  }

  // ============================================================
  // SELECTED ANSWER CARD
  // ============================================================
  Widget _selectedAnswerCard(bool isUserWon, Color stateColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stateColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stateColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isUserWon ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: stateColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "YOUR ANSWER",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: kMuted,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.selectedOption,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kDark,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CORRECT ANSWER CARD (shown only when wrong)
  // ============================================================
  Widget _correctAnswerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCorrect.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCorrect.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kCorrect.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_rounded,
                color: kCorrect, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "CORRECT ANSWER",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: kCorrect,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.correctAns,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kDark,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WINNINGS CARD (shown only when correct)
  // ============================================================
  Widget _winningsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: kAccent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "CURRENT WINNINGS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "₹",
                      style: TextStyle(
                        fontSize: 18,
                        color: kAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "${widget.winnings}",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Next question prize chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "NEXT",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  "₹${widget.nextQueModel.queMoney}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: kAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXPLANATION CARD
  // ============================================================
  Widget _explanationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: kAccent, size: 14),
              ),
              const SizedBox(width: 10),
              const Text(
                "EXPLANATION",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.prev_explanation,
            style: const TextStyle(
              fontSize: 14,
              color: kDark,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM CTA
  // ============================================================
  Widget _bottomCta(bool isUserWon, int creditAmount) {
    final label = isUserWon ? "NEXT QUESTION" : "CLAIM ₹$creditAmount";
    final subLabel = isUserWon
        ? "Win ₹${widget.nextQueModel.queMoney}"
        : "Better luck next time";

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: kBg,
          border: Border(top: BorderSide(color: kSoft, width: 1.2)),
        ),
        child: SizedBox(
          height: 64,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              if (isUserWon) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizScreen(
                      quizModel: widget.currQuizModel,
                      quiz_start_time: widget.quiz_start_time,
                      difficutly: widget.difficutly,
                      topic: widget.topic,
                      questionmodel: widget.nextQueModel,
                    ),
                  ),
                );
              } else {
                final wonMoney =
                    (widget.winnings / widget.currQuizModel.greed_factor);
                await quizController.addQuizToHistory(
                  widget.currQuizModel,
                  widget.lifeline_used,
                  widget.quiz_start_time,
                  wonMoney,
                );
                await quizController.endQuiz(wonMoney);
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LeaderboardScreen()),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
