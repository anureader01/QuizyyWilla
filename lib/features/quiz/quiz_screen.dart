import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quizbit_2/core/session/LifeLineSession.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/core/utils/lifeLineController.dart';
import 'package:quizbit_2/core/utils/lifelineEnum.dart';
import 'package:quizbit_2/core/utils/quiz_timer.dart';
import 'package:quizbit_2/core/utils/rewarded_ad_service.dart';
import 'package:quizbit_2/core/utils/snackbar_helper.dart';
import 'package:quizbit_2/features/leaderboard/leaderboard_screen.dart';
import 'package:quizbit_2/features/quiz/questionModel.dart';
import 'package:quizbit_2/features/quiz/quiz_controller.dart';
import 'package:quizbit_2/features/quizresult/quizresult_screen.dart';
import 'package:quizbit_2/models/quizModel.dart';
import 'package:quizbit_2/widgets/optionTile.dart';
import 'package:quizbit_2/widgets/quizDrawer.dart';
import 'package:vapi/vapi.dart';

class QuizScreen extends StatefulWidget {
  final String topic;
  final QuizModel quizModel;
  final Questionmodel questionmodel;
  final DateTime quiz_start_time;
  final int difficutly;
  const QuizScreen({
    super.key,
    required this.quiz_start_time,
    required this.questionmodel,
    required this.topic,
    required this.difficutly,
    required this.quizModel,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);
  static const Color kDanger = Color(0xFFE74C3C);

  final QuizController quizController = QuizController();

  late QuizTimer timer;
  int remaining = 25;
  static const int kInitialSeconds = 25;
  Set<String> disabledOptions = {};

  VapiClient? vapiclient;
  VapiCall? currentCall;

  bool isCalling = false;
  int callSeconds = 50;
  Timer? callTimer;

  final String publicKey = dotenv.env["VAPI_PUBLIC_KEY"]!;
  final String assistantId = dotenv.env["VAPI_ASSISTANT_ID"]!;

  Map<String, int> audiencePollData = {};
  Questionmodel? nextQueModel;
  bool nextQueLoaded = false;

  String? selectedOption;
  bool isLocked = false;
  bool showResult = false;
  String? generationError;

  Function? dialogSetState;
  bool isDialogOpen = false;

  // ============================================================
  // LIFECYCLE
  // ============================================================
  @override
  void initState() {
    super.initState();

    VapiClient.platformInitialized.future.then((_) {
      vapiclient = VapiClient(publicKey);
    });
    generateQuestion();
    WidgetsBinding.instance.addObserver(this);
    startNewQuestion();
    RewardedAdService.loadAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    callTimer?.cancel();
    callTimer = null;
    currentCall?.dispose();
    vapiclient?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => remaining = timer.getRemainingSeconds());
    }
  }

  // ============================================================
  // QUIZ FLOW
  // ============================================================
  void startNewQuestion() {
    if (widget.questionmodel.queMoney == 0) {
      widget.questionmodel.queMoney = (widget.quizModel.base_prize).toInt();
    }
    timer = QuizTimer(remainingSeconds: remaining);
    timer.start();
    startUIReferesh();
  }

  void startUIReferesh() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() => remaining = timer.getRemainingSeconds());
      if (timer.isTimeUp()) {
        onTimerUp();
        return false;
      }
      return true;
    });
  }

  void onTimerUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LeaderboardScreen()),
    );
  }

  Future<void> waitForNextOrError() async {
    int waited = 0;
    while (!nextQueLoaded && generationError == null) {
      await Future.delayed(const Duration(milliseconds: 200));
      waited += 200;
      if (waited > 5000) break;
    }
  }

