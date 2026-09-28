import 'package:flutter/material.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/core/utils/lifelineEnum.dart';
import 'package:quizbit_2/core/utils/prize_ladder.dart';
import 'package:quizbit_2/models/quizModel.dart';
import 'package:quizbit_2/widgets/lifeline.dart';
import 'package:quizbit_2/widgets/prizeTile.dart';

class QuizDrawer extends StatelessWidget {
  final QuizModel quizModel;
  final int que_money;
  final Function(LifeLineType) onLifeLineSelected;
  final Map<LifeLineType, bool> usedMap;
  final BuildContext context;

  const QuizDrawer({
    super.key,
    required this.onLifeLineSelected,
    required this.usedMap,
    required this.context,
    required this.quizModel,
    required this.que_money,
  });

  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  @override
  Widget build(BuildContext context) {
    final totalQuestions =
        (quizModel.top_prize / quizModel.base_prize).toInt();
    final prizes = generatePrizeLadder(
      baseAmount: quizModel.base_prize.toInt(),
      greed_factor: quizModel.greed_factor,
      total_question: totalQuestions,
    );

    final lifelinesUsed = usedMap.values.where((v) => v).length;
    final lifelinesTotal = usedMap.length;

    final profileName = ProfileSession.profile?.name ?? "Player";
    final profilePic = ProfileSession.profile?.profile_pic_url;
    

    // Find current rung index for progress
    final currentIndex = prizes.indexOf(que_money);
    final progress = currentIndex >= 0
        ? (currentIndex + 1) / prizes.length
        : 0.0;

    return Drawer(
      backgroundColor: kBg,
      width: 320,
      child: SafeArea(
        child: Column(
          children: [
            // ====== Header: player + quiz title ======
            _header(profileName, profilePic),

            const SizedBox(height: 20),

            // ====== Lifelines section ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("LIFELINES",
                      trailing: "$lifelinesUsed/$lifelinesTotal used"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kSoft, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        lifeline(
                          title: "Audience\nPoll",
                          icon: Icons.people,
                          context: context,
                          onLifeLineSelected: onLifeLineSelected,
                          type: LifeLineType.audiencePoll,
                          usedMap: usedMap,
                        ),
                        lifeline(
                          title: "Question\nHint",
                          icon: Icons.keyboard_double_arrow_right_rounded,
                          context: context,
                          onLifeLineSelected: onLifeLineSelected,
                          type: LifeLineType.queHint,
                          usedMap: usedMap,
                        ),
                        lifeline(
                          title: "Ask The\nExpert",
                          icon: Icons.emoji_people_rounded,
                          context: context,
                          onLifeLineSelected: onLifeLineSelected,
                          type: LifeLineType.expertAdvice,
                          usedMap: usedMap,
                        ),
                        lifeline(
                          title: "50-50\nFiftyFifty",
                          icon: Icons.data_object_outlined,
                          context: context,
                          onLifeLineSelected: onLifeLineSelected,
                          type: LifeLineType.fiftyFifty,
                          usedMap: usedMap,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ====== Progress card ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _progressCard(prizes, currentIndex, progress),
            ),

            const SizedBox(height: 20),

            // ====== Prize ladder (top = highest) ======
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _sectionLabel("PRIZE LADDER",
                  trailing: "${prizes.length} levels"),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kSoft, width: 1.5),
                ),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  physics: const BouncingScrollPhysics(),
                  itemCount: prizes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, index) {
                    // Reverse order — highest at top
                    final reverseIndex = prizes.length - 1 - index;
                    final prize = prizes[reverseIndex];
                    final isActive = prize == que_money;
                    final isPassed = currentIndex >= 0 &&
                        reverseIndex < currentIndex;
                    final levelNumber = reverseIndex + 1;
                    return _prizeRow(
                      level: levelNumber,
                      amount: prize,
                      isActive: isActive,
                      isPassed: isPassed,
                      isTop: reverseIndex == prizes.length - 1,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _header(String name, String? profilePic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: kDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: kAccent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: kSoft,
                  backgroundImage:
                      (profilePic != null && profilePic.isNotEmpty)
                          ? NetworkImage(profilePic)
                          : null,
                  child: (profilePic == null || profilePic.isEmpty)
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: kDark,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PLAYING",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.55),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Current winnings pill
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: kAccent, size: 18),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "CURRENT PRIZE",
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.55),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹$que_money",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white24, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION LABEL
  // ============================================================
  Widget _sectionLabel(String label, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: kMuted,
            letterSpacing: 1.5,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kAccent,
              letterSpacing: 0.3,
            ),
          ),
      ],
    );
  }

  // ============================================================
  // PROGRESS CARD
  // ============================================================
  Widget _progressCard(List<dynamic> prizes, int currentIndex, double progress) {
    final levelText = currentIndex >= 0
        ? "Level ${currentIndex + 1} of ${prizes.length}"
        : "Starting out";
    final topPrize = prizes.isNotEmpty ? prizes.last : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kSoft, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                levelText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: kSoft,
                  valueColor: const AlwaysStoppedAnimation<Color>(kAccent),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.flag_outlined, size: 13, color: kMuted),
              const SizedBox(width: 4),
              Text(
                "Top prize: ",
                style: TextStyle(fontSize: 11, color: kMuted),
              ),
              Text(
                "₹$topPrize",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIZE ROW
  // ============================================================
  Widget _prizeRow({
    required int level,
    required dynamic amount,
    required bool isActive,
    required bool isPassed,
    required bool isTop,
  }) {
    Color bg = Colors.transparent;
    Color textColor = kDark;
    Color levelBg = kSoft;
    Color levelText = kDark;
    FontWeight weight = FontWeight.w700;

    if (isActive) {
      bg = kAccent;
      textColor = Colors.white;
      levelBg = Colors.white.withOpacity(0.25);
      levelText = Colors.white;
      weight = FontWeight.w900;
    } else if (isPassed) {
      textColor = kMuted.withOpacity(0.7);
      levelBg = kSoft;
      levelText = kMuted;
      weight = FontWeight.w500;
    } else if (isTop) {
      textColor = kDark;
      levelBg = kAccent.withOpacity(0.15);
      levelText = kAccent;
      weight = FontWeight.w900;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: kAccent.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Level chip
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: levelBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "$level",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: levelText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Amount
          Expanded(
            child: Text(
              "₹$amount",
              style: TextStyle(
                fontSize: 15,
                fontWeight: weight,
                color: textColor,
                decoration: isPassed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: kMuted.withOpacity(0.4),
              ),
            ),
          ),
          // Trailing indicator
          if (isActive)
            const Icon(Icons.arrow_back_rounded,
                size: 16, color: Colors.white)
          else if (isPassed)
            Icon(Icons.check_rounded,
                size: 14, color: kMuted.withOpacity(0.6))
          else if (isTop)
            const Icon(Icons.emoji_events_rounded,
                size: 16, color: kAccent),
        ],
      ),
    );
  }
}
