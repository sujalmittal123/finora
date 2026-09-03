import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finora/core/theme/app_colors.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class VaultsScreen extends ConsumerWidget {
  const VaultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final totalSavedInVaults = finance.vaults
        .fold(0.0, (sum, vault) => sum + vault.currentAmount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Savings Vaults 🎯',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.neonEmerald),
            onPressed: () => _showCreateVaultDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Vault Header Card ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.neonCyan.withValues(alpha: 0.15),
                      AppColors.surfaceCard,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL STASHED IN VAULTS',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currencyFormatter.format(totalSavedInVaults),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${finance.vaults.length} Active Goals Locked & Growing',
                      style: const TextStyle(
                        color: AppColors.neonCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'YOUR WISHLIST TARGETS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              // ─── Vault List ────────────────────────────────────────────────
              ...finance.vaults.map((vault) {
                final pct = (vault.progressPercentage * 100).round();
                final daysLeft =
                    vault.targetDate.difference(DateTime.now()).inDays;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(vault.emoji,
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vault.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${currencyFormatter.format(vault.currentAmount)} of ${currencyFormatter.format(vault.targetAmount)}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonEmerald
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$pct%',
                              style: const TextStyle(
                                color: AppColors.neonEmerald,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: vault.progressPercentage,
                          minHeight: 8,
                          backgroundColor: AppColors.surfaceElevated,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.neonEmerald),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '⏳ ${daysLeft > 0 ? daysLeft : 0} days remaining',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref
                                  .read(financeProvider.notifier)
                                  .depositToVault(vault.id, 500);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppColors.surfaceCard,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  content: Text(
                                    '⚡ Stashed ₹500 into ${vault.title}! Streak on fire 🔥',
                                    style: const TextStyle(
                                      color: AppColors.neonEmerald,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.flash_on, size: 16),
                            label: const Text('+ ₹500'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonEmerald,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateVaultDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedEmoji = '🎧';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Savings Vault',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Goal Title (e.g. Jordan 1 Retro)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Target Amount (₹)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
                  if (title.isNotEmpty && amount > 0) {
                    ref.read(financeProvider.notifier).createVault(
                          title: title,
                          targetAmount: amount,
                          emoji: selectedEmoji,
                          daysToTarget: 60,
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Lock Vault & Start Stashing'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