void onOptionSelected(String option) async {
  if (isLocked) return;

  setState(() {
    selectedOption = option;
    isLocked = true;
  });

  timer.pause();

  print("USER SELECTED OPTION: $option");

  // Next question generate hone ka wait
  await waitForNextOrError();

  // Agar next question generate nahi hua
  if (nextQueModel == null) {
    print("NEXT QUESTION IS NULL");

    if (!mounted) return;

    setState(() {
      isLocked = false;
    });

    SnackbarHelper.showError(
      context,
      "Next question is still loading. Please try again.",
    );

    startNewQuestion();

    return;
  }

  if (!mounted) return;

  setState(() {
    showResult = true;
  });

  await Future.delayed(
    const Duration(seconds: 2),
  );

  if (!mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => QuizresultScreen(
        correctAns: widget.questionmodel.correctOpt,
        currQuizModel: widget.quizModel,
        curreQueModel: widget.questionmodel,
        difficutly: widget.difficutly,
        lifeline_used: LifeLineSession.lifeLineUsed(),
        nextQueModel: nextQueModel!,
        quiz_start_time: widget.quiz_start_time,
        selectedOption: selectedOption!,
        topic: widget.topic,
        winnings: widget.questionmodel.queMoney,
        prev_explanation: widget.questionmodel.explanation,
      ),
    ),
  );
}

  void generateQuestion() async {
    int currentDifficulty = widget.difficutly;
    try {
      Questionmodel nextGenQueModel = await quizController.generateWithRetry(
        topic: widget.topic,
        difficutly: currentDifficulty++,
        base_prize: widget.quizModel.base_prize.toInt(),
      );
      nextGenQueModel.queMoney =
          (widget.questionmodel.queMoney * widget.quizModel.greed_factor)
              .toInt();

      if (!mounted) return;
      setState(() {
        nextQueLoaded = true;
        nextQueModel = nextGenQueModel;
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, e.toString());
      setState(() => generationError = e.toString());
    }
  }

  // ============================================================
  // REWARDED AD
  // ============================================================
  void showRewardedAd() {
    timer.pause();
    RewardedAdService.show(
      onRewarded: () {
        if (!mounted) return;
        timer.addExtraSeconds(10);
        SnackbarHelper.showSucess(context, "Time increased by +10 seconds");
      },
      onClosed: () {
        if (!mounted) return;
        timer.resume();
        timer.addExtraSeconds(10);
        setState(() => remaining = timer.getRemainingSeconds());
      },
      onUnavailable: () {
        if (!mounted) return;
        timer.resume();
        SnackbarHelper.showError(context, "Ad not ready, please try again");
      },
    );
  }

  // ============================================================
  // 50/50 + AUDIENCE POLL
  // ============================================================
  void applyFify50() {
    final options = [
      widget.questionmodel.option1,
      widget.questionmodel.option2,
      widget.questionmodel.option3,
      widget.questionmodel.option4,
    ];
    final correct = widget.questionmodel.correctOpt;
    final wrongOptions = options.where((o) => o != correct).toList();
    wrongOptions.shuffle();
    final toRemove = wrongOptions.take(2).toList();
    setState(() => disabledOptions = toRemove.toSet());
  }

  void generateAudienePoll() {
    final options = [
      widget.questionmodel.option1,
      widget.questionmodel.option2,
      widget.questionmodel.option3,
      widget.questionmodel.option4,
    ];
    final correct = widget.questionmodel.correctOpt;
    Map<String, int> poll = {};
    bool correcrDominates = Random().nextDouble() < 0.7;

    for (var option in options) {
      if (option == correct && correcrDominates) {
        poll[option] = 50 + Random().nextInt(20);
      } else {
        poll[option] = Random().nextInt(30);
      }
    }
    setState(() => audiencePollData = poll);
  }

  // ============================================================
  // LIFELINES
  // ============================================================
  void handleLifeLine(LifeLineType type) {
    if (LifeLineSession.isUsed(type)) return;
    showConfirmationDialog(type);
  }

  void showConfirmationDialog(LifeLineType type) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined,
                    color: kAccent, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                "Use Lifeline?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "This will be marked as used and can't be undone.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kMuted),
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
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        executeLifeLine(type);
                      },
                      child: const Text("Use it",
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

  void executeLifeLine(LifeLineType type) async {
    if (LifeLineSession.isUsed(type)) return;
    LifeLineSession.markUsed(type);
    timer.pause();

    switch (type) {
      case LifeLineType.fiftyFifty:
        applyFify50();
        timer.resume();
        break;
      case LifeLineType.queHint:
        await _handleHint();
        break;
      case LifeLineType.audiencePoll:
        await _handleAudiencePoll();
        break;
      case LifeLineType.expertAdvice:
        await _handleExpertAdvice();
        break;
    }
  }

  Future<void> showAutoCloseDialog({
    required Widget content,
    required int seconds,
    String? title,
  }) async {
    bool isOpen = true;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.auto_awesome_rounded,
                          color: kAccent, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              content,
            ],
          ),
        ),
      ),
    );

    await Future.delayed(Duration(seconds: seconds));
    if (mounted && isOpen && Navigator.canPop(context)) {
      Navigator.pop(context);
      isOpen = false;
    }
    timer.resume();
  }

  Future<void> _handleHint() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: const Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: kAccent, strokeWidth: 2.5),
              SizedBox(height: 16),
              Text("Generating Hint...",
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: kDark)),
            ],
          ),
        ),
      ),
    );

    final hint = await quizController
        .generateHint(widget.questionmodel.question, [
      widget.questionmodel.option1,
      widget.questionmodel.option2,
      widget.questionmodel.option3,
      widget.questionmodel.option4,
    ]);

    if (mounted && Navigator.canPop(context)) Navigator.pop(context);

    await showAutoCloseDialog(
      title: "HINT",
      content: Text(
        hint,
        style: const TextStyle(
            fontSize: 14, color: kDark, height: 1.5, fontWeight: FontWeight.w500),
      ),
      seconds: 15,
    );
  }

  Future<void> _handleAudiencePoll() async {
    generateAudienePoll();
    await showAutoCloseDialog(
      title: "AUDIENCE POLL",
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: audiencePollData.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          e.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kDark,
                          ),
                        ),
                      ),
                      Text(
                        "${e.value}%",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: e.value / 100,
                      minHeight: 6,
                      backgroundColor: kSoft,
                      valueColor: const AlwaysStoppedAnimation(kAccent),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      seconds: 15,
    );
  }

  Future<void> _handleExpertAdvice() async {
    if (vapiclient == null) {
      SnackbarHelper.showError(context, "Voice client not ready yet");
      timer.resume();
      return;
    }

    isDialogOpen = true;
    isCalling = false;
    callSeconds = 50;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            dialogSetState = setDialogState;
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCalling) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                                color: kAccent, strokeWidth: 2.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Connecting to Expert',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Hang on a moment...',
                          style: TextStyle(fontSize: 12, color: kMuted),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: kAccent.withOpacity(0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.phone_in_talk_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Expert call active",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$callSeconds sec remaining",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: kAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDanger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: endCall,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.call_end_rounded, size: 18),
                                SizedBox(width: 6),
                                Text("End Call",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    await startVapiCall();
  }

  Future<void> startVapiCall() async {
    try {
      final call = await vapiclient!.start(assistantId: assistantId);
      currentCall = call;
      call.onEvent.listen(handleVapiEvents);
    } catch (e) {
      await endCall();
      if (mounted) {
        SnackbarHelper.showError(context, "Failed to start expert call");
      }
    }
  }

  void handleVapiEvents(VapiEvent event) {
    if (event.label == 'message' && !isCalling) {
      isCalling = true;
      dialogSetState?.call(() {});
      startCallTimer();
    }
    if (event.label == 'call-end' && isDialogOpen) endCall();
  }

  void startCallTimer() {
    callTimer?.cancel();
    callSeconds = 50;
    callTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isDialogOpen) {
        t.cancel();
        return;
      }
      if (callSeconds <= 0) {
        t.cancel();
        endCall();
        return;
      }
      callSeconds--;
      dialogSetState?.call(() {});
    });
  }

  Future<void> endCall() async {
    if (!isDialogOpen) return;
    isDialogOpen = false;
    isCalling = false;
    callTimer?.cancel();
    callTimer = null;

    final call = currentCall;
    currentCall = null;
    dialogSetState = null;

    try {
      await call?.stop();
    } catch (_) {}

    if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    if (mounted) timer.resume();
  }

  // ============================================================
  // UI HELPERS
  // ============================================================
  Color get _timerColor {
    if (remaining <= 5) return kDanger;
    if (remaining <= 10) return kAccent;
    return kDark;
  }

  double get _timerProgress => (remaining / kInitialSeconds).clamp(0.0, 1.0);

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final queModel = widget.questionmodel;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitDialog();
        if (shouldExit == true && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: kBg,
        drawer: QuizDrawer(
          context: context,
          usedMap: {
            LifeLineType.fiftyFifty:
                LifeLineSession.isUsed(LifeLineType.fiftyFifty),
            LifeLineType.audiencePoll:
                LifeLineSession.isUsed(LifeLineType.audiencePoll),
            LifeLineType.expertAdvice:
                LifeLineSession.isUsed(LifeLineType.expertAdvice),
            LifeLineType.queHint:
                LifeLineSession.isUsed(LifeLineType.queHint),
          },
          onLifeLineSelected: handleLifeLine,
          quizModel: widget.quizModel,
          que_money: widget.questionmodel.queMoney,
        ),
        appBar: _appBar(queModel),
        bottomNavigationBar: _quitBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _heroSection(queModel),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _questionCard(queModel),
                      const SizedBox(height: 20),
                      optionTile(
                        isDisabled: disabledOptions.contains(queModel.option1),
                        isLocked: isLocked,
                        onTap: () => onOptionSelected(queModel.option1),
                        selectedOption: selectedOption,
                        showResult: showResult,
                        optionText: queModel.option1.trim(),
                        correctAns: queModel.correctOpt,
                      ),
                      optionTile(
                        isDisabled: disabledOptions.contains(queModel.option2),
                        isLocked: isLocked,
                        onTap: () => onOptionSelected(queModel.option2),
                        selectedOption: selectedOption,
                        showResult: showResult,
                        optionText: queModel.option2.trim(),
                        correctAns: queModel.correctOpt,
                      ),
                      optionTile(
                        isDisabled: disabledOptions.contains(queModel.option3),
                        isLocked: isLocked,
                        onTap: () => onOptionSelected(queModel.option3),
                        selectedOption: selectedOption,
                        showResult: showResult,
                        optionText: queModel.option3.trim(),
                        correctAns: queModel.correctOpt,
                      ),
                      optionTile(
                        isDisabled: disabledOptions.contains(queModel.option4),
                        isLocked: isLocked,
                        onTap: () => onOptionSelected(queModel.option4),
                        selectedOption: selectedOption,
                        showResult: showResult,
                        optionText: queModel.option4.trim(),
                        correctAns: queModel.correctOpt,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- App bar with prize pill ----
  PreferredSizeWidget _appBar(Questionmodel queModel) {
    return AppBar(
      backgroundColor: kBg,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: kDark),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded,
                color: kAccent, size: 16),
            const SizedBox(width: 6),
            Text(
              "₹${queModel.queMoney}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "LVL ${widget.difficutly}",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: kAccent,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---- Hero section: image + timer ring + time-add pills ----
  Widget _heroSection(Questionmodel queModel) {
    final imgUrl = queModel.queImgUrl;
    final hasImage = imgUrl != null && imgUrl.isNotEmpty;

    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover image
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: kDark,
              boxShadow: [
                BoxShadow(
                  color: kDark.withOpacity(0.15),
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
                  if (hasImage)
                    Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: kDark),
                    )
                  else
                    Container(color: kDark),
                  // Gradient overlay for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          kDark.withOpacity(0.2),
                          kDark.withOpacity(0.55),
                          kDark.withOpacity(0.85),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Topic name top-left
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded,
                                  color: kAccent, size: 12),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: Text(
                                  widget.topic,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Time-add pills
          Positioned(
            bottom: 0,
            left: 24,
            child: _timePill(
              "+10 Sec",
              Icons.play_circle_outline_rounded,
              onTap: showRewardedAd,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 24,
            child: _timePill(
              "+30 Sec",
              Icons.add_circle_outline_rounded,
              onTap: () {},
            ),
          ),

          // Center timer ring
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: Center(child: _timerRing()),
          ),
        ],
      ),
    );
  }

  Widget _timerRing() {
    return Container(
      height: 110,
      width: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: _timerColor.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ring
          SizedBox(
            width: 96,
            height: 96,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: _timerProgress, end: _timerProgress),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 6,
                  backgroundColor: kSoft,
                  valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                );
              },
            ),
          ),
          // Number
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$remaining",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: _timerColor,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "SEC",
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _timerColor.withOpacity(0.7),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timePill(String label, IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kSoft, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kDark.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kAccent, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: kDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Question card ----
  Widget _questionCard(Questionmodel queModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "QUESTION",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.help_outline_rounded,
                  size: 16, color: kMuted.withOpacity(0.7)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            queModel.question,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kDark,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Quit bar ----
  Widget _quitBar() {
    final name = ProfileSession.profile?.name ?? "Player";
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: kBg,
          border: Border(top: BorderSide(color: kSoft, width: 1.2)),
        ),
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kDark,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () async {
              final shouldExit = await _showExitDialog();
              if (shouldExit == true && mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LeaderboardScreen()),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, size: 18),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "QUIT QUIZ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      "Playing as $name",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showExitDialog() {
    return showDialog<bool>(
      barrierDismissible: false,
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: kDanger, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                "Quit Quiz?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "You'll lose your progress and no money will be credited.",
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
                      child: const Text("Keep playing",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDanger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Quit",
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
}
