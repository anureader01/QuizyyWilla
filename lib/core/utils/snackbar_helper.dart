import 'package:flutter/material.dart';

class SnackbarHelper {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kSuccess = Color(0xFF4CAF7C);
  static const Color kError = Color(0xFFE74C3C);
  static const Color kInfo = Color(0xFF3B82F6);

  /// Shared snackbar builder so all three variants stay consistent.
  static SnackBar _buildSnackbar({
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    return SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
      content: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kDark,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: kDark.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Accent strip on the left for quick visual recognition
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            // Icon in a colored disc
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            // Message
            Expanded(
              child: Text(
                message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Safely show a snackbar — clears any existing one to avoid stacking.
  static void _show(BuildContext context, SnackBar snackbar) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackbar);
  }

  // ---- Public API (same signatures as before) ----

  static void showSucess(BuildContext context, String message) {
    _show(
      context,
      _buildSnackbar(
        message: message,
        icon: Icons.check_circle_rounded,
        accentColor: kSuccess,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    _show(
      context,
      _buildSnackbar(
        message: message,
        icon: Icons.error_rounded,
        accentColor: kError,
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    _show(
      context,
      _buildSnackbar(
        message: message,
        icon: Icons.info_rounded,
        accentColor: kInfo,
      ),
    );
  }

  /// Bonus: themed snackbar in the app's accent color, useful for game events
  /// like "+10 seconds added" or "Lifeline used". Not a breaking change.
  static void showAccent(BuildContext context, String message) {
    _show(
      context,
      _buildSnackbar(
        message: message,
        icon: Icons.bolt_rounded,
        accentColor: kAccent,
      ),
    );
  }
}
