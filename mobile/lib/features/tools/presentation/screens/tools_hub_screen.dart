import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finora/core/theme/app_colors.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class ToolsHubScreen extends ConsumerWidget {
  const ToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final budgetLeft = finance.remainingMonthlyBudget;
    final budgetProgress = finance.monthlyBudget > 0
        ? (finance.monthlyExpenses / finance.monthlyBudget).clamp(0.0, 1.0)
        : 0.0;

    final subSubtitle = finance.subscriptions.isNotEmpty
        ? '${finance.subscriptions.length} active'
        : 'None yet';
    final emiSubtitle = finance.emis.isNotEmpty
        ? '${finance.emis.length} active'
        : 'None yet';
    final pmSubtitle = finance.paymentMethods.isNotEmpty
        ? '${finance.paymentMethods.length} accounts'
        : 'Set up cards';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Screen Title ─────────────────────────────────────────────
              const Text(
                'Financial Tools',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 18),

              // ─── Monthly Budget Card (Matching Reference Image 2) ──────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monthly budget',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showEditBudgetDialog(context, ref, finance.monthlyBudget),
                          child: Row(
                            children: [
                              Text(
                                '${currencyFormatter.format(budgetLeft)} left',
                                style: const TextStyle(
                                  color: AppColors.neonEmerald,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.edit_outlined,
                                  color: AppColors.neonEmerald, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: budgetProgress,
                        minHeight: 8,
                        backgroundColor: AppColors.surfaceElevated,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          budgetProgress > 0.85
                              ? AppColors.neonCrimson
                              : AppColors.neonEmerald,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Commitments Section ───────────────────────────────────────
              const Text(
                'Commitments',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Column(
                  children: [
                    _buildToolListTile(
                      icon: Icons.access_time_rounded,
                      title: 'Subscriptions',
                      subtitle: subSubtitle,
                      onTap: () => context.push('/tools/subscriptions'),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildToolListTile(
                      icon: Icons.history_rounded,
                      title: 'EMIs',
                      subtitle: emiSubtitle,
                      onTap: () => context.push('/tools/emis'),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildToolListTile(
                      icon: Icons.credit_card_rounded,
                      title: 'Payment Methods',
                      subtitle: pmSubtitle,
                      onTap: () => context.push('/tools/payment-methods'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ─── Calculators Section ───────────────────────────────────────
              const Text(
                'Calculators',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Column(
                  children: [
                    _buildToolListTile(
                      icon: Icons.bar_chart_rounded,
                      title: 'FD / RD calculator',
                      onTap: () => context.push('/tools/fd-rd-calculator'),
                    ),
                    const Divider(height: 1, indent: 56, endIndent: 20),
                    _buildToolListTile(
                      icon: Icons.description_outlined,
                      title: 'Tax estimator',
                      onTap: () => context.push('/tools/tax-estimator'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.arrow_forward_ios_rounded,
              color: AppColors.textMuted, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showEditBudgetDialog(
      BuildContext context, WidgetRef ref, double currentBudget) {
    final ctrl = TextEditingController(text: currentBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Update Monthly Budget',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Monthly Target (₹)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(ctrl.text.trim()) ?? currentBudget;
              ref.read(financeProvider.notifier).updateMonthlyBudget(val);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
