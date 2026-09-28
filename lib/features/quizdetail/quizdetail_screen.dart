import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:quizbit_2/core/services/authgate_service.dart';
import 'package:quizbit_2/core/services/supabase_service.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/core/utils/snackbar_helper.dart';
import 'package:quizbit_2/features/auth/auth_controller.dart';
import 'package:quizbit_2/features/auth/screens/login.dart';
import 'package:quizbit_2/features/home/home_controller.dart';
import 'package:quizbit_2/features/quiz/questionModel.dart';
import 'package:quizbit_2/features/quiz/quiz_controller.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_enum.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_screen.dart';
import 'package:quizbit_2/features/quizdetail/rating_controller.dart';
import 'package:quizbit_2/features/quizstartcountdown/quizstartcountdown_screen.dart';
import 'package:quizbit_2/models/quizModel.dart';
import 'package:quizbit_2/features/quiz/quiz_screen.dart';
import 'package:quizbit_2/models/ratingCommentModel.dart';
import 'package:quizbit_2/widgets/chip.dart';
import 'package:quizbit_2/widgets/quiz_item.dart';
import 'package:quizbit_2/widgets/ratingCard.dart';
import 'package:quizbit_2/widgets/ratingItem.dart';
import 'package:quizbit_2/widgets/rating_dialog.dart';

class QuizDetailScreen extends StatefulWidget {
  final QuizModel quizModel;
  const QuizDetailScreen({super.key, required this.quizModel});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen>
    with TickerProviderStateMixin {
  // --- Same minimal palette as HomeScreen ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  final QuizController quizController = QuizController();
  final HomeController homeController = HomeController();
  final RatingController _ratingController = RatingController();

  RatingCommentmodel? _myRating;
  List<RatingCommentmodel> allRatingsList = [];
  bool _ratingLoading = true;
  bool isPlaying = false;

  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.98, end: 1.04)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    fetchYouMayLike();
    _loadAllRating();
    _loadMyRating();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  fetchYouMayLike() async {
    await homeController.loadYouMayLike();
    if (mounted) setState(() {});
  }

  _loadMyRating() async {
    final rating =
        await _ratingController.fetchMyRating(widget.quizModel.quiz_id);
    if (!mounted) return;
    setState(() {
      _myRating = rating;
      _ratingLoading = false;
    });
  }

  Future<List<RatingCommentmodel>?> _loadAllRating() async {
    setState(() => _ratingLoading = true);
    final ratingList =
        await _ratingController.fetchAllRating(widget.quizModel.quiz_id);
    if (!mounted) return null;
    setState(() {
      allRatingsList = ratingList;
      _ratingLoading = false;
    });
    return ratingList;
  }

  _openRatingDialog() async {
    if (!ProfileSession.isLoggedIn) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    final result = await showRatingDialog(context);
    if (result == null) return;

    final wasNew = _myRating == null;
    final saved = await _ratingController.submitRating(
      quizId: widget.quizModel.quiz_id,
      rating: result.rating,
      comment: result.comment,
      existing: _myRating,
    );

    if (!mounted) return;
    setState(() => _myRating = saved);
    SnackbarHelper.showInfo(context, wasNew ? "Review Posted" : "Review Edited");
  }

