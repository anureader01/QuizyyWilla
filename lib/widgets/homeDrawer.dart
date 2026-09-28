import 'package:flutter/material.dart';
import 'package:quizbit_2/core/session/ProfileSession.dart';
import 'package:quizbit_2/core/utils/snackbar_helper.dart';
import 'package:quizbit_2/features/aboutus/aboutus_screen.dart';
import 'package:quizbit_2/features/auth/auth_controller.dart';
import 'package:quizbit_2/features/auth/screens/login.dart';
import 'package:quizbit_2/features/helpnsupport/help_screen.dart';
import 'package:quizbit_2/features/profile/profile_screen.dart';

// --- Shared palette ---
const Color kDark = Color(0xFF1E2236);
const Color kAccent = Color(0xFFFF7A3D);
const Color kBg = Color(0xFFFAF7F2);
const Color kSoft = Color(0xFFEFEAE2);
const Color kMuted = Color(0xFF8A8A95);
const Color kDanger = Color(0xFFE74C3C);

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kDanger.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: kDanger, size: 26),
              ),
              const SizedBox(height: 14),
              const Text(
                "Log out?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "You'll need to sign in again to play.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
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
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel",
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDanger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Log out",
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final success = await AuthController().logout();
    if (!context.mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileSession.profile;

    final isLoggedIn = ProfileSession.isLoggedIn;

    return Drawer(
      backgroundColor: kBg,
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            // ── Profile header ──────────────────────────────
            _ProfileHeader(
              name: profile?.name ?? 'Guest',
              gameTitle: profile?.game_title ?? 'New Player',
              avatarUrl: profile?.profile_pic_url,
              money: profile?.money ?? 0,
              attempts: profile?.quiz_attempts ?? 0,
              isLoggedIn: isLoggedIn,
            ),

            const SizedBox(height: 16),

            // ── Menu items ──────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _sectionLabel("ACCOUNT"),
                  const SizedBox(height: 4),
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: "My Profile",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProfileSession.isLoggedIn
                                ? ProfileScreen(
                                    profile_id:
                                        ProfileSession.profile!.user_id,
                                  )
                                : const LoginScreen();
                          },
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.history_rounded,
                    label: "Quiz History",
                    trailing: profile != null
                        ? "${profile.quiz_attempts}"
                        : null,
                    onTap: () {
                      SnackbarHelper.showInfo(context, "Feature will come soon.");
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "Wallet",
                    trailing: profile  == null ? "Login" : "₹${profile.money}"  ,
                    highlightTrailing: true,
                    onTap: () {
                        SnackbarHelper.showInfo(context, "Feature will come soon.");
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.lightbulb_outline_rounded,
                    label: "My Topic Requests",
                    trailing: profile != null
                        ? "${profile.topic_asked.length}"
                        : null,
                    onTap: () {
                        SnackbarHelper.showInfo(context, "Feature will come soon.");
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.emoji_events_outlined,
                    label: "Achievements",
                    onTap: () {
                        SnackbarHelper.showInfo(context, "Feature will come soon.");
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 16),
                  _sectionLabel("GENERAL"),
                  const SizedBox(height: 4),
                  _DrawerItem(
                    icon: Icons.notifications_none_rounded,
                    label: "Notifications",
                    onTap: () {
                        SnackbarHelper.showInfo(context, "Feature will come soon.");
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: "Settings",
                    onTap: () {
                        SnackbarHelper.showInfo(context, "Feature will come soon.");
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: "Help & Support",
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>HelpSupportScreen()));
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    label: "About",
                    onTap: () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>AboutUsScreen()));
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // ── Bottom CTA (Log out or Sign in) ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: isLoggedIn
                  ? _bottomCta(
                      label: "Log out",
                      icon: Icons.logout_rounded,
                      color: kDanger,
                      bg: kDanger.withOpacity(0.08),
                      onTap: () => _logout(context),
                    )
                  : _bottomCta(
                      label: "Sign in",
                      icon: Icons.login_rounded,
                      color: Colors.white,
                      bg: kAccent,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Section label ----
  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: kMuted,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // ---- Bottom CTA ----
  Widget _bottomCta({
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: bg == kAccent ? kAccent : color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Profile header
// ─────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String gameTitle;
  final String? avatarUrl;
  final int money;
  final int attempts;
  final bool isLoggedIn;

  const _ProfileHeader({
    required this.name,
    required this.gameTitle,
    required this.avatarUrl,
    required this.money,
    required this.attempts,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLoggedIn ? kAccent : kSoft,
                    width: 2,
                  ),
                  boxShadow: isLoggedIn
                      ? [
                          BoxShadow(
                            color: kAccent.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: kSoft,
                  backgroundImage: hasUrl ? NetworkImage(avatarUrl!) : null,
                  child: !hasUrl
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "?",
                          style: const TextStyle(
                            color: kDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
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
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  size: 10, color: kAccent),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  gameTitle,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: kAccent,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoggedIn) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    icon: Icons.account_balance_wallet_rounded,
                    label: "₹$money",
                    sub: "Wallet",
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    icon: Icons.quiz_rounded,
                    label: "$attempts",
                    sub: "Plays",
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: kAccent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Sign in to track progress",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stat pill in header
// ─────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  const _StatPill({
    required this.icon,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: kAccent),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                sub.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Drawer item
// ─────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final bool highlightTrailing;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.highlightTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kAccent, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: kDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              if (trailing != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: highlightTrailing
                        ? kAccent
                        : kSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trailing!,
                    style: TextStyle(
                      color: highlightTrailing ? Colors.white : kDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: kMuted.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
