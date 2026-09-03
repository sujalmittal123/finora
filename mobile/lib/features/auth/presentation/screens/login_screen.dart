import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  int _activeStep = 1;

  final List<Map<String, String>> _onboardingSteps = [
    {
      'tag': '01 · WELCOME',
      'title1': 'track',
      'title2': 'expense',
      'title3': 'easy.',
      'sub': 'IN JUST 3 SECONDS.',
      'descTitle': 'pick how to enter.',
      'descSub': 'One tap. No passwords. No spam.',
    },
    {
      'tag': '02 · AI INSIGHTS',
      'title1': 'spend',
      'title2': 'smart.',
      'title3': 'flex more.',
      'sub': 'POWERED BY FINORA AI.',
      'descTitle': 'daily safe-to-spend.',
      'descSub': 'Never go broke before payday again.',
    },
    {
      'tag': '03 · VAULTS & GOALS',
      'title1': 'save',
      'title2': 'goals.',
      'title3': 'level up.',
      'sub': 'GAMIFIED SAVINGS VAULTS.',
      'descTitle': 'hit your targets.',
      'descSub': 'Trips, tech stashes, and emergency funds.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final currentStepData = _onboardingSteps[_activeStep - 1];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Ambient Glowing Backdrop Gradient ───────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF06070B),
                    Color(0xFF0B0D16),
                    Color(0xFF140D24),
                    Color(0xFF220E30),
                    Color(0xFF3B1238),
                  ],
                  stops: [0.0, 0.35, 0.65, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // ─── Top Ambient Light Bloom ──────────────────────────────────────
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyberViolet.withValues(alpha: 0.18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyberViolet.withValues(alpha: 0.3),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // ─── Content SafeArea ─────────────────────────────────────────────
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),

                            // ── 01 · WELCOME Micro-Tag ───────────────────────────────
                            Text(
                              currentStepData['tag']!,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                                fontFamily: 'monospace',
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Hero Headline (Bold Lowercase Typography) ────────────
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                key: ValueKey<int>(_activeStep),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentStepData['title1']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  Text(
                                    currentStepData['title2']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                  Text(
                                    currentStepData['title3']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      height: 1.05,
                                      letterSpacing: -1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ── Tagline (IN JUST 3 SECONDS.) ─────────────────────────
                            Text(
                              currentStepData['sub']!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── Stepper Capsule (1) (2) (3) ──────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStepNumber(1),
                                  const SizedBox(width: 8),
                                  _buildStepNumber(2),
                                  const SizedBox(width: 8),
                                  _buildStepNumber(3),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),
                            const Spacer(),

                            // ── Secondary Prompt & Description ───────────────────────
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                key: ValueKey<int>(_activeStep),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentStepData['descTitle']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    currentStepData['descSub']!,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Error Banner if any ──────────────────────────────────
                            if (authState.hasError)
                              Container(
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.neonCrimson
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.neonCrimson
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline,
                                        color: AppColors.neonCrimson, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        authState.error != null
                                            ? authState.error
                                                .toString()
                                                .replaceAll('Exception:', '')
                                                .trim()
                                            : 'Sign-in failed. Please try again.',
                                        style: TextStyle(
                                          color: AppColors.neonCrimson
                                              .withValues(alpha: 0.95),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ── Primary Action Button: "Continue with Google" ────────
                            _GoogleSignInPillButton(
                              isLoading: isLoading,
                              onPressed: () async {
                                await ref
                                    .read(authNotifierProvider.notifier)
                                    .signInWithGoogle();
                              },
                            ),

                            const SizedBox(height: 20),

                            // ── Disclaimer Footer ────────────────────────────────────
                            Center(
                              child: Text(
                                'Your money stays yours. By continuing, you agree to our Terms & Privacy Policy.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.45),
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNumber(int step) {
    final isActive = _activeStep == step;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeStep = step;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? AppColors.neonCrimson
              : Colors.white.withValues(alpha: 0.05),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.neonCrimson.withValues(alpha: 0.45),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInPillButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInPillButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.2,
            ),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GoogleGLogo(size: 22),
                  const SizedBox(width: 14),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleGLogo extends StatelessWidget {
  final double size;
  const _GoogleGLogo({this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    final segments = [
      (0.0, 0.5, const Color(0xFF4285F4)), // Blue
      (0.5, 0.75, const Color(0xFF34A853)), // Green
      (0.75, 0.875, const Color(0xFFFBBC05)), // Yellow
      (0.875, 1.0, const Color(0xFFEA4335)), // Red
    ];

    for (final (start, end, color) in segments) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.7),
        start * 2 * 3.14159,
        (end - start) * 2 * 3.14159,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
