import 'package:flutter/material.dart';
import 'package:quizbit_2/core/services/locController.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/features/leaderboard/leaderboard_controller.dart';
import 'package:quizbit_2/models/profileModel.dart';
import 'package:quizbit_2/widgets/comingSoonScreen.dart';
import 'package:quizbit_2/widgets/leaderRow.dart';

// --- Shared palette ---
const Color kDark = Color(0xFF1E2236);
const Color kAccent = Color(0xFFFF7A3D);
const Color kBg = Color(0xFFFAF7F2);
const Color kSoft = Color(0xFFEFEAE2);
const Color kMuted = Color(0xFF8A8A95);

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final controller = LeaderboardController();
  late final TabController _tabController;

  double? lat;
  double? lng;

  final ScrollController _globalScrolLController = ScrollController();
  final ScrollController _localScrollCotroller = ScrollController();

  bool _globalLoading = true;
  bool _localLoading = true;

  Future<void> loadMore() async {
    await controller.loadMore();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> loadMoreLocal() async {
    if (lat == null || lng == null) return;
    await controller.loadLocal(lat: lat!, lng: lng!);
    if (!mounted) return;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    initData();
    initLocalLeaderboard();

    _globalScrolLController.addListener(() {
      if (_globalScrolLController.position.pixels >=
          _globalScrolLController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });

    _localScrollCotroller.addListener(() {
      if (_localScrollCotroller.position.pixels >=
          _localScrollCotroller.position.maxScrollExtent - 200) {
        loadMoreLocal();
      }
    });
  }

  Future<void> initData() async {
    await controller.init();
    if (!mounted) return;
    setState(() => _globalLoading = false);
  }

  Future<void> initLocalLeaderboard() async {
    try {
      final location = await LocationController().getCurrentUserLocation();
      lat = location?.latitude;
      lng = location?.longitude;
      if (lat != null && lng != null) {
        await controller.loadLocal(lat: lat!, lng: lng!);
        await controller.loadTop3Local(lat: lat!, lng: lng!);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _localLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _globalScrolLController.dispose();
    _localScrollCotroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: kDark),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              "Leaderboard",
              style: TextStyle(
                color: kDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kSoft, width: 1.5),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: kMuted,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
                tabs: const [
                  Tab(text: "Global"),
                  Tab(text: "Local"),
                  Tab(text: "Friends"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildLeaderBoardTab(
              users: controller.users,
              top3: controller.top3,
              scrollController: _globalScrolLController,
              isLoading: _globalLoading,
              emptyText: "Loading global leaderboard...",
            ),
            _buildLeaderBoardTab(
              users: controller.localUsers,
              top3: controller.top3Local,
              scrollController: _localScrollCotroller,
              isLoading: _localLoading,
              emptyText: "Loading local leaderboard...",
            ),
            const ComingSoon(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LEADERBOARD TAB
// ============================================================
Widget _buildLeaderBoardTab({
  required List<ProfileModel> users,
  required List top3,
  required ScrollController scrollController,
  required bool isLoading,
  required String emptyText,
}) {
  if (isLoading && top3.length < 3) {
    return _loadingState(emptyText);
  }
  if (top3.length < 3) {
    return _emptyState();
  }

  return Column(
    children: [
      const SizedBox(height: 12),
      _podiumSection(top3),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "ALL PLAYERS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: kMuted,
                letterSpacing: 1.5,
              ),
            ),
            if (users.isNotEmpty)
              Text(
                "${users.length + 3} total",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kAccent,
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      Expanded(
        child: users.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    "Be the first to climb past the top 3!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kMuted, fontSize: 13),
                  ),
                ),
              )
            : ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                physics: const BouncingScrollPhysics(),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 250 + (index * 40)),
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
                    child: leaderRow(
                      profileUrl: user.profile_pic_url,
                      rank: (index + 4).toString(),
                      name: user.name,
                      amount: "Rs. ${user.money}",
                      title: user.game_title,
                    ),
                  );
                },
              ),
      ),
    ],
  );
}

