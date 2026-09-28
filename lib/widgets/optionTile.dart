import 'package:flutter/material.dart';

class optionTile extends StatefulWidget {
  final String optionText;
  final VoidCallback onTap;
  final bool isLocked;
  final bool showResult;
  final bool isDisabled;
  final String? selectedOption;
  final String correctAns;
  final int? optionIndex; // optional: 0,1,2,3 → A,B,C,D

  const optionTile({
    super.key,
    required this.correctAns,
    required this.isLocked,
    required this.onTap,
    required this.optionText,
    required this.selectedOption,
    required this.showResult,
    required this.isDisabled,
    this.optionIndex,
  });

  @override
  State<optionTile> createState() => _optionTileState();
}

class _optionTileState extends State<optionTile>
    with SingleTickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);
  static const Color kCorrect = Color(0xFF4CAF7C);
  static const Color kWrong = Color(0xFFE74C3C);

  late final AnimationController _shakeController;
  late final Animation<double> _shake;

  String? _lastReveal; // tracks if we already shook for current result

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _shake = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant optionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isSelected = widget.selectedOption == widget.optionText;
    final isCorrect = widget.optionText == widget.correctAns;
    // Shake when result reveals AND this tile is the wrong selection
    if (widget.showResult && isSelected && !isCorrect && _lastReveal != 'wrong') {
      _lastReveal = 'wrong';
      _shakeController.forward(from: 0);
    }
    if (!widget.showResult) _lastReveal = null;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String _letter(int? i) {
    if (i == null) return "•";
    const letters = ["A", "B", "C", "D"];
    if (i < 0 || i >= letters.length) return "•";
    return letters[i];
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedOption == widget.optionText;
    final isCorrect = widget.optionText == widget.correctAns;

    // --- Determine visual state ---
    Color bg = Colors.white;
    Color borderColor = kSoft;
    Color textColor = kDark;
    Color badgeBg = kSoft;
    Color badgeText = kDark;
    double borderWidth = 1.5;
    IconData? trailingIcon;
    Color? trailingIconColor;
    bool isStruckthrough = false;

    // Disabled (50/50)
    if (widget.isDisabled) {
      bg = Colors.white.withOpacity(0.5);
      borderColor = kSoft;
      textColor = kMuted.withOpacity(0.6);
      badgeBg = kSoft;
      badgeText = kMuted.withOpacity(0.7);
      isStruckthrough = true;
      trailingIcon = Icons.close_rounded;
      trailingIconColor = kMuted.withOpacity(0.6);
    }
    // Locked in, waiting for result
    else if (widget.isLocked && isSelected && !widget.showResult) {
      bg = kAccent.withOpacity(0.12);
      borderColor = kAccent;
      textColor = kDark;
      badgeBg = kAccent;
      badgeText = Colors.white;
      borderWidth = 2;
      trailingIcon = Icons.lock_rounded;
      trailingIconColor = kAccent;
    }
    // Result revealed
    else if (widget.showResult) {
      if (isCorrect) {
        bg = kCorrect.withOpacity(0.12);
        borderColor = kCorrect;
        textColor = kDark;
        badgeBg = kCorrect;
        badgeText = Colors.white;
        borderWidth = 2;
        trailingIcon = Icons.check_circle_rounded;
        trailingIconColor = kCorrect;
      } else if (isSelected) {
        bg = kWrong.withOpacity(0.1);
        borderColor = kWrong;
        textColor = kDark;
        badgeBg = kWrong;
        badgeText = Colors.white;
        borderWidth = 2;
        trailingIcon = Icons.cancel_rounded;
        trailingIconColor = kWrong;
      } else {
        // Untouched after reveal — fade slightly
        bg = Colors.white.withOpacity(0.6);
        textColor = kMuted;
        badgeBg = kSoft;
        badgeText = kMuted;
      }
    }

    final isInteractive = !widget.isLocked && !widget.isDisabled;

    // Shake offset only applies to the wrong selection on reveal
    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final shouldShake = widget.showResult &&
            isSelected &&
            !isCorrect &&
            _shake.value > 0 &&
            _shake.value < 1;
        final dx = shouldShake
            ? (4 * (_shake.value * 8 % 1 - 0.5) * 2)
            : 0.0;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: isInteractive ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: (borderWidth > 1.5)
                ? [
                    BoxShadow(
                      color: borderColor.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Leading letter badge (A/B/C/D)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  _letter(widget.optionIndex),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: badgeText,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Option text
              Expanded(
                child: Text(
                  widget.optionText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.3,
                    decoration: isStruckthrough
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: kMuted.withOpacity(0.6),
                    decorationThickness: 2,
                  ),
                ),
              ),
              // Trailing icon
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    trailingIcon,
                    key: ValueKey(trailingIcon),
                    size: 22,
                    color: trailingIconColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