  // ---- Animated wrapper ----
  Widget _animated(Widget child, {double delay = 0}) {
    final start = delay.clamp(0.0, 0.9);
    final end = (start + 0.5).clamp(0.0, 1.0);
    final anim = CurvedAnimation(
      parent: _fadeController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  // ---- Difficulty label ----
  String _difficultyLabel(int level) {
    switch (level) {
      case 3:
        return "Hard";
      case 2:
        return "Medium";
      default:
        return "Easy";
    }
  }

  // ---- Section header ----
  Widget _sectionHeader(String title, {String? subtitle, VoidCallback? onMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                  height: 1.1,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onMore != null)
          GestureDetector(
            onTap: onMore,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text("See all",
                    style: TextStyle(
                        color: kAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded, size: 16, color: kAccent),
              ],
            ),
          ),
      ],
    );
  }

  // ---- Stat pill (used in entry fees card) ----
  Widget _statPill(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Entry fees / info card ----
  Widget _infoCard() {
    final quizModel = widget.quizModel;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "ENTRY FEES",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white54, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "₹",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: kAccent,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "${quizModel.entry_fees}",
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  "per play",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _statPill(
                  Icons.bar_chart_rounded,
                  "LEVEL",
                  _difficultyLabel(quizModel.level),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statPill(
                  Icons.people_alt_rounded,
                  "PLAYED",
                  "${quizModel.views}",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---- Description card ----
  Widget _descriptionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    size: 16, color: kAccent),
              ),
              const SizedBox(width: 10),
              const Text(
                "About this quiz",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.quizModel.quiz_des,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: kDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Tags row ----
  Widget _tagsRow() {
    if (widget.quizModel.tags.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TAGS",
          style: TextStyle(
            fontSize: 11,
            color: kMuted,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.quizModel.tags.map((tag) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizExploreScreen(
                      category: QuizCategory.byTag,
                      tag: tag,
                    ),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kSoft, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag_rounded, size: 13, color: kAccent),
                    const SizedBox(width: 4),
                    Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ---- Quiz row (safe) ----
  Widget _quizRow(List<QuizModel> list) {
    final count = list.isEmpty ? 0 : math.min(list.length, 15);
    if (count == 0) {
      return SizedBox(
        height: 270,
        child: Center(
          child:
              Text("Nothing here yet", style: TextStyle(color: kMuted)),
        ),
      );
    }
    return SizedBox(
      height: 270,
      child: ListView.separated(
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (index * 60)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: QuizItem(quizModel: list[index]),
          );
        },
      ),
    );
  }

  // ---- Bottom Play button ----
  Widget _playButton() {
    final quizModel = widget.quizModel;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: kBg,
          border: Border(top: BorderSide(color: kSoft, width: 1.2)),
        ),
        child: ScaleTransition(
          scale: _pulse,
          child: SizedBox(
            height: 58,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                disabledBackgroundColor: kAccent.withOpacity(0.5),
                elevation: 0,
                shadowColor: kAccent.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isPlaying
                  ? null
                  : () async {
                      setState(() => isPlaying = true);
                      try {
                        final client = SupabaseService().client;
                        final session = client.auth.currentSession;

                        if (session != null) {
                          final success = await quizController.startQuiz(
                            quizModel.entry_fees.toDouble(),
                            quizModel.quiz_id,
                            quizModel.quiz_title,
                          );

                          if (!mounted) return;

                          if (!success) {
                            SnackbarHelper.showError(
                                context, "Insufficient Balance");
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AuthgateService(
                                  nextScreen: QuizstartcountdownScreen(
                                    quizModel: quizModel,
                                    topicName: quizModel.quiz_title,
                                  ),
                                ),
                              ),
                            );
                          }
                        } else {
                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        }
                      } finally {
                        if (mounted) setState(() => isPlaying = false);
                      }
                    },
              child: isPlaying
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 24),
                        SizedBox(width: 6),
                        Text(
                          "READY TO PLAY",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizModel = widget.quizModel;
    return Scaffold(
      backgroundColor: kBg,
      bottomNavigationBar: _playButton(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ----- Hero AppBar -----
          SliverAppBar(
            backgroundColor: kDark,
            pinned: true,
            expandedHeight: 260,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      _difficultyLabel(quizModel.level).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizModel.quiz_title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    quizModel.quiz_cover_img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: kDark),
                  ),
                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          kDark.withOpacity(0.3),
                          kDark.withOpacity(0.5),
                          kDark.withOpacity(0.95),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Player count chip floating bottom-right
                  Positioned(
                    right: 20,
                    bottom: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.people_alt_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            "${quizModel.views} played",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ----- Body -----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _animated(_infoCard(), delay: 0.0),
                  const SizedBox(height: 18),

                  _animated(_descriptionCard(), delay: 0.1),
                  const SizedBox(height: 18),

                  _animated(_tagsRow(), delay: 0.15),
                  const SizedBox(height: 24),

                  // ----- You May Like -----
                  _animated(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          "You May Like",
                          subtitle: "Similar quizzes you'll enjoy",
                          onMore: widget.quizModel.tags.isEmpty
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizExploreScreen(
                                        category: QuizCategory.byTag,
                                        tag: widget.quizModel.tags.first,
                                      ),
                                    ),
                                  );
                                },
                        ),
                        const SizedBox(height: 14),
                        _quizRow(homeController.youMayLike),
                      ],
                    ),
                    delay: 0.2,
                  ),

                  const SizedBox(height: 28),

                  // ----- Ratings & Reviews -----
                  _animated(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionHeader(
                          "Ratings & Reviews",
                          subtitle: allRatingsList.isEmpty
                              ? "Be the first to review"
                              : "${allRatingsList.length} ${allRatingsList.length == 1 ? 'review' : 'reviews'}",
                        ),
                        const SizedBox(height: 16),

                        // Your rating block
                        if (_ratingLoading)
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: kSoft, width: 1.5),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: kAccent,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        else ...[
                          if (_myRating != null) ...[
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8, left: 4),
                              child: Text(
                                "YOUR REVIEW",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: kMuted,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            Ratingitem(rating: _myRating!),
                          ] else
                            GiveRatingCard(onTap: _openRatingDialog),
                        ],

                        const SizedBox(height: 20),

                        if (allRatingsList.isNotEmpty) ...[
                          Row(
                            children: [
                              Expanded(
                                  child: Container(height: 1, color: kSoft)),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "ALL REVIEWS",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: kMuted,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(height: 1, color: kSoft)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allRatingsList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: Duration(
                                    milliseconds: 300 + (index * 50)),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 12 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child:
                                    Ratingitem(rating: allRatingsList[index]),
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                    delay: 0.25,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
