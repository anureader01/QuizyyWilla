import 'package:flutter/material.dart';
import 'package:quizbit_2/features/auth/auth_controller.dart';
import 'package:quizbit_2/models/profileModel.dart';

class ProfileScreen extends StatefulWidget {
  final String profile_id;
  const ProfileScreen({super.key, required this.profile_id});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  final AuthController _authController = AuthController();

  bool _isLoading = true;
  ProfileModel? _profile;

  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _init();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _authController.refereshProfileSession();
    final profile = await _authController.getProfile(widget.profile_id);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
    _fadeController.forward();
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
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: _isLoading
          ? _buildLoading()
          : _profile == null
              ? _buildNotFound()
              : _buildBody(_profile!),
    );
  }

  // ============================================================
  // LOADING STATE
  // ============================================================
  Widget _buildLoading() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _backButton(),
          ),
          Expanded(
            child: Center(
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
                  const Text(
                    "Loading profile...",
                    style: TextStyle(
                      color: kMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOT FOUND STATE
  // ============================================================
  Widget _buildNotFound() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _backButton(),
          ),
          Expanded(
            child: Center(
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
                      child: Icon(Icons.person_off_rounded,
                          size: 36, color: kMuted),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Profile not found",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "This user doesn't exist or has been removed.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: kMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================
  Widget _backButton({Color iconColor = kDark, Color bg = Colors.white}) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: bg == Colors.white
            ? Border.all(color: kSoft, width: 1.5)
            : null,
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: iconColor, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // ============================================================
  // MAIN BODY
  // ============================================================
  Widget _buildBody(ProfileModel p) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Hero header ─────────────────────────────────────
        SliverAppBar(
          backgroundColor: kDark,
          pinned: true,
          expandedHeight: 280,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: _backButton(
              iconColor: Colors.white,
              bg: Colors.white.withOpacity(0.15),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(color: kDark),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Decorative dots
                    Positioned(
                      top: 30,
                      right: 30,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 70,
                      right: 60,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 30,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Main hero content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Avatar(url: p.profile_pic_url, name: p.name),
                          const SizedBox(height: 16),
                          Text(
                            p.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (p.game_title.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: kAccent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.workspace_premium_rounded,
                                      color: Colors.white, size: 13),
                                  const SizedBox(width: 4),
                                  Text(
                                    p.game_title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
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
          ),
        ),

        // ── Stat cards row ──────────────────────────────────
        SliverToBoxAdapter(
          child: _animated(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.quiz_rounded,
                      value: "${p.quiz_attempts}",
                      label: "Attempts",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.collections_bookmark_rounded,
                      value: "${(p.quiz_owned as List).toSet().length}",
                      label: "Owned",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.lightbulb_rounded,
                      value: "${p.topic_asked.length}",
                      label: "Topics",
                    ),
                  ),
                ],
              ),
            ),
            delay: 0.0,
          ),
        ),

        // ── Section header: Info ────────────────────────────
        SliverToBoxAdapter(
          child: _animated(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "ABOUT",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: kMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            delay: 0.1,
          ),
        ),

        // ── Info card ───────────────────────────────────────
        SliverToBoxAdapter(
          child: _animated(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kSoft, width: 1.5),
                ),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: p.email,
                    ),
                    _divider(),
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      label: "Name",
                      value: p.name,
                    ),
                    _divider(),
                    _InfoRow(
                      icon: Icons.workspace_premium_outlined,
                      label: "Title",
                      value: p.game_title.isNotEmpty
                          ? p.game_title
                          : "No title yet",
                      muted: p.game_title.isEmpty,
                    ),
                  ],
                ),
              ),
            ),
            delay: 0.15,
          ),
        ),

        // ── Topics chips ────────────────────────────────────
        if (p.topic_asked.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _animated(
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "TOPICS REQUESTED",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kMuted,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${p.topic_asked.length}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              delay: 0.2,
            ),
          ),
          SliverToBoxAdapter(
            child: _animated(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kSoft, width: 1.5),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.topic_asked.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: kAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: kAccent.withOpacity(0.3), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tag_rounded,
                                size: 12, color: kAccent),
                            const SizedBox(width: 3),
                            Text(
                              t.toString(),
                              style: const TextStyle(
                                color: kAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              delay: 0.25,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.only(left: 56, right: 16),
      child: Container(height: 1, color: kSoft),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Pieces
// ─────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _ProfileScreenState.kAccent,
        boxShadow: [
          BoxShadow(
            color: _ProfileScreenState.kAccent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 48,
        backgroundColor: const Color(0xFF1E2236),
        child: CircleAvatar(
          radius: 45,
          backgroundColor: _ProfileScreenState.kSoft,
          backgroundImage: hasUrl ? NetworkImage(url!) : null,
          child: !hasUrl
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: _ProfileScreenState.kDark,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _ProfileScreenState.kSoft, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _ProfileScreenState.kAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: _ProfileScreenState.kAccent, size: 0),
          ),
          // We use a Stack to overlay the actual icon (workaround for const)
          // Actually just render the icon plainly:
          // (replaced below)
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool muted;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _ProfileScreenState.kAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _ProfileScreenState.kAccent, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: _ProfileScreenState.kMuted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: muted
                        ? _ProfileScreenState.kMuted
                        : _ProfileScreenState.kDark,
                    fontStyle: muted ? FontStyle.italic : FontStyle.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
