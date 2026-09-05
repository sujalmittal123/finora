import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/analytics')) return 1;
    if (location.startsWith('/ai-assistant')) return 2;
    if (location.startsWith('/vaults')) return 3;
    if (location.startsWith('/accounts')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/analytics');
        break;
      case 2:
        context.go('/ai-assistant');
        break;
      case 3:
        context.go('/vaults');
        break;
      case 4:
        context.go('/accounts');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    // Dynamic accent color depending on current tab
    Color currentAccent;
    switch (currentIndex) {
      case 0:
        currentAccent = AppColors.neonEmerald;
        break;
      case 1:
        currentAccent = AppColors.neonCyan;
        break;
      case 2:
        currentAccent = AppColors.cyberViolet;
        break;
      case 3:
        currentAccent = AppColors.electricAmber;
        break;
      default:
        currentAccent = AppColors.neonEmerald;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Content
          Positioned.fill(child: child),

          // ─── Floating Island Glass Navigation Capsule ─────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 68,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xCC0D101A),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: currentAccent.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: currentAccent.withValues(alpha: 0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                      const BoxShadow(
                        color: Colors.black54,
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        index: 0,
                        currentIndex: currentIndex,
                        icon: Icons.grid_view_rounded,
                        label: 'Home',
                        accentColor: AppColors.neonEmerald,
                        context: context,
                      ),
                      _buildNavItem(
                        index: 1,
                        currentIndex: currentIndex,
                        icon: Icons.insights_rounded,
                        label: '3D Burn',
                        accentColor: AppColors.neonCyan,
                        context: context,
                      ),

                      // Center Quantum FAB
                      _buildCenterQuantumFab(context, currentAccent),

                      _buildNavItem(
                        index: 2,
                        currentIndex: currentIndex,
                        icon: Icons.auto_awesome,
                        label: 'Nova AI',
                        accentColor: AppColors.cyberViolet,
                        context: context,
                      ),
                      _buildNavItem(
                        index: 3,
                        currentIndex: currentIndex,
                        icon: Icons.savings_outlined,
                        label: 'Vaults',
                        accentColor: AppColors.electricAmber,
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterQuantumFab(BuildContext context, Color currentAccent) {
    return GestureDetector(
      onTap: () => _showQuantumActionSheet(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              AppColors.neonEmerald,
              AppColors.neonCyan,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonEmerald.withValues(alpha: 0.4),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.black,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int currentIndex,
    required IconData icon,
    required String label,
    required Color accentColor,
    required BuildContext context,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantumActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F121C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(
            top: BorderSide(color: AppColors.glassBorderGlow, width: 1.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'QUANTUM ACTIONS ⚡',
              style: TextStyle(
                color: AppColors.neonEmerald,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _buildActionTile(
              ctx: ctx,
              icon: '💸',
              title: 'Log Instant Vibe Expense',
              desc: 'Manual dial & split-bill logger',
              onTap: () {
                Navigator.pop(ctx);
                context.push('/transactions/add');
              },
            ),
            _buildActionTile(
              ctx: ctx,
              icon: '🔮',
              title: 'Ask Nova AI to Analyze Receipt',
              desc: 'Autonomous spending co-pilot',
              onTap: () {
                Navigator.pop(ctx);
                context.go('/ai-assistant');
              },
            ),
            _buildActionTile(
              ctx: ctx,
              icon: '🎯',
              title: 'Create Stash Goal / Vault',
              desc: 'Gamified 3D wishlist bucket',
              onTap: () {
                Navigator.pop(ctx);
                context.go('/vaults');
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext ctx,
    required String icon,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: ListTile(
        leading: Text(icon, style: const TextStyle(fontSize: 24)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          desc,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            color: AppColors.textMuted, size: 14),
        onTap: onTap,
      ),
    );
  }
}
