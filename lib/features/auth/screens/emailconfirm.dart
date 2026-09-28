import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmailConfirmScreen extends StatefulWidget {
  final String? email;
  const EmailConfirmScreen({super.key, this.email});

  @override
  State<EmailConfirmScreen> createState() => _EmailConfirmScreenState();
}

class _EmailConfirmScreenState extends State<EmailConfirmScreen>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

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
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _pulse = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ---- Mask email for privacy display ----
  String _maskedEmail() {
    final raw = (widget.email ?? "").trim();
    if (raw.isEmpty || !raw.contains('@')) return "your inbox";
    final parts = raw.split('@');
    final local = parts[0];
    final domain = parts[1];
    if (local.length <= 2) return "${local[0]}***@$domain";
    final visible = local.substring(0, 2);
    final tail = local.length > 4
        ? local.substring(local.length - 2)
        : "";
    return "$visible***$tail@$domain";
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

  // ---- Pulsing rings around the lottie ----
  Widget _pulsingRings({required Widget child}) {
    return SizedBox(
      width: 240,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              return Container(
                width: 180 + (_pulse.value * 50),
                height: 180 + (_pulse.value * 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withOpacity(0.08 * (1 - _pulse.value)),
                ),
              );
            },
          ),
          // Inner ring
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              return Container(
                width: 140 + (_pulse.value * 30),
                height: 140 + (_pulse.value * 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent.withOpacity(0.12 * (1 - _pulse.value)),
                ),
              );
            },
          ),
          // Static soft backdrop
          Container(
            width: 140,
            height: 140,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ---- Brand wordmark (compact) ----
                _animated(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: kAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "QuizyyWilla",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: kDark,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const Text(
                        " 2.0",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: kAccent,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  delay: 0.0,
                ),

                const SizedBox(height: 40),

                // ---- Lottie + pulsing rings ----
                _animated(
                  _pulsingRings(
                    child: SizedBox(
                      height: 130,
                      width: 130,
                      child: Lottie.asset(
                        "assets/animation/EmailSent.json",
                        repeat: true,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            color: kAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                      ),
                    ),
                  ),
                  delay: 0.1,
                ),

                const SizedBox(height: 32),

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
                        Icon(Icons.check_circle_rounded,
                            size: 14, color: kAccent),
                        SizedBox(width: 6),
                        Text(
                          "EMAIL SENT",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kAccent,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  delay: 0.2,
                ),

                const SizedBox(height: 20),

                // ---- Headline ----
                _animated(
                  const Text(
                    "Check your inbox",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kDark,
                      letterSpacing: 0.2,
                    ),
                  ),
                  delay: 0.25,
                ),

                const SizedBox(height: 12),

                // ---- Body with masked email ----
                _animated(
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: kMuted,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(
                            text: "We've sent a confirmation link to\n"),
                        TextSpan(
                          text: _maskedEmail(),
                          style: const TextStyle(
                            color: kDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  delay: 0.3,
                ),

                const SizedBox(height: 28),

                // ---- Info card with steps ----
                _animated(
                  Container(
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
                        const Text(
                          "WHAT'S NEXT",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _stepRow(1, "Open your email app"),
                        const SizedBox(height: 10),
                        _stepRow(2, "Click the confirmation link"),
                        const SizedBox(height: 10),
                        _stepRow(3, "Return here to sign in"),
                      ],
                    ),
                  ),
                  delay: 0.35,
                ),

                const SizedBox(height: 24),

                // ---- Primary CTA ----
                _animated(
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // hook into mail launcher or just pop back
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.mark_email_read_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Open Email App",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  delay: 0.4,
                ),

                const SizedBox(height: 14),

                // ---- Resend link ----
                _animated(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive it? ",
                        style: TextStyle(
                          fontSize: 13,
                          color: kMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // hook for resend logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Resending email..."),
                              backgroundColor: kDark,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text(
                          "Resend",
                          style: TextStyle(
                            fontSize: 13,
                            color: kAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  delay: 0.45,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepRow(int number, String label) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: kAccent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            "$number",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kAccent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: kDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

