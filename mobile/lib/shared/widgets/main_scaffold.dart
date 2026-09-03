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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        backgroundColor: AppColors.neonEmerald,
        foregroundColor: Colors.black,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(
            top: BorderSide(color: AppColors.glassBorderSubtle, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.grid_view_rounded,
                  label: 'Home',
                  context: context,
                ),
                _buildNavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.insights_rounded,
                  label: 'Analytics',
                  context: context,
                ),
                const SizedBox(width: 48), // Spacing for docked FAB
                _buildNavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.auto_awesome,
                  label: 'Nova AI',
                  context: context,
                  isAiTab: true,
                ),
                _buildNavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.savings_outlined,
                  label: 'Vaults',
                  context: context,
                ),
              ],
            ),
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
    required BuildContext context,
    bool isAiTab = false,
  }) {
    final isSelected = index == currentIndex;
    final activeColor = isAiTab ? AppColors.cyberViolet : AppColors.neonEmerald;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
