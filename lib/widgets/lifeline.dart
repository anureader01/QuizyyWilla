import 'package:flutter/material.dart';
import 'package:quizbit_2/core/utils/lifelineEnum.dart';

Widget lifeline({
  required String title,
  required IconData icon,
  required BuildContext context,
  required LifeLineType type,
  required Function(LifeLineType) onLifeLineSelected,
  required Map<LifeLineType, bool> usedMap,
}) {
  return _LifelineButton(
    title: title,
    icon: icon,
    type: type,
    onLifeLineSelected: onLifeLineSelected,
    usedMap: usedMap,
    parentContext: context,
  );
}

class _LifelineButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final LifeLineType type;
  final Function(LifeLineType) onLifeLineSelected;
  final Map<LifeLineType, bool> usedMap;
  final BuildContext parentContext;

  const _LifelineButton({
    required this.title,
    required this.icon,
    required this.type,
    required this.onLifeLineSelected,
    required this.usedMap,
    required this.parentContext,
  });

  @override
  State<_LifelineButton> createState() => _LifelineButtonState();
}

class _LifelineButtonState extends State<_LifelineButton> {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final used = widget.usedMap[widget.type] ?? false;

    // ---- Visual state ----
    final Color iconBg;
    final Color iconColor;
    final Color textColor;
    final Color borderColor;
    final List<BoxShadow>? shadow;
    final IconData? overlayIcon;

    if (used) {
      iconBg = kSoft;
      iconColor = kMuted.withOpacity(0.6);
      textColor = kMuted.withOpacity(0.7);
      borderColor = kSoft;
      shadow = null;
      overlayIcon = Icons.check_rounded;
    } else {
      iconBg = Colors.white;
      iconColor = kAccent;
      textColor = kDark;
      borderColor = kAccent.withOpacity(0.5);
      shadow = [
        BoxShadow(
          color: kAccent.withOpacity(0.18),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
      overlayIcon = null;
    }

    return GestureDetector(
      onTapDown: used ? null : (_) => setState(() => _pressed = true),
      onTapUp: used ? null : (_) => setState(() => _pressed = false),
      onTapCancel: used ? null : () => setState(() => _pressed = false),
      onTap: used
          ? null
          : () {
              Navigator.pop(widget.parentContext);
              widget.onLifeLineSelected(widget.type);
            },
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ---- Icon circle ----
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1.8),
                    boxShadow: shadow,
                  ),
                  child: Icon(widget.icon, color: iconColor, size: 22),
                ),

                // "Used" check overlay
                if (overlayIcon != null)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: kMuted,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(overlayIcon,
                          size: 10, color: Colors.white),
                    ),
                  ),

                // Strikethrough line for used state
                if (used)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _StrikePainter(
                        color: kMuted.withOpacity(0.5),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // ---- Label ----
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1.2,
                letterSpacing: 0.2,
                decoration: used
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: kMuted.withOpacity(0.5),
                decorationThickness: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Diagonal strikethrough painter for the used icon ----
class _StrikePainter extends CustomPainter {
  final Color color;
  _StrikePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Diagonal line from bottom-left to top-right
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.82),
      Offset(size.width * 0.82, size.height * 0.18),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrikePainter oldDelegate) =>
      oldDelegate.color != color;
}
