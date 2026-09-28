import 'package:flutter/material.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/features/profile/profile_screen.dart';
import 'package:quizbit_2/models/ratingCommentModel.dart';
import 'package:timeago/timeago.dart' as timeago;

class Ratingitem extends StatelessWidget {
  final RatingCommentmodel rating;

  const Ratingitem({super.key, required this.rating});

  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  @override
  Widget build(BuildContext context) {
    final hasComment =
        rating.comment != null && rating.comment!.trim().isNotEmpty;
    final userName = rating.userName ?? "Anonymous";
    final profilePic = rating.user_profile_pic;
    final createdAt = rating.created_at;

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
          // ---- Top row: user info + time ----
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (rating.profileId == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfileScreen(profile_id: rating.profileId!),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kSoft, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: kSoft,
                    backgroundImage: (profilePic != null && profilePic.isNotEmpty)
                        ? NetworkImage(profilePic)
                        : null,
                    child: (profilePic == null || profilePic.isEmpty)
                        ? Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              color: kDark,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kDark,
                      ),
                    ),
                    if (createdAt != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        timeago.format(createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: kMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Rating pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: kAccent),
                    const SizedBox(width: 2),
                    Text(
                      "${rating.rating}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: kAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ---- Stars row ----
          Row(
            children: List.generate(5, (index) {
              final filled = index < rating.rating;
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 18,
                  color: filled ? kAccent : kMuted.withOpacity(0.4),
                ),
              );
            }),
          ),

          // ---- Comment ----
          if (hasComment) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kSoft.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: kAccent, width: 3),
                ),
              ),
              child: Text(
                rating.comment!,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: kDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.chat_bubble_outline_rounded,
                    size: 13, color: kMuted.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  "No comment provided",
                  style: TextStyle(
                    fontSize: 12,
                    color: kMuted.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
