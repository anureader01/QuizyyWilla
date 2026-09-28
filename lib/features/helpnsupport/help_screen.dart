import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  /// Map of FAQ questions to answers.
  /// Pass your own map, or leave null to use the default starter set.
  final Map<String, String>? faqs;

  /// Optional support email shown on the contact card.
  final String supportEmail;

  const HelpSupportScreen({
    super.key,
    this.faqs,
    this.supportEmail = "anu.reader01@gmail.com",
  });

  // Default FAQ if no map is passed
  static const Map<String, String> _defaultFaqs = {
    "How do I start a quiz?":
        "From the home screen, tap any quiz card or use the carousel at the top. You'll see the quiz details and an entry fee — tap 'Ready to Play' to begin. Make sure you have enough balance in your wallet to cover the entry fee.",
    "How do lifelines work?":
        "You get four lifelines per quiz: 50/50 (removes two wrong options), Audience Poll (shows simulated audience voting), Question Hint (AI-generated clue), and Ask the Expert (live voice call). Each lifeline can only be used once per quiz, so use them wisely on harder questions.",
    "How is my prize calculated?":
        "Every question multiplies your winnings by the quiz's greed factor. If you answer wrong, you walk away with your last confirmed prize divided by the greed factor. Top out the ladder to win the maximum prize for that quiz.",
    "Can I get extra time on a question?":
        "Yes! Tap the '+10 Sec' button to watch a short ad and get 10 extra seconds added to your timer. This is available even after time is paused, and you can use it as many times as ads are available.",
    "How do I withdraw my winnings?":
        "Your winnings are added to your wallet at the end of each quiz. Go to the wallet section from the side menu to view your balance and request withdrawal. Withdrawals typically process within 2–3 business days.",
    "I forgot my password. What do I do?":
        "On the login screen, tap 'Forgot password?' and enter the email you signed up with. We'll send you a 6-digit OTP. Enter it, then create a new password. You'll be back in the game in under a minute.",
    "How do I suggest a new quiz topic?":
        "On the home screen, scroll down to the 'Suggest a Quiz' card and enter your topic idea. We review every suggestion, and if it fits, we'll generate a quiz for it and add it to the catalog.",
    "What happens if I lose internet during a quiz?":
        "Your timer pauses automatically if connection drops. Reconnect within 60 seconds and you can continue where you left off. If you stay disconnected longer, the quiz ends and any locked-in winnings are credited to your wallet.",
  };

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  final TextEditingController _searchCtrl = TextEditingController();
  late final AnimationController _fadeController;

  // Tracks which questions are expanded
  final Set<int> _expanded = {};
  String _searchQuery = "";

  Map<String, String> get _faqs =>
      widget.faqs ?? HelpSupportScreen._defaultFaqs;

  List<MapEntry<String, String>> get _filteredFaqs {
    final entries = _faqs.entries.toList();
    if (_searchQuery.isEmpty) return entries;
    final q = _searchQuery.toLowerCase();
    return entries
        .where((e) =>
            e.key.toLowerCase().contains(q) ||
            e.value.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
        position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  void _showContactSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Get in touch",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Pick a channel — we'll get back within 24 hours.",
              style: TextStyle(fontSize: 12, color: kMuted),
            ),
            const SizedBox(height: 20),
            _contactOption(
              icon: Icons.email_outlined,
              title: "Email",
              subtitle: widget.supportEmail,
              onTap: () async{
               await launchUrl(Uri.parse("emailto:anu.reader01@gmail.com"));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Opening email to ${widget.supportEmail}"),
                    backgroundColor: kDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            // const SizedBox(height: 10),
            // _contactOption(
            //   icon: Icons.chat_bubble_outline_rounded,
            //   title: "Live chat",
            //   subtitle: "Mon-Fri, 9 AM - 6 PM IST",
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            // const SizedBox(height: 10),
            // _contactOption(
            //   icon: Icons.bug_report_outlined,
            //   title: "Report a bug",
            //   subtitle: "Help us improve QuizyyWilla",
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _contactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kSoft, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                    const SizedBox(height: 2),
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
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: kMuted.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFaqs;

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
          "Help & Support",
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Hero ----
                _animated(
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kDark,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: kAccent,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: kAccent.withOpacity(0.4),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.help_outline_rounded,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "How can we help?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Search the FAQ or reach out to us",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  delay: 0.0,
                ),

                const SizedBox(height: 16),

                // ---- Search bar ----
                _animated(
                  TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(
                      fontSize: 14,
                      color: kDark,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search FAQs...",
                      hintStyle: TextStyle(
                        color: kMuted.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 14, right: 10),
                        child: Icon(Icons.search_rounded,
                            color: kAccent, size: 20),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 0, minHeight: 0),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: kMuted, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: kSoft, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: kSoft, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: kAccent, width: 1.5),
                      ),
                    ),
                  ),
                  delay: 0.1,
                ),

                const SizedBox(height: 20),

                // ---- FAQ section header ----
                _animated(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "FREQUENTLY ASKED",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "${filtered.length} ${filtered.length == 1 ? 'result' : 'results'}",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kAccent,
                        ),
                      ),
                    ],
                  ),
                  delay: 0.15,
                ),

                const SizedBox(height: 10),

                // ---- FAQ list ----
                if (filtered.isEmpty)
                  _animated(_noResultsState(), delay: 0.2)
                else
                  ...List.generate(filtered.length, (index) {
                    final entry = filtered[index];
                    final isExpanded = _expanded.contains(index);
                    return _animated(
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _faqCard(
                          question: entry.key,
                          answer: entry.value,
                          isExpanded: isExpanded,
                          onTap: () {
                            setState(() {
                              if (isExpanded) {
                                _expanded.remove(index);
                              } else {
                                _expanded.add(index);
                              }
                            });
                          },
                        ),
                      ),
                      delay: 0.2 + (index * 0.02),
                    );
                  }),

                const SizedBox(height: 24),

                // ---- Still need help section ----
                _animated(
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kSoft, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.support_agent_rounded,
                              color: kAccent, size: 22),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Still need help?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Our team usually responds within 24 hours.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: kMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _showContactSheet,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded,
                                    size: 16),
                                SizedBox(width: 8),
                                Text(
                                  "Contact us",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  delay: 0.3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FAQ CARD
  // ============================================================
  Widget _faqCard({
    required String question,
    required String answer,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isExpanded ? kAccent.withOpacity(0.5) : kSoft,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.help_outline_rounded,
                        color: kAccent, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kDark,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? kAccent.withOpacity(0.12)
                            : kSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: isExpanded ? kAccent : kMuted,
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 1, color: kSoft),
                      const SizedBox(height: 12),
                      Text(
                        answer,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kDark,
                          fontWeight: FontWeight.w500,
                          height: 1.55,
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
    );
  }

  // ============================================================
  // NO RESULTS STATE
  // ============================================================
  Widget _noResultsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded,
                size: 28, color: kMuted.withOpacity(0.8)),
          ),
          const SizedBox(height: 14),
          const Text(
            "No matches found",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: kDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Try a different keyword or contact us directly",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: kMuted.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

