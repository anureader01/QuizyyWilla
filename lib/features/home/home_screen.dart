import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:quizbit_2/core/services/locController.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/core/utils/snackbar_helper.dart';
import 'package:quizbit_2/features/auth/auth_controller.dart';
import 'package:quizbit_2/features/auth/screens/login.dart';
import 'package:quizbit_2/features/home/home_controller.dart';
import 'package:quizbit_2/features/home/topic_controller.dart';
import 'package:quizbit_2/features/leaderboard/leaderboard_controller.dart';
import 'package:quizbit_2/features/profile/profile_screen.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_enum.dart';
import 'package:quizbit_2/features/quizExplore/quiz_explore_screen.dart';
import 'package:quizbit_2/features/quizdetail/quizdetail_screen.dart';
import 'package:quizbit_2/models/profileModel.dart';
import 'package:quizbit_2/models/quizModel.dart';
import 'package:quizbit_2/widgets/custom_slideshow.dart';
import 'package:quizbit_2/widgets/homeDrawer.dart';
import 'package:quizbit_2/widgets/quiz_item.dart';
import 'dart:async';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // --- Minimal palette (3 colors only) ---
  static const Color kDark = Color(0xFF1E2236);       // deep navy/charcoal
  static const Color kAccent = Color(0xFFFF7A3D);     // warm orange
  static const Color kBg = Color(0xFFFAF7F2);         // soft cream
  static const Color kSoft = Color(0xFFEFEAE2);       // muted card bg
  static const Color kMuted = Color(0xFF8A8A95);      // secondary text

  // --- Animations ---
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  // --- Controllers ---
  final LocationController _locationController = LocationController();
  final LeaderboardController leaderboardController = LeaderboardController();
  final AuthController authController = AuthController();
  final AuthController _controller = AuthController();
  final homeController = HomeController();
  final _topicCtrl = TextEditingController();
  final _topicController = TopicController();

  List<ProfileModel> top4Users = [];
  bool isLoading = false;
  String? error;
  bool _submittingtopic = false;

  initLocation() async {
    try {
      await _locationController.saveLocation();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, "Location Error : ${e.toString()}");
    }
  }

  fetchTop4Users() async {
    final profiles = await leaderboardController.loadTop4Home();
    if (!mounted) return;
    setState(() => top4Users = profiles);
  }

  intiCreateSession() async {
    await authController.handleUserProfile();
  }

  loadHomeScreen() async {
    await homeController.loadHome();
    if (!mounted) return;
    setState(() {});
    _fadeController.forward();
  }

  Future<void> _logout() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    bool success = await _controller.logout();
    setState(() {
      isLoading = false;
      error = _controller.errorMessage;
    });
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<void> _submitTopic() async {
    if (_submittingtopic) return;
    setState(() => _submittingtopic = true);
    final result = await _topicController.submitTopic(_topicCtrl.text);
    if (!mounted) return;
    setState(() => _submittingtopic = false);

    if (result.success) {
      _topicCtrl.clear();
      SnackbarHelper.showSucess(context, result.message);
    } else {
      SnackbarHelper.showError(context, result.message);
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.97, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    intiCreateSession();
    initLocation();
    fetchTop4Users();
    loadHomeScreen();
  }

  @override
  void dispose() {
    _topicCtrl.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ---- Helpers ----
  int _safeLen(List list, [int max = 15]) =>
      list.isEmpty ? 0 : math.min(list.length, max);

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
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  // ---- Section header (minimal) ----
  Widget _sectionHeader(String title, {String? subtitle, VoidCallback? onMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
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
                Text(
                  "See all",
                  style: TextStyle(
                    color: kAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_rounded,
                    size: 16, color: kAccent),
              ],
            ),
          ),
      ],
    );
  }

  // ---- Top players (single-theme rings) ----
  Widget _topPlayers() {
    if (top4Users.isEmpty) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Text(
            "No champions yet — be the first!",
            style: TextStyle(color: kMuted),
          ),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: top4Users.length,
        itemBuilder: (context, index) {
          final user = top4Users[index];
          final isFirst = index == 0;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfileScreen(profile_id: user.user_id),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFirst ? kAccent : Colors.transparent,
                          border: isFirst
                              ? null
                              : Border.all(color: kSoft, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: kBg,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage:
                                NetworkImage(user.profile_pic_url),
                          ),
                        ),
                      ),
                      // Rank chip — orange only for #1, dark for others
                      Positioned(
                        bottom: -4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isFirst ? kAccent : kDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kBg, width: 2),
                            ),
                            child: Text(
                              "#${index + 1}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 78,
                    child: Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: kDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- Horizontal quiz list ----
  Widget _quizRow(List<QuizModel> list) {
    final count = _safeLen(list, 15);
    if (count == 0) {
      return SizedBox(
        height: 270,
        child: Center(
          child: Text("Nothing here yet",
              style: TextStyle(color: kMuted)),
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

  // ---- Latest quiz hero (dark card, orange CTA) ----
  Widget _latestQuizCard() {
    final latest = homeController.newlyAdded;
    if (latest == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: kSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text("No latest quiz available",
              style: TextStyle(color: kMuted)),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetailScreen(quizModel: latest),
          ),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: kDark.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background image with dark overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.35,
                  child: Image.network(
                    latest.quiz_cover_img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: kDark),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        kDark.withOpacity(0.95),
                        kDark.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: kAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "NEW",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            latest.quiz_title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Tap to play now",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white60,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ScaleTransition(
                      scale: _pulse,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccent,
                          boxShadow: [
                            BoxShadow(
                              color: kAccent.withOpacity(0.5),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
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

  // ---- Topic submission (light card, orange accent) ----
  Widget _topicCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    color: kAccent, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Suggest a Quiz",
                  style: TextStyle(
                    color: kDark,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Got an idea? Drop a topic and we'll build it for you.",
            style: TextStyle(color: kMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _topicCtrl,
                  enabled: !_submittingtopic,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: kDark),
                  onSubmitted: (value) => _submitTopic(),
                  decoration: InputDecoration(
                    hintText: "e.g. Space Exploration",
                    hintStyle: TextStyle(color: kMuted.withOpacity(0.7)),
                    filled: true,
                    fillColor: kBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _submittingtopic ? null : _submitTopic,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: kAccent.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _submittingtopic
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (homeController.isLoading) {
      return _HomeLoadingSplash();
    }

    return Scaffold(
      backgroundColor: kBg,
      drawer: const HomeDrawer(),
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bolt_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              "QuizyyWilla",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kDark,
                letterSpacing: 0.5,
              ),
            ),
            const Text(
              " 2.0",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: kAccent,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: kDark),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _animated(
              CustomSlideshow(quizModels: homeController.random3Quiz),
              delay: 0.0,
            ),
            const SizedBox(height: 32),

            // Top players
            _animated(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      "Masters of QuizyyWilla",
                      subtitle: "Top players this week",
                    ),
                    const SizedBox(height: 18),
                    _topPlayers(),
                  ],
                ),
              ),
              delay: 0.1,
            ),
            const SizedBox(height: 32),

            // Weekly Dhamaka
            _animated(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      "Weekly Dhamaka",
                      subtitle: "Fresh quizzes, just for you",
                      onMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizExploreScreen(
                                category: QuizCategory.newThisWeek),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _quizRow(homeController.weekelyDhamaka),
                  ],
                ),
              ),
              delay: 0.2,
            ),
            const SizedBox(height: 32),

            // Latest quiz hero
            _animated(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      "Latest Quiz",
                      subtitle: "Hot off the press",
                      onMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizExploreScreen(
                                category: QuizCategory.recentlyAdded),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _latestQuizCard(),
                  ],
                ),
              ),
              delay: 0.3,
            ),
            const SizedBox(height: 32),

            // Most played
            _animated(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                      "Most Played",
                      subtitle: "Community favorites",
                      onMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizExploreScreen(
                                category: QuizCategory.mostPlayed),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _quizRow(homeController.mostPlayed),
                  ],
                ),
              ),
              delay: 0.4,
            ),
            const SizedBox(height: 32),

            // Topic submission
            _animated(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _topicCard(),
              ),
              delay: 0.5,
            ),

            const SizedBox(height: 48),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  Container(
                    height: 1,
                    color: kSoft,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Text(
                            "MADE WITH ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                              letterSpacing: 1,
                            ),
                          ),
                          Icon(Icons.favorite, color: kAccent, size: 14),
                          Text(
                            " BY",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "v1.0.0",
                          style: TextStyle(
                            fontSize: 11,
                            color: kDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: kAccent,
                    ),
                    child: const CircleAvatar(
                      radius: 38,
                      backgroundImage: NetworkImage(
                        "data:image/jpeg;base64,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",
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Stay in Touch",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    children: [
                      _socialIcon(Icons.facebook_rounded),
                      _socialIcon(Icons.camera_alt_rounded),
                      _socialIcon(Icons.alternate_email_rounded),
                      _socialIcon(Icons.play_circle_fill_rounded),
                      _socialIcon(Icons.mail_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Icon(icon, color: kDark, size: 18),
    );
  }
}


















class _HomeLoadingSplash extends StatefulWidget {
  const _HomeLoadingSplash();

  @override
  State<_HomeLoadingSplash> createState() => _HomeLoadingSplashState();
}

class _HomeLoadingSplashState extends State<_HomeLoadingSplash>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  late final AnimationController _pulseController;
  late final AnimationController _ringController;
  late final AnimationController _floatController;
  late final AnimationController _progressController;
  late final AnimationController _dotsController;

  late final Animation<double> _pulse;
  late final Animation<double> _logoBob;

  // Rotating loading messages
  final List<String> _messages = const [
    "Warming up the trivia engine",
    "Picking the perfect quizzes for you",
    "Sharpening the questions",
    "Setting up the leaderboard",
    "Almost ready",
  ];
  int _messageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeOut);
    _logoBob = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Rotate messages every 1.6s
    _messageTimer =
        Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _pulseController.dispose();
    _ringController.dispose();
    _floatController.dispose();
    _progressController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Widget _bubble({
    required double size,
    required Color color,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        final offset = ((_floatController.value + delay) % 1.0) * 2 - 1;
        return Transform.translate(
          offset: Offset(0, offset * 8),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(
          children: [
            // ---- Decorative floating bubbles ----
            Positioned(
              top: 80,
              left: 40,
              child: _bubble(
                size: 10,
                color: kAccent.withOpacity(0.2),
                delay: 0.0,
              ),
            ),
            Positioned(
              top: 140,
              right: 50,
              child: _bubble(
                size: 6,
                color: kAccent.withOpacity(0.35),
                delay: 0.3,
              ),
            ),
            Positioned(
              top: 220,
              left: 70,
              child: _bubble(
                size: 8,
                color: kDark.withOpacity(0.15),
                delay: 0.6,
              ),
            ),
            Positioned(
              bottom: 180,
              right: 60,
              child: _bubble(
                size: 12,
                color: kAccent.withOpacity(0.18),
                delay: 0.8,
              ),
            ),
            Positioned(
              bottom: 260,
              left: 50,
              child: _bubble(
                size: 6,
                color: kDark.withOpacity(0.2),
                delay: 0.2,
              ),
            ),
            Positioned(
              top: 320,
              right: 80,
              child: _bubble(
                size: 5,
                color: kAccent.withOpacity(0.3),
                delay: 0.5,
              ),
            ),

            // ---- Main content ----
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ====== Logo with pulsing rings ======
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer pulse ring
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) {
                            return Container(
                              width: 130 + (_pulse.value * 60),
                              height: 130 + (_pulse.value * 60),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kAccent
                                    .withOpacity(0.08 * (1 - _pulse.value)),
                              ),
                            );
                          },
                        ),
                        // Middle pulse ring
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (context, _) {
                            return Container(
                              width: 100 + (_pulse.value * 40),
                              height: 100 + (_pulse.value * 40),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: kAccent
                                    .withOpacity(0.12 * (1 - _pulse.value)),
                              ),
                            );
                          },
                        ),
                        // Static soft disc
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kAccent.withOpacity(0.1),
                          ),
                        ),
                        // Rotating orbit ring (subtle)
                        AnimatedBuilder(
                          animation: _ringController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _ringController.value * 2 * 3.14159,
                              child: CustomPaint(
                                size: const Size(90, 90),
                                painter: _OrbitPainter(),
                              ),
                            );
                          },
                        ),
                        // Bouncing logo
                        AnimatedBuilder(
                          animation: _logoBob,
                          builder: (context, _) {
                            return Transform.translate(
                              offset: Offset(0, _logoBob.value),
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kAccent.withOpacity(0.5),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ====== Wordmark ======
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "QuizyyWilla",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: kDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        " 2.0",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: kAccent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ====== Status pill ======
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.bolt_rounded, size: 11, color: kAccent),
                        SizedBox(width: 4),
                        Text(
                          "PREPARING YOUR EXPERIENCE",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: kAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ====== Rotating message ======
                  SizedBox(
                    height: 24,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) {
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        key: ValueKey(_messageIndex),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _messages[_messageIndex],
                            style: const TextStyle(
                              fontSize: 13,
                              color: kDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(
                            width: 18,
                            child: AnimatedBuilder(
                              animation: _dotsController,
                              builder: (context, _) {
                                final count =
                                    ((_dotsController.value * 4).floor() % 4);
                                return Text(
                                  "." * count,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: kDark,
                                    fontWeight: FontWeight.w700,
                                    height: 1,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ====== Indeterminate progress bar ======
                  Container(
                    width: 220,
                    height: 6,
                    decoration: BoxDecoration(
                      color: kSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: const Size(220, 6),
                            painter: _ProgressBarPainter(
                              progress: _progressController.value,
                              color: kAccent,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ====== Tip line ======
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "💡 Tip: Save lifelines for the harder questions",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: kMuted.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Custom painters ----

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF7A3D).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw three arc segments around the circle
    for (int i = 0; i < 3; i++) {
      final startAngle = (i * 2 * 3.14159 / 3) - 1.5708;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        0.8, // arc length in radians
        false,
        paint,
      );
    }

    // Draw three small dots between arcs
    final dotPaint = Paint()
      ..color = const Color(0xFFFF7A3D)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = (i * 2 * 3.14159 / 3) - 1.5708 + 1.0;
      final dx = center.dx + radius * (math.cos(angle));
      final dy = center.dy + radius * (math.sin(angle));
      canvas.drawCircle(Offset(dx, dy), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) => false;
}

class _ProgressBarPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressBarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Animated traveling segment
    const segmentWidth = 80.0;
    final travelDistance = size.width + segmentWidth;
    final position = (progress * travelDistance) - segmentWidth;

    final rect = Rect.fromLTWH(position, 0, segmentWidth, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

