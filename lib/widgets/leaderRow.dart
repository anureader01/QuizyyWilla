import 'package:flutter/material.dart';

Widget leaderRow({
  required String profileUrl,
  required String rank,
  required String name,
  required String amount,
  required String title,
  bool highlighted = false,
}) {
  // --- Shared palette ---
  const Color kDark = Color(0xFF1E2236);
  const Color kAccent = Color(0xFFFF7A3D);
  const Color kSoft = Color(0xFFEFEAE2);
  const Color kMuted = Color(0xFF8A8A95);

  final hasPic = profileUrl.isNotEmpty;
  final hasTitle = title.isNotEmpty;

  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
    decoration: BoxDecoration(
      color: highlighted ? kAccent.withOpacity(0.08) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: highlighted ? kAccent : kSoft,
        width: highlighted ? 1.8 : 1.5,
      ),
    ),
    child: Row(
      children: [
        // Rank chip
        SizedBox(
          width: 36,
          child: Text(
            "#$rank",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: highlighted ? kAccent : kMuted,
            ),
          ),
        ),

        // Avatar with ring
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: highlighted ? kAccent : kSoft,
              width: 1.5,
            ),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: kSoft,
            backgroundImage: hasPic ? NetworkImage(profileUrl) : null,
            child: !hasPic
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: const TextStyle(
                      color: kDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),

        // Name + title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              if (hasTitle) ...[
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: kMuted,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),

        // Amount
        Text(
          amount,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: kDark,
          ),
        ),
      ],
    ),
  );
}
