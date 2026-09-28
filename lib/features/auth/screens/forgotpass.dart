import 'package:flutter/material.dart';
import 'package:quizbit_2/core/utils/snackbar_helper.dart';
import 'package:quizbit_2/features/auth/auth_controller.dart';
import 'package:quizbit_2/features/auth/screens/login.dart';

enum _Step { enterEmail, enterCode, enterPassword }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  // --- Shared palette ---
  static const Color kDark = Color(0xFF1E2236);
  static const Color kAccent = Color(0xFFFF7A3D);
  static const Color kBg = Color(0xFFFAF7F2);
  static const Color kSoft = Color(0xFFEFEAE2);
  static const Color kMuted = Color(0xFF8A8A95);

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newpasswordController = TextEditingController();
  final _newPassConfirmController = TextEditingController();

  _Step _step = _Step.enterEmail;
  final AuthController _authController = AuthController();

  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newpasswordController.dispose();
    _newPassConfirmController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _goToStep(_Step next) {
    setState(() => _step = next);
    _fadeController
      ..reset()
      ..forward();
  }

  // ---- Step handlers ----
  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      SnackbarHelper.showError(context, "Enter a valid email");
      return;
    }
    setState(() => _isLoading = true);
    final res = await _authController.sendResetOTP(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.sucess) {
      _goToStep(_Step.enterCode);
    } else {
      SnackbarHelper.showError(context, res.error ?? "Something went wrong");
    }
  }

  Future<void> _verifyCode() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      SnackbarHelper.showError(context, "Enter a 6-digit OTP");
      return;
    }
    setState(() => _isLoading = true);
    final res = await _authController.verifyOTP(
      email: _emailController.text.trim(),
      otp: otp,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.sucess) {
      _goToStep(_Step.enterPassword);
    } else {
      SnackbarHelper.showError(context, res.error ?? "Invalid OTP");
    }
  }

  Future<void> _updatePassword() async {
    final newPassword = _newpasswordController.text.trim();
    final confirmPassword = _newPassConfirmController.text.trim();
    if (newPassword.length < 6) {
      SnackbarHelper.showError(
          context, "Password must be at least 6 characters");
      return;
    }
    if (newPassword != confirmPassword) {
      SnackbarHelper.showError(context, "Both passwords don't match");
      return;
    }
    setState(() => _isLoading = true);
    final res = await _authController.updateNewPassword(newPassword);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res.sucess) {
      SnackbarHelper.showSucess(context, "Password reset successfully");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      SnackbarHelper.showError(context, res.error ?? "Failed to update");
    }
  }

  // ---- Reusable text field ----
  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kMuted,
              letterSpacing: 1,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword && obscure,
          keyboardType: keyboardType,
          maxLength: maxLength,
          style: const TextStyle(
            fontSize: 14,
            color: kDark,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            counterText: "",
            hintText: hint,
            hintStyle: TextStyle(
              color: kMuted.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, color: kAccent, size: 20),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: kMuted,
                      size: 20,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
      ],
    );
  }

  // ---- CTA button ----
  Widget _primaryButton({
    required String label,
    required VoidCallback onPressed,
    IconData icon = Icons.arrow_forward_rounded,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          disabledBackgroundColor: kAccent.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: _isLoading ? null : onPressed,
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 18),
                ],
              ),
      ),
    );
  }

  // ---- Step progress indicator ----
  Widget _stepIndicator() {
    final activeIndex = _step.index;
    return Row(
      children: List.generate(3, (i) {
        final isActive = i <= activeIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: 4,
              decoration: BoxDecoration(
                color: isActive ? kAccent : kSoft,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---- Header (brand block at top) ----
  Widget _header() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: kAccent.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: Colors.white, size: 26),
        ),
        const SizedBox(height: 14),
        const Text(
          "Reset Password",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: kDark,
          ),
        ),
      ],
    );
  }

  // ---- Animated wrapper for step content ----
  Widget _animatedStep(Widget child) {
    final anim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
            .animate(anim),
        child: child,
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(child: _header()),
                const SizedBox(height: 30),
                _stepIndicator(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Step ${_step.index + 1} of 3",
                      style: const TextStyle(
                        fontSize: 11,
                        color: kMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _animatedStep(
                  switch (_step) {
                    _Step.enterEmail => _emailStep(),
                    _Step.enterCode => _otpStep(),
                    _Step.enterPassword => _passwordStep(),
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Step 1: Email ----
  Widget _emailStep() {
    return Column(
      key: const ValueKey('email'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Find your account",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "We'll send a verification code to your email",
          style: TextStyle(
            fontSize: 13,
            color: kMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        _textField(
          controller: _emailController,
          label: "EMAIL",
          hint: "you@example.com",
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _primaryButton(label: "Send OTP", onPressed: _sendCode),
      ],
    );
  }

  // ---- Step 2: OTP ----
  Widget _otpStep() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verification code",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kDark,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 13,
              color: kMuted,
              fontWeight: FontWeight.w500,
            ),
            children: [
              const TextSpan(text: "Enter the 6-digit code sent to "),
              TextSpan(
                text: _emailController.text,
                style: const TextStyle(
                  color: kDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _textField(
          controller: _otpController,
          label: "OTP CODE",
          hint: "6-digit code",
          icon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kMuted,
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _goToStep(_Step.enterEmail),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_rounded, size: 14),
                  SizedBox(width: 4),
                  Text("Change email",
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: kAccent,
                padding: EdgeInsets.zero,
              ),
              onPressed: _isLoading ? null : _sendCode,
              child: const Text("Resend code",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _primaryButton(label: "Verify OTP", onPressed: _verifyCode),
      ],
    );
  }

  // ---- Step 3: New password ----
  Widget _passwordStep() {
    return Column(
      key: const ValueKey('password'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Create new password",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: kDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Make it strong — at least 6 characters",
          style: TextStyle(
            fontSize: 13,
            color: kMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        _textField(
          controller: _newpasswordController,
          label: "NEW PASSWORD",
          hint: "Enter new password",
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscure: _obscureNew,
          onToggleObscure: () =>
              setState(() => _obscureNew = !_obscureNew),
        ),
        const SizedBox(height: 18),
        _textField(
          controller: _newPassConfirmController,
          label: "CONFIRM PASSWORD",
          hint: "Re-enter new password",
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscure: _obscureConfirm,
          onToggleObscure: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
        ),
        const SizedBox(height: 24),
        _primaryButton(
          label: "Reset Password",
          onPressed: _updatePassword,
          icon: Icons.check_rounded,
        ),
      ],
    );
  }
}
