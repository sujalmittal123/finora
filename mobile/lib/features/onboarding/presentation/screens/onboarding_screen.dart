import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/financial_models.dart';
import '../../../dashboard/presentation/providers/finance_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _incomeCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  String _accountType = 'Bank';
  final _accountBalanceCtrl = TextEditingController();
  bool _includeAccount = true;

  static const _accountTypes = ['Bank', 'Cash', 'UPI', 'Credit Card'];

  @override
  void dispose() {
    _incomeCtrl.dispose();
    _budgetCtrl.dispose();
    _accountNameCtrl.dispose();
    _accountBalanceCtrl.dispose();
    super.dispose();
  }

  void _finishSetup() {
    final income = double.tryParse(_incomeCtrl.text.trim()) ?? 0.0;
    final budget = double.tryParse(_budgetCtrl.text.trim()) ?? 0.0;

    if (income <= 0) {
      _showError('Please enter your monthly income (greater than 0).');
      return;
    }

    AccountItem? firstAccount;
    if (_includeAccount && _accountNameCtrl.text.trim().isNotEmpty) {
      final balance = double.tryParse(_accountBalanceCtrl.text.trim()) ?? 0.0;
      firstAccount = AccountItem(
        id: 'acc-${DateTime.now().millisecondsSinceEpoch}',
        name: _accountNameCtrl.text.trim(),
        type: _accountType,
        balance: balance,
        isDefault: true,
      );
    }

    ref.read(financeProvider.notifier).completeSetup(
          monthlyIncome: income,
          monthlyBudget: budget,
          firstAccount: firstAccount,
        );

    context.go('/dashboard');
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.neonCrimson),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SETUP YOUR MONEY HUB',
                style: TextStyle(
                  color: AppColors.neonEmerald,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your data,\nyour rules 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Finora starts empty. Enter your own numbers — everything is stored only on this device.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              _buildFieldLabel('MONTHLY INCOME 💰'),
              _buildMoneyField(_incomeCtrl, 'e.g. 60000'),
              const SizedBox(height: 18),

              _buildFieldLabel('MONTHLY BUDGET 🎯'),
              _buildMoneyField(_budgetCtrl, 'e.g. 40000'),
              const SizedBox(height: 28),

              _buildFieldLabel('FIRST ACCOUNT (optional)'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Add a bank/cash account',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Switch(
                          value: _includeAccount,
                          activeTrackColor: AppColors.neonEmerald,
                          onChanged: (v) => setState(() => _includeAccount = v),
                        ),
                      ],
                    ),
                    if (_includeAccount) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: _accountNameCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Account name (e.g. HDFC Savings)',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.account_balance,
                              color: AppColors.textMuted, size: 20),
                          fillColor: AppColors.surfaceElevated,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _accountType,
                        dropdownColor: AppColors.surfaceElevated,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Type',
                          labelStyle:
                              const TextStyle(color: AppColors.textMuted),
                          fillColor: AppColors.surfaceElevated,
                        ),
                        items: _accountTypes.map((t) {
                          return DropdownMenuItem(value: t, child: Text(t));
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _accountType = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _accountBalanceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Current balance (₹)',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.currency_rupee,
                              color: AppColors.textMuted, size: 20),
                          fillColor: AppColors.surfaceElevated,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonEmerald,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Start Tracking 🚀',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  'You can change anything later in the app.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildMoneyField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: const Icon(Icons.currency_rupee,
            color: AppColors.neonEmerald, size: 20),
        filled: true,
        fillColor: AppColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.neonEmerald),
        ),
      ),
    );
  }
}
