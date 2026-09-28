import 'package:flutter/material.dart';
import 'package:quizbit_2/models/ratingCommentModel.dart';

class RatingDialog extends StatefulWidget {
  final RatingCommentmodel? existing;

  const RatingDialog({super.key, required this.existing});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatignDialogResult {
  final double rating;
  final String comment;
  _RatignDialogResult(this.rating, this.comment);
}

class _RatingDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  late int _rating;
  late TextEditingController _controller;

  // For the star pop animation
  int? _lastTappedStar;
  late AnimationController _popController;

  static const List<String> _labels = [
    "Tap a star to rate",
    "Poor",
    "Fair",
    "Good",
    "Great",
    "Excellent!",
  ];

  static const List<String> _emojis = [
    "⭐",
    "😕",
    "😐",
    "🙂",
    "😄",
    "🤩",
  ];

  @override
  void initState() {
    super.initState();
    _rating = widget.existing?.rating.round() ?? 0;
    _controller =
        TextEditingController(text: widget.existing?.comment ?? '');

    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _popController.dispose();
    super.dispose();
  }

  void _setRating(int value) {
    setState(() {
      _rating = value;
      _lastTappedStar = value - 1;
    });
    _popController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final remaining = 500 - _controller.text.length;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Header ----
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: kAccent, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEdit ? "Edit your review" : "Rate this quiz",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kDark,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: kSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: kDark),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ---- Animated rating label with emoji ----
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.2), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
                child: Column(
                  key: ValueKey(_rating),
                  children: [
                    Text(
                      _emojis[_rating],
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _labels[_rating],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _rating == 0 ? kMuted : kDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- Star row ----
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  final isLastTapped = _lastTappedStar == i;
                  return GestureDetector(
                    onTap: () => _setRating(i + 1),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedBuilder(
                      animation: _popController,
                      builder: (context, _) {
                        // pop only on most recently tapped star
                        final t = isLastTapped ? _popController.value : 0.0;
                        // simple ease: scale up then back down
                        final scale = 1.0 + (t < 0.5
                            ? t * 0.6
                            : (1 - t) * 0.6);
                        return Transform.scale(
                          scale: scale,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                filled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                key: ValueKey(filled),
                                size: 38,
                                color: filled
                                    ? kAccent
                                    : kMuted.withOpacity(0.4),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 22),

              // ---- Comment field ----
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  "YOUR THOUGHTS",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: kMuted,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              TextField(
                controller: _controller,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: kDark,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: "Share what you liked or didn't (optional)",
                  hintStyle: TextStyle(
                    color: kMuted.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: kBg,
                  contentPadding: const EdgeInsets.all(14),
                  counterText: "", // hide default counter
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kSoft, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kSoft, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kAccent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Custom char counter aligned right
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.edit_note_rounded,
                        size: 12, color: kMuted.withOpacity(0.7)),
                    const SizedBox(width: 3),
                    Text(
                      "$remaining left",
                      style: TextStyle(
                        fontSize: 10,
                        color: remaining < 50
                            ? kAccent
                            : kMuted.withOpacity(0.85),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ---- Action buttons ----
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: kDark,
                        backgroundColor: kSoft,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccent,
                        disabledBackgroundColor: kAccent.withOpacity(0.4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _rating == 0
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                _RatignDialogResult(
                                  _rating.toDouble(),
                                  _controller.text.trim(),
                                ),
                              );
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isEdit
                                ? Icons.edit_rounded
                                : Icons.send_rounded,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isEdit ? "Update" : "Post Review",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<({double rating, String comment})?> showRatingDialog(
  BuildContext context, {
  RatingCommentmodel? existing,
}) async {
  final result = await showDialog<_RatignDialogResult>(
    context: context,
    builder: (_) => RatingDialog(existing: existing),
  );

  if (result == null) return null;
  return (rating: result.rating, comment: result.comment);
}
