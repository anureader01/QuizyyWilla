import 'package:flutter/material.dart';

class ComingSoon extends StatefulWidget {
  const ComingSoon({super.key});

  @override
  State<ComingSoon> createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  late final AnimationController _floatController;
  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _float;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _float = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
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

  // Pulsing rings around the icon
  Widget _pulsingRings({required Widget child}) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              return Container(
                width: 140 + (_pulse.value * 50),
                height: 140 + (_pulse.value * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withOpacity(0.08 * (1 - _pulse.value)),
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
                  color: kAccent.withOpacity(0.12 * (1 - _pulse.value)),
                ),
              );
            },
          ),
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kAccent.withOpacity(0.1),
            ),
          ),
          child,
        ],
      ),
    );
  }

  // Floating decorative bubble
  Widget _bubble({
    required double size,
    required Color color,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, _) {
        // each bubble bobs with a phase offset
        final offset = ((_floatController.value + delay) % 1.0) * 2 - 1;
        return Transform.translate(
          offset: Offset(0, offset * 6),
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
    return Container(
      color: kBg,
      child: SafeArea(
        child: Stack(
          children: [
            // ---- Decorative floating bubbles ----
            Positioned(
              top: 60,
              left: 30,
              child: _bubble(
                size: 12,
                color: kAccent.withOpacity(0.2),
                delay: 0.0,
              ),
            ),
            Positioned(
              top: 120,
              right: 40,
              child: _bubble(
                size: 8,
                color: kAccent.withOpacity(0.3),
                delay: 0.3,
              ),
            ),
            Positioned(
              bottom: 160,
              left: 50,
              child: _bubble(
                size: 10,
                color: kDark.withOpacity(0.15),
                delay: 0.6,
              ),
            ),
            Positioned(
              bottom: 220,
              right: 30,
              child: _bubble(
                size: 14,
                color: kAccent.withOpacity(0.15),
                delay: 0.8,
              ),
            ),
            Positioned(
              top: 200,
              left: 60,
              child: _bubble(
                size: 6,
                color: kDark.withOpacity(0.2),
                delay: 0.2,
              ),
            ),

            // ---- Main content ----
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),

                      // ---- Animated icon with floating + rings ----
                      _animated(
                        AnimatedBuilder(
                          animation: _float,
                          builder: (context, _) {
                            return Transform.translate(
                              offset: Offset(0, _float.value),
                              child: _pulsingRings(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: kAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: kAccent.withOpacity(0.4),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.groups_rounded,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        delay: 0.0,
                      ),

                      const SizedBox(height: 28),

                      // ---- Status pill ----
                      _animated(
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.bolt_rounded,
                                  size: 13, color: kAccent),
                              SizedBox(width: 5),
                              Text(
                                "IN THE WORKS",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: kAccent,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        delay: 0.1,
                      ),

                      const SizedBox(height: 16),

                      // ---- Heading ----
                      _animated(
                        const Text(
                          "Coming Soon",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: kDark,
                            letterSpacing: 0.3,
                          ),
                        ),
                        delay: 0.15,
                      ),

                      const SizedBox(height: 10),

                      // ---- Subtitle ----
                      _animated(
                        Text(
                          "We're putting the finishing touches on something special.\nStay tuned!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: kMuted,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        delay: 0.2,
                      ),

                      const SizedBox(height: 32),

                      // ---- Feature preview cards ----
                      _animated(
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: kSoft, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "WHAT TO EXPECT",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: kMuted,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 14),
                              _featureRow(
                                Icons.group_add_rounded,
                                "Add friends",
                                "Connect with other players",
                              ),
                              const SizedBox(height: 12),
                              _featureRow(
                                Icons.leaderboard_rounded,
                                "Friend leaderboards",
                                "Compete with your circle",
                              ),
                              const SizedBox(height: 12),
                              _featureRow(
                                Icons.people,
                                "Friendly challenges",
                                "Challenge friends to quizzes",
                              ),
                            ],
                          ),
                        ),
                        delay: 0.25,
                      ),

                      const SizedBox(height: 20),

                      // ---- Notify me button ----
                      _animated(
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: const [
                                      Icon(Icons.notifications_active_rounded,
                                          color: kAccent, size: 18),
                                      SizedBox(width: 8),
                                      Text("We'll let you know when it's live"),
                                    ],
                                  ),
                                  backgroundColor: kDark,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.notifications_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  "Notify me",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        delay: 0.3,
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kAccent.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kAccent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: kMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
