import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _glowSweepController;
  int _activeStep = 1;
  double _demoMonthlyIncome = 65000;

  final List<Map<String, dynamic>> _onboardingSlides = [
    {
      'tag': '01 · QUANTUM SPEED',
      'title1': 'track.',
      'title2': 'flex.',
      'title3': 'save.',
      'sub': 'LOG IN JUST 3 SECONDS.',
      'descTitle': 'instant money telemetry.',
      'descSub':
          'Zero manual friction. 1-tap vibe logging & smart account sync.',
      'accentColor': AppColors.neonEmerald,
      'badgeEmoji': '⚡',
    },
    {
      'tag': '02 · AI MONEY TWIN',
      'title1': 'spend',
      'title2': 'smarter.',
      'title3': 'level up.',
      'sub': 'POWERED BY NOVA AI CO-PILOT.',
      'descTitle': 'predictive safe-to-spend.',
      'descSub':
          'Real-time spending roasts, vampire sub radar, & daily allowances.',
      'accentColor': AppColors.cyberViolet,
      'badgeEmoji': '🔮',
    },
    {
      'tag': '03 · GRAVITY VAULTS',
      'title1': 'lock',
      'title2': 'goals.',
      'title3': 'fly out.',
      'sub': 'GAMIFIED 3D SAVINGS VAULTS.',
      'descTitle': 'crush your wishlist.',
      'descSub': 'Trips, tech stashes, and emergency reserves on autopilot.',
      'accentColor': AppColors.neonCyan,
      'badgeEmoji': '🎯',
    },
  ];

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _glowSweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _glowSweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    final currentSlide = _onboardingSlides[_activeStep - 1];
    final accentColor = currentSlide['accentColor'] as Color;

    // Computed demo daily allowance for interactive simulator
    final demoDailySafe = (_demoMonthlyIncome * 0.65) / 30;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ─── Animated Floating Ambient Neon Mesh Orbs ───────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CyberAmbientMeshPainter(
                    animationValue: _ambientController.value,
                    accentColor: accentColor,
                  ),
                );
              },
            ),
          ),

          // ─── Subtle Grid Overlay ─────────────────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _CyberGridPainter(),
            ),
          ),

          // ─── Main Scrollable Content ──────────────────────────────────────
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
                            horizontal: 26, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Top Bar: Tag & Live Aura Status ─────────────
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          accentColor.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        currentSlide['badgeEmoji'] as String,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        currentSlide['tag'] as String,
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 2.0,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.glassBorderSubtle),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'FINORA 2030',
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ── Hero Typography (Massive Bold Lowercase) ────
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
                                opacity: anim,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.08),
                                    end: Offset.zero,
                                  ).animate(anim),
                                  child: child,
                                ),
                              ),
                              child: Column(
                                key: ValueKey<int>(_activeStep),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSlide['title1'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 46,
                                      fontWeight: FontWeight.w900,
                                      height: 1.02,
                                      letterSpacing: -2.0,
                                    ),
                                  ),
                                  Text(
                                    currentSlide['title2'] as String,
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 46,
                                      fontWeight: FontWeight.w900,
                                      height: 1.02,
                                      letterSpacing: -2.0,
                                      shadows: [
                                        Shadow(
                                          color: accentColor.withValues(
                                              alpha: 0.5),
                                          blurRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    currentSlide['title3'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 46,
                                      fontWeight: FontWeight.w900,
                                      height: 1.02,
                                      letterSpacing: -2.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ── Tagline ─────────────────────────────────────
                            Text(
                              currentSlide['sub'] as String,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2.0,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Interactive Stepper Capsule (1) (2) (3) ─────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildStepNumber(1, AppColors.neonEmerald),
                                  const SizedBox(width: 8),
                                  _buildStepNumber(2, AppColors.cyberViolet),
                                  const SizedBox(width: 8),
                                  _buildStepNumber(3, AppColors.neonCyan),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── Interactive "Taste the Safe-to-Spend" Dial ──
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceCard.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.3),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.auto_awesome,
                                              color: accentColor, size: 16),
                                          const SizedBox(width: 6),
                                          const Text(
                                            'INTERACTIVE SIMULATOR',
                                            style: TextStyle(
                                              color: AppColors.textMuted,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '₹${demoDailySafe.toStringAsFixed(0)}/day safe',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Drag monthly inflow to test daily allowance: ₹${_demoMonthlyIncome.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor: accentColor,
                                      inactiveTrackColor:
                                          AppColors.surfaceElevated,
                                      thumbColor: Colors.white,
                                      overlayColor: accentColor
                                          .withValues(alpha: 0.2),
                                      trackHeight: 4,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 7),
                                    ),
                                    child: Slider(
                                      value: _demoMonthlyIncome,
                                      min: 20000,
                                      max: 200000,
                                      divisions: 36,
                                      onChanged: (val) {
                                        setState(() => _demoMonthlyIncome = val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),
                            const Spacer(),

                            // ── Secondary Prompt & Description ───────────────
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                key: ValueKey<int>(_activeStep),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentSlide['descTitle'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentSlide['descSub'] as String,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ── Error Banner ─────────────────────────────────
                            if (authState.hasError)
                              Container(
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(bottom: 14),
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
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // ── Luxury Animated "Continue with Google" ───────
                            _CyberGoogleSignInButton(
                              isLoading: isLoading,
                              sweepAnimation: _glowSweepController,
                              onPressed: () async {
                                await ref
                                    .read(authNotifierProvider.notifier)
                                    .signInWithGoogle();
                              },
                            ),

                            const SizedBox(height: 14),

                            // ── Disclaimer Footer ────────────────────────────
                            Center(
                              child: Text(
                                'Your money stays yours. End-to-end encrypted · Powered by Firebase',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
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

  Widget _buildStepNumber(int step, Color activeStepColor) {
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
              ? activeStepColor
              : Colors.white.withValues(alpha: 0.06),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeStepColor.withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            '$step',
            style: TextStyle(
              color: isActive ? Colors.black : AppColors.textMuted,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Floating Ambient Neon Mesh Painter ──────────────────────────────────────
class _CyberAmbientMeshPainter extends CustomPainter {
  final double animationValue;
  final Color accentColor;

  _CyberAmbientMeshPainter({
    required this.animationValue,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background base
    final bgPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Orb 1 (Top Right)
    final orb1Center = Offset(
      w * 0.85 + math.sin(animationValue * math.pi * 2) * 30,
      h * 0.15 + math.cos(animationValue * math.pi * 2) * 40,
    );
    final orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: 0.28),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb1Center, radius: w * 0.55));
    canvas.drawCircle(orb1Center, w * 0.55, orb1Paint);

    // Orb 2 (Bottom Left)
    final orb2Center = Offset(
      w * 0.15 + math.cos(animationValue * math.pi * 2) * 30,
      h * 0.85 + math.sin(animationValue * math.pi * 2) * 40,
    );
    final orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.electricPurple.withValues(alpha: 0.25),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: orb2Center, radius: w * 0.65));
    canvas.drawCircle(orb2Center, w * 0.65, orb2Paint);

    // Orb 3 (Center Ambient)
    final orb3Center = Offset(
      w * 0.5,
      h * 0.5 + math.sin(animationValue * math.pi) * 20,
    );
    final orb3Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.neonCyan.withValues(alpha: 0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: orb3Center, radius: w * 0.45));
    canvas.drawCircle(orb3Center, w * 0.45, orb3Paint);
  }

  @override
  bool shouldRepaint(covariant _CyberAmbientMeshPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.accentColor != accentColor;
  }
}

// ─── Subtle Cyber Grid Painter ──────────────────────────────────────────────
class _CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Luxury Animated Google Sign-In Button with Sweep Glow ─────────────────
class _CyberGoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final Animation<double> sweepAnimation;
  final VoidCallback onPressed;

  const _CyberGoogleSignInButton({
    required this.isLoading,
    required this.sweepAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sweepAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: 0.0,
              endAngle: math.pi * 2,
              transform: GradientRotation(sweepAnimation.value * math.pi * 2),
              colors: const [
                AppColors.neonEmerald,
                AppColors.neonCyan,
                AppColors.cyberViolet,
                AppColors.electricPurple,
                AppColors.neonEmerald,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyberViolet.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5), // Border thickness
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF090B12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.neonEmerald,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
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
        ..strokeWidth = size.width * 0.20;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.68),
        start * 2 * math.pi,
        (end - start) * 2 * math.pi,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
