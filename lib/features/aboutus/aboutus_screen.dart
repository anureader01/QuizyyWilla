import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
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
      duration: const Duration(milliseconds: 900),
    )..forward();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _animated(Widget child, {double delay = 0}) {
    final start = delay.clamp(0.0, 0.85);
    final end = (start + 0.4).clamp(0.0, 1.0);
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: kMuted,
        letterSpacing: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: kDark),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kSoft, width: 1.5),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: kDark, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "About",
          style: TextStyle(
            color: kDark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // HERO
                // ============================================
                _animated(_buildHero(), delay: 0.0),

                const SizedBox(height: 28),

                // ============================================
                // KEY METRICS
                // ============================================
                _animated(_buildMetrics(), delay: 0.1),

                const SizedBox(height: 28),

                // ============================================
                // OUR STORY
                // ============================================
                _animated(_sectionLabel("OUR STORY"), delay: 0.15),
                const SizedBox(height: 10),
                _animated(_buildStoryCard(), delay: 0.18),

                const SizedBox(height: 28),

                // ============================================
                // WHAT MAKES QuizyyWilla UNIQUE
                // ============================================
                _animated(_sectionLabel("WHAT MAKES IT UNIQUE"), delay: 0.22),
                const SizedBox(height: 10),
                _animated(_buildFeatureCard(
                  icon: Icons.psychology_alt_rounded,
                  title: "AI-Generated Questions",
                  description:
                      "Every question is dynamically created in real time using AI, so you never see the same question twice. The system also adapts difficulty as you climb the ladder.",
                ), delay: 0.25),
                const SizedBox(height: 10),
                _animated(_buildFeatureCard(
                  icon: Icons.shield_outlined,
                  title: "Smart Lifelines",
                  description:
                      "Use 50/50, AI hints, audience poll, or talk live to an AI voice expert. Each lifeline adds strategy — saving them for the right moment can change your game.",
                ), delay: 0.28),
                const SizedBox(height: 10),
                _animated(_buildFeatureCard(
                  icon: Icons.public_rounded,
                  title: "Global & Local Leaderboards",
                  description:
                      "Compete with players worldwide or just those near you. Geolocation-based rankings make local bragging rights as fun as global ones.",
                ), delay: 0.31),
                const SizedBox(height: 10),
                _animated(_buildFeatureCard(
                  icon: Icons.bolt_rounded,
                  title: "Prize Ladder Gameplay",
                  description:
                      "Inspired by classic TV quiz shows — climb the prize ladder one question at a time, with mounting suspense and increasing rewards.",
                ), delay: 0.34),

                const SizedBox(height: 28),

                // ============================================
                // CATEGORIES
                // ============================================
                // _animated(_sectionLabel("QUIZ CATEGORIES"), delay: 0.38),
                // const SizedBox(height: 10),
                // _animated(_buildCategoriesCard(), delay: 0.4),

                // const SizedBox(height: 28),

                // ============================================
                // BUILT WITH
                // ============================================
                _animated(_sectionLabel("BUILT WITH"), delay: 0.44),
                const SizedBox(height: 10),
                _animated(_buildTechStackCard(), delay: 0.46),

                const SizedBox(height: 28),

                // ============================================
                // CREATOR
                // ============================================
                _animated(_sectionLabel("MEET THE CREATOR"), delay: 0.5),
                const SizedBox(height: 10),
                _animated(_buildCreatorCard(), delay: 0.52),

                const SizedBox(height: 28),

                // ============================================
                // CLOSING CTA
                // ============================================
                _animated(_buildClosingCard(), delay: 0.58),

                const SizedBox(height: 20),

                // ============================================
                // VERSION FOOTER
                // ============================================
                _animated(
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: kSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "v1.0.0",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "© 2025 QuizyyWilla. All rights reserved.",
                          style: TextStyle(
                            fontSize: 11,
                            color: kMuted.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  delay: 0.6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative dots
          Positioned(
            top: 12,
            right: 16,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: kAccent.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 50,
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
            bottom: 20,
            left: 12,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: kAccent.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "QuizyyWilla",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    " 2.0",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: kAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        size: 12, color: kAccent),
                    SizedBox(width: 4),
                    Text(
                      "AI-POWERED QUIZ GAMING",
                      style: TextStyle(
                        color: kAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Where learning meets the thrill of the game",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // METRICS ROW
  // ============================================================
  Widget _buildMetrics() {
    return Row(
      children: [
        Expanded(child: _metricCard("∞", "AI Questions", Icons.psychology_alt_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _metricCard("4", "Lifelines", Icons.shield_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _metricCard("10+", "Categories", Icons.category_rounded)),
      ],
    );
  }

  Widget _metricCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kAccent, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              color: kMuted,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STORY CARD
  // ============================================================
  Widget _buildStoryCard() {
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: kAccent, size: 16),
              ),
              const SizedBox(width: 10),
              const Text(
                "More than a quiz app",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "QuizyyWilla is an interactive AI-powered quiz gaming platform that brings together learning, entertainment, and competition into one immersive experience. We blend classic quiz-show gameplay with modern technology — AI question generation, voice assistants, geolocation-based competition, and dynamic gamification — to create something genuinely new.",
            style: TextStyle(
              fontSize: 13.5,
              color: kDark,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Whether you're a casual player looking for a quick brain workout or a serious quiz enthusiast chasing the top of the leaderboard, QuizyyWilla adapts to you. Every question is fresh, every game feels different, and every win matters.",
            style: TextStyle(
              fontSize: 13.5,
              color: kDark,
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FEATURE CARD
  // ============================================================
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kAccent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: kMuted,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
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
  // CATEGORIES CARD
  // ============================================================
  Widget _buildCategoriesCard() {
    final categories = [
      "General Knowledge",
      "Science",
      "Technology",
      "History",
      "Geography",
      "Sports",
      "Movies",
      "Mathematics",
      "Coding",
      "Current Affairs",
    ];

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
          const Text(
            "Pick your battlefield",
            style: TextStyle(
              fontSize: 13,
              color: kMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categories.map((cat) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: kAccent.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tag_rounded, size: 11, color: kAccent),
                    const SizedBox(width: 3),
                    Text(
                      cat,
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TECH STACK CARD
  // ============================================================
  Widget _buildTechStackCard() {
    final techs = [
      ("Flutter", Icons.flutter_dash_rounded),
      ("Artificial Intelligence", Icons.psychology_rounded),
      ("Supabase", Icons.storage_rounded),
      ("Voice AI", Icons.mic_rounded),
    ];

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
          const Text(
            "The technology behind the magic",
            style: TextStyle(
              fontSize: 13,
              color: kMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ...techs.map((tech) {
            final isLast = tech == techs.last;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: kSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(tech.$2, size: 16, color: kDark),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    tech.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // CREATOR CARD
  // ============================================================
  Widget _buildCreatorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kAccent,
                  boxShadow: [
                    BoxShadow(
                      color: kAccent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundColor: kSoft,
                  child: Text(
                    "DA",
                    style: TextStyle(
                      color: kDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "BUILT BY",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "Shantanu Kumar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: kAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Developer · AI Enthusiast",
                        style: TextStyle(
                          color: kAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Bio
          Text(
            "Dhruv is a passionate software developer, AI enthusiast, and content creator focused on building intelligent digital products with Flutter, AI, Supabase, and Voice AI systems.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            "Beyond development, he shares practical knowledge with the developer community through tutorials and real-world project guides, helping learners understand how modern scalable systems are built.",
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 16),

          // Vision pill
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: kAccent, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Bridging creativity, AI, and user-centered design",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Social links
          const Text(
            "CONNECT",
            style: TextStyle(
              fontSize: 10,
              color: Colors.white54,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _socialIcon(Icons.code_rounded, "GitHub", "https://github.com/anureader01"),
          
              const SizedBox(width: 8),
              _socialIcon(Icons.play_circle_fill_rounded, "YouTube", "https://github.com/anureader01"),
              const SizedBox(width: 8),
              _socialIcon(Icons.business_center_rounded, "LinkedIn", "https://in.linkedin.com/in/dhananjayarne"),
              const SizedBox(width: 8),
              _socialIcon(Icons.mail_outline_rounded, "Email" ,"http://emailto:anu.reader01@gmail.com/"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialIcon(IconData icon, String tooltip, String url) {
    return Expanded(
      child: GestureDetector(
        onTap: () async{
           await  launchUrl(Uri.parse(url));
        },
        child: Tooltip(
          message: tooltip,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CLOSING CTA
  // ============================================================
  Widget _buildClosingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kAccent.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kAccent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          const Text(
            "Thanks for playing",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: kDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "QuizyyWilla is built with care to make every game feel new. Got feedback or ideas? We'd love to hear them.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: kMuted,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

