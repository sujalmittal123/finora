import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finora/core/theme/app_colors.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class EmisScreen extends ConsumerWidget {
  const EmisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finance = ref.watch(financeProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _showAddEmiDialog(context, ref),
            icon: const Icon(Icons.add, color: AppColors.neonEmerald, size: 18),
            label: const Text(
              'Add an EMI',
              style: TextStyle(
                color: AppColors.neonEmerald,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header & Subtitle ─────────────────────────────────────────
              const Text(
                'EMIs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track instalments you owe and tick each one off as you pay it.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // ─── Top Info Card (Matching Reference Image 4) ────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: const Text(
                  'Track big purchases on EMI — log one and never miss a payment.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─── Active EMIs List ──────────────────────────────────────────
              if (finance.emis.isEmpty)
                const SizedBox()
              else
                ...finance.emis.map((emi) {
                  final pct = (emi.progressPercentage * 100).round();
                  final isCompleted = emi.paidMonths >= emi.totalMonths;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.neonEmerald.withValues(alpha: 0.3)
                            : AppColors.glassBorderSubtle,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    emi.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${emi.bankName} · Due ${DateFormat('MMM d').format(emi.nextDueDate)}',
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${currencyFormatter.format(emi.monthlyAmount)}/mo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: emi.progressPercentage,
                            minHeight: 7,
                            backgroundColor: AppColors.surfaceElevated,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.neonEmerald),
                          ),
                        ),

                        const SizedBox(height: 14),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${emi.paidMonths} / ${emi.totalMonths} paid ($pct%)',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (!isCompleted)
                              ElevatedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(financeProvider.notifier)
                                      .payEmiInstallment(emi.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Recorded payment for "${emi.title}"! (${emi.paidMonths + 1}/${emi.totalMonths})'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check, size: 14),
                                label: const Text('Pay Installment'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonEmerald,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.neonEmerald
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Fully Paid ✅',
                                  style: TextStyle(
                                    color: AppColors.neonEmerald,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddEmiDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final monthlyCtrl = TextEditingController();
    final monthsCtrl = TextEditingController(text: '6');
    final bankCtrl = TextEditingController(text: 'HDFC Bank');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
              'Add an EMI',
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
                labelText: 'Purchase Title (e.g. MacBook Air M3)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: totalCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Total ₹'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: monthlyCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Monthly ₹'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: monthsCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Tenure (Months)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: bankCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Bank / Card'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleCtrl.text.trim();
                  final total = double.tryParse(totalCtrl.text.trim()) ?? 0.0;
                  final monthly = double.tryParse(monthlyCtrl.text.trim()) ?? 0.0;
                  final months = int.tryParse(monthsCtrl.text.trim()) ?? 6;
                  final bank = bankCtrl.text.trim();
                  if (title.isNotEmpty && total > 0) {
                    ref.read(financeProvider.notifier).addEmi(
                          title: title,
                          totalAmount: total,
                          monthlyAmount: monthly > 0 ? monthly : total / months,
                          totalMonths: months,
                          bankName: bank.isNotEmpty ? bank : 'Credit Card',
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add EMI Track'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