// ============================================================
// LOADING STATE
// ============================================================
Widget _loadingState(String message) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kAccent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: kAccent,
              strokeWidth: 2.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(
            color: kMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// EMPTY STATE
// ============================================================
Widget _emptyState() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_outlined,
                size: 36, color: kMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            "No champions yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Be the first to top the leaderboard",
            style: TextStyle(color: kMuted, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// PODIUM SECTION
// ============================================================
Widget _podiumSection(List top3) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kSoft, width: 1.5),
    ),
    child: Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Top 3 Champions",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kDark,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt_rounded, size: 12, color: kAccent),
                  SizedBox(width: 3),
                  Text(
                    "LIVE",
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: kAccent,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Podium — IntrinsicHeight prevents overflow by sizing the row
        // to whichever column needs the most vertical space.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _podiumColumn(top3[1], 2, false)),
              Expanded(child: _podiumColumn(top3[0], 1, true)),
              Expanded(child: _podiumColumn(top3[2], 3, false)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// PODIUM COLUMN
// ============================================================
Widget _podiumColumn(dynamic profile, int rank, bool isFirst) {
  final pedestalHeight = isFirst ? 70.0 : (rank == 2 ? 48.0 : 36.0);
  final avatarSize = isFirst ? 54.0 : 42.0;
  final ringColor = isFirst ? kAccent : kSoft;
  final ringWidth = isFirst ? 3.0 : 2.0;
  final pedestalColor = isFirst ? kAccent : kSoft;
  final pedestalTextColor = isFirst ? Colors.white : kDark;
  final crown = isFirst ? "👑" : (rank == 2 ? "🥈" : "🥉");

  final hasTitle =
      profile.game_title != null && profile.game_title.toString().isNotEmpty;

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    mainAxisSize: MainAxisSize.min,
    children: [
      // Crown slot — fixed height so all three columns align
      SizedBox(
        height: 26,
        child: isFirst
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (context, value, _) {
                  return Transform.scale(
                    scale: value,
                    child: const Text("👑",
                        style: TextStyle(fontSize: 22)),
                  );
                },
              )
            : null,
      ),

      // Avatar with ring + rank badge
      Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.all(ringWidth),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ringColor,
              boxShadow: isFirst
                  ? [
                      BoxShadow(
                        color: kAccent.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: CircleAvatar(
              radius: avatarSize / 2,
              backgroundColor: kBg,
              backgroundImage:
                  (profile.profile_pic_url != null &&
                          profile.profile_pic_url.isNotEmpty)
                      ? NetworkImage(profile.profile_pic_url)
                      : null,
              child: (profile.profile_pic_url == null ||
                      profile.profile_pic_url.isEmpty)
                  ? Text(
                      profile.name.isNotEmpty
                          ? profile.name[0].toUpperCase()
                          : "?",
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: kDark,
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: -4,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isFirst ? kDark : kAccent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  "#$rank",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      const SizedBox(height: 10),

      // Name
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          profile.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: kDark,
          ),
        ),
      ),
      const SizedBox(height: 2),

      // Prize
      Text(
        "₹${profile.money}",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isFirst ? 13 : 11,
          fontWeight: FontWeight.w900,
          color: isFirst ? kAccent : kDark,
        ),
      ),

      // Game title slot — fixed height so columns align
      SizedBox(
        height: 14,
        child: hasTitle
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  profile.game_title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontStyle: FontStyle.italic,
                    color: kMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : null,
      ),

      const SizedBox(height: 6),

      // Pedestal — grows from zero
      TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 600 + (rank * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: double.infinity,
            height: pedestalHeight * value,
            decoration: BoxDecoration(
              color: pedestalColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              
              boxShadow: isFirst
                  ? [
                      BoxShadow(
                        color: kAccent.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: value > 0.8
                ? Text(
                    crown,
                    style: TextStyle(
                      fontSize: isFirst ? 22 : 16,
                      color: pedestalTextColor,
                    ),
                  )
                : null,
          );
        },
      ),
    ],
  );
}
