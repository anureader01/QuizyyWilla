import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quizbit_2/core/utils/snackbar_helper.dart';
import 'package:quizbit_2/features/quiz/questionModel.dart';
import 'package:quizbit_2/features/quiz/quiz_controller.dart';
import 'package:quizbit_2/features/quiz/quiz_screen.dart';
import 'package:quizbit_2/models/quizModel.dart';

class QuizstartcountdownScreen extends StatefulWidget {
  final String topicName;
  final QuizModel quizModel;
  const QuizstartcountdownScreen({
    super.key,
    required this.topicName,
    required this.quizModel,
  });

  @override
  State<QuizstartcountdownScreen> createState() =>
      _QuizstartcountdownScreenState();
}

class _QuizstartcountdownScreenState extends State<QuizstartcountdownScreen>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  static const int _startFrom = 5;

  final QuizController _quizController = QuizController();

  Timer? _timer;
  int _secondsLeft = _startFrom;

  bool _questionsLoaded = false;
  bool _countdownComplete = false;
  bool _navigated = false;
  bool _hasError = false;
  String? _errorMessage;

  Questionmodel? _questionmodel;

  // ---- Animations ----
  late final AnimationController _tickController;
  late final Animation<double> _scaleAnim;
  late final AnimationController _ringController;
  late final AnimationController _dotsController;
  late final AnimationController _loadingPulseController;
  late final Animation<double> _loadingPulseAnim;

  // Rotating loading messages so it never feels stale
  final List<String> _loadingMessages = const [
    "Crafting your questions",
    "Picking the perfect mix",
    "Almost ready",
    "Adding a few tricky ones",
    "Polishing it up",
  ];
  int _messageIndex = 0;
  Timer? _messageRotateTimer;

  @override
  void initState() {
    super.initState();

    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 60),
    ]).animate(
      CurvedAnimation(parent: _tickController, curve: Curves.easeOutCubic),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _startFrom),
    );

    // Animated "..." dots
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    // Breathing pulse for loading state
    _loadingPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _loadingPulseAnim = Tween<double>(begin: 0.93, end: 1.07).animate(
      CurvedAnimation(
          parent: _loadingPulseController, curve: Curves.easeInOut),
    );

    _tickController.forward();
    _ringController.forward();
    _startTimer();
    _generateQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _messageRotateTimer?.cancel();
    _messageRotateTimer = null;
    _tickController.dispose();
    _ringController.dispose();
    _dotsController.dispose();
    _loadingPulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();
        _timer = null;
        setState(() {
          _secondsLeft = 0;
          _countdownComplete = true;
        });
        _startMessageRotation();
        _maybeNavigate();
      } else {
        setState(() => _secondsLeft--);
        _tickController
          ..reset()
          ..forward();
      }
    });
  }

  // Rotates the loading message every 1.8s while we wait for questions
  void _startMessageRotation() {
    _messageRotateTimer?.cancel();
    if (_questionsLoaded) return;
    _messageRotateTimer =
        Timer.periodic(const Duration(milliseconds: 1800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_questionsLoaded || _hasError) {
        timer.cancel();
        _messageRotateTimer = null;
        return;
      }
      setState(() {
        _messageIndex = (_messageIndex + 1) % _loadingMessages.length;
      });
    });
  }

  Future<void> _generateQuestions() async {
    try {
      final questionmodel = await _quizController.generateWithRetry(
        topic: widget.topicName,
        difficutly: 1,
        base_prize: widget.quizModel.base_prize.toInt(),
      );

      if (!mounted) return;
      setState(() {
        _questionmodel = questionmodel;
        _questionsLoaded = true;
      });
      _messageRotateTimer?.cancel();
      _messageRotateTimer = null;
      _maybeNavigate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      _timer?.cancel();
      _messageRotateTimer?.cancel();
      _ringController.stop();
      SnackbarHelper.showError(context, "Failed to generate quiz: $e");
    }
  }

  void _maybeNavigate() {
    if (_navigated) return;
    if (!_countdownComplete || !_questionsLoaded) return;
    if (_questionmodel == null) return;
    if (!mounted) return;

    _navigated = true;
    _timer?.cancel();
    _timer = null;
    _messageRotateTimer?.cancel();
    _messageRotateTimer = null;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          quiz_start_time: DateTime.now(),
          quizModel: widget.quizModel,
          difficutly: 1,
          topic: widget.topicName,
          questionmodel: _questionmodel!,
        ),
      ),
    );
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _questionsLoaded = false;
      _countdownComplete = false;
      _secondsLeft = _startFrom;
      _questionmodel = null;
      _messageIndex = 0;
    });
    _ringController
      ..reset()
      ..forward();
    _startTimer();
    _generateQuestions();
  }

  // Are we in the "waiting for questions" state?
  bool get _isLoading => _countdownComplete && !_questionsLoaded && !_hasError;

  // ---- Animated dots widget ----
  Widget _animatedDots({
    double fontSize = 13,
    Color color = kDark,
    FontWeight weight = FontWeight.w700,
  }) {
    return SizedBox(
      width: 18, // reserve space so layout doesn't jitter
      child: AnimatedBuilder(
        animation: _dotsController,
        builder: (context, _) {
          final count = ((_dotsController.value * 4).floor() % 4);
          return Text(
            "." * count,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: weight,
              color: color,
              height: 1,
            ),
          );
        },
      ),
    );
  }

  String _statusText() {
    if (_hasError) return "Something went wrong";
    if (_countdownComplete && _questionsLoaded) return "Starting now";
    if (_isLoading) return _loadingMessages[_messageIndex];
    if (_questionsLoaded) return "Get ready";
    return "Generating questions";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _hasError ? _errorView() : _countdownView(),
        ),
      ),
    );
  }

  // ---- Central loading visual (after countdown, while waiting) ----
  Widget _loadingCenter() {
    return ScaleTransition(
      scale: _loadingPulseAnim,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.psychology_alt_rounded,
              size: 52, color: kAccent),
          const SizedBox(height: 10),
          const Text(
            "Loading",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kDark,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          _animatedDots(fontSize: 22, weight: FontWeight.w900, color: kAccent),
        ],
      ),
    );
  }

  // ---- Number / GO! display during countdown ----
  Widget _countdownCenter() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: _secondsLeft == 0
          ? const Text(
              "GO!",
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.w900,
                color: kAccent,
                letterSpacing: 2,
              ),
            )
          : Text(
              "$_secondsLeft",
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                color: kDark,
                height: 1,
              ),
            ),
    );
  }

  // ---- Ring: determinate while counting, indeterminate while loading ----
  Widget _ring() {
    if (_isLoading) {
      return const SizedBox(
        width: 200,
        height: 200,
        child: CircularProgressIndicator(
          strokeWidth: 8,
          backgroundColor: kSoft,
          valueColor: AlwaysStoppedAnimation<Color>(kAccent),
        ),
      );
    }
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: _ringController,
        builder: (context, _) {
          return CircularProgressIndicator(
            value: 1.0 - _ringController.value,
            strokeWidth: 8,
            backgroundColor: kSoft,
            valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
          );
        },
      ),
    );
  }

  // ---- Main countdown view ----
  Widget _countdownView() {
    return Column(
      children: [
        const SizedBox(height: 20),

        // ---- Top topic chip ----
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kSoft, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded,
                    size: 12, color: kAccent),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  widget.topicName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kDark,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // ---- Heading ----
        Text(
          _isLoading ? "HANG TIGHT" : "GET READY",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: kMuted,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isLoading ? "Preparing your quiz" : "Quiz starts in",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kDark,
          ),
        ),

        const SizedBox(height: 36),

        // ---- Center stack ----
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Faint ring backdrop
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: kSoft, width: 1.5),
                ),
              ),
              // The progress ring (determinate or indeterminate)
              _ring(),
              // Inner soft disc — pulses when loading
              if (_isLoading)
                ScaleTransition(
                  scale: _loadingPulseAnim,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kAccent.withOpacity(0.1),
                    ),
                  ),
                )
              else
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kAccent.withOpacity(0.08),
                  ),
                ),
              // Center content
              _isLoading ? _loadingCenter() : _countdownCenter(),
            ],
          ),
        ),

        const SizedBox(height: 36),

        // ---- Status indicator with animated dots ----
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Container(
            key: ValueKey(_statusText()),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kSoft, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: _questionsLoaded
                      ? const Icon(Icons.check_circle_rounded,
                          size: 14, color: kAccent)
                      : const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kAccent,
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  _statusText(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kDark,
                  ),
                ),
                if (!_questionsLoaded && !_hasError) _animatedDots(),
              ],
            ),
          ),
        ),

        const Spacer(),

        // ---- Bottom hint ----
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  size: 14, color: kMuted.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                "Stay focused — no going back once it starts",
                style: TextStyle(
                  fontSize: 12,
                  color: kMuted.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Error view ----
  Widget _errorView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded,
              size: 48, color: Colors.redAccent),
        ),
        const SizedBox(height: 20),
        const Text(
          "Couldn't start the quiz",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: kDark,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _errorMessage ?? "Something went wrong while generating questions.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: kMuted,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _retry,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, size: 18),
                SizedBox(width: 6),
                Text("Try Again",
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: kMuted),
          child: const Text("Go back",
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
