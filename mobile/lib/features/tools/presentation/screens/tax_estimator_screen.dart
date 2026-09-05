import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class TaxEstimatorScreen extends StatefulWidget {
  const TaxEstimatorScreen({super.key});

  @override
  State<TaxEstimatorScreen> createState() => _TaxEstimatorScreenState();
}

class _TaxEstimatorScreenState extends State<TaxEstimatorScreen> {
  double _grossIncome = 1200000; // ₹12,00,000
  double _section80C = 150000;   // Max 1.5L
  double _section80D = 25000;    // Max 50K
  double _hraHomeLoan = 100000;  // Max 2L
  double _nps80CCD = 50000;      // Max 50K

  // Calculate New Regime Tax (FY 2024-25 / AY 2025-26)
  // Standard Deduction: ₹75,000
  // Slabs:
  // 0 - 3L: Nil
  // 3L - 7L: 5%
  // 7L - 10L: 10%
  // 10L - 12L: 15%
  // 12L - 15L: 20%
  // Above 15L: 30%
  // Section 87A rebate if taxable income <= 7,00,000 -> Tax = 0
  double _calculateNewRegimeTax(double gross) {
    const stdDeduction = 75000.0;
    final taxable = (gross - stdDeduction).clamp(0.0, double.infinity);
    if (taxable <= 700000) return 0.0; // Rebate u/s 87A

    double tax = 0.0;
    if (taxable > 1500000) {
      tax += (taxable - 1500000) * 0.30;
      tax += 300000 * 0.20; // 12L - 15L
      tax += 200000 * 0.15; // 10L - 12L
      tax += 300000 * 0.10; // 7L - 10L
      tax += 400000 * 0.05; // 3L - 7L
    } else if (taxable > 1200000) {
      tax += (taxable - 1200000) * 0.20;
      tax += 200000 * 0.15; // 10L - 12L
      tax += 300000 * 0.10; // 7L - 10L
      tax += 400000 * 0.05; // 3L - 7L
    } else if (taxable > 1000000) {
      tax += (taxable - 1000000) * 0.15;
      tax += 300000 * 0.10; // 7L - 10L
      tax += 400000 * 0.05; // 3L - 7L
    } else if (taxable > 700000) {
      tax += (taxable - 700000) * 0.10;
      tax += 400000 * 0.05; // 3L - 7L
    } else if (taxable > 300000) {
      tax += (taxable - 300000) * 0.05;
    }

    // 4% Health & Education Cess
    return tax * 1.04;
  }

  // Calculate Old Regime Tax
  // Standard Deduction: ₹50,000 + 80C + 80D + HRA/HomeLoan + NPS
  // Slabs:
  // 0 - 2.5L: Nil
  // 2.5L - 5L: 5%
  // 5L - 10L: 20%
  // Above 10L: 30%
  // Section 87A rebate if taxable income <= 5,00,000 -> Tax = 0
  double _calculateOldRegimeTax(double gross) {
    const stdDeduction = 50000.0;
    final totalDeductions = stdDeduction +
        _section80C.clamp(0.0, 150000.0) +
        _section80D.clamp(0.0, 50000.0) +
        _hraHomeLoan.clamp(0.0, 200000.0) +
        _nps80CCD.clamp(0.0, 50000.0);

    final taxable = (gross - totalDeductions).clamp(0.0, double.infinity);
    if (taxable <= 500000) return 0.0; // Rebate u/s 87A

    double tax = 0.0;
    if (taxable > 1000000) {
      tax += (taxable - 1000000) * 0.30;
      tax += 500000 * 0.20; // 5L - 10L
      tax += 250000 * 0.05; // 2.5L - 5L
    } else if (taxable > 500000) {
      tax += (taxable - 500000) * 0.20;
      tax += 250000 * 0.05; // 2.5L - 5L
    } else if (taxable > 250000) {
      tax += (taxable - 250000) * 0.05;
    }

    // 4% Health & Education Cess
    return tax * 1.04;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final newTax = _calculateNewRegimeTax(_grossIncome);
    final oldTax = _calculateOldRegimeTax(_grossIncome);
    final diff = (newTax - oldTax).abs();
    final isNewCheaper = newTax <= oldTax;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Tax Estimator 📑',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Regime Comparison Card ────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF161B2B),
                      Color(0xFF0F121C),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.cyberViolet.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyberViolet.withValues(alpha: 0.1),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildRegimeSummary(
                            regimeTitle: 'NEW REGIME ⚡',
                            taxAmount: currencyFormatter.format(newTax),
                            isRecommended: isNewCheaper,
                            color: AppColors.neonEmerald,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 70,
                          color: AppColors.divider,
                        ),
                        Expanded(
                          child: _buildRegimeSummary(
                            regimeTitle: 'OLD REGIME 📜',
                            taxAmount: currencyFormatter.format(oldTax),
                            isRecommended: !isNewCheaper,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isNewCheaper
                                ? Icons.auto_awesome
                                : Icons.savings_outlined,
                            color: isNewCheaper
                                ? AppColors.neonEmerald
                                : AppColors.neonCyan,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isNewCheaper
                                  ? 'New Regime saves you ${currencyFormatter.format(diff)} in taxes!'
                                  : 'Old Regime saves you ${currencyFormatter.format(diff)} with your deductions!',
                              style: TextStyle(
                                color: isNewCheaper
                                    ? AppColors.neonEmerald
                                    : AppColors.neonCyan,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Gross Annual Income Slider ────────────────────────────────
              _buildSliderCard(
                title: 'Gross Annual Income (CTC)',
                valueString: currencyFormatter.format(_grossIncome),
                currentValue: _grossIncome,
                min: 300000,
                max: 5000000,
                divisions: 94,
                accentColor: AppColors.neonEmerald,
                onChanged: (v) => setState(() => _grossIncome = v),
              ),

              const SizedBox(height: 20),

              // ─── Deductions Section (Old Regime) ───────────────────────────
              const Text(
                'Deductions (Applicable for Old Regime)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'New Regime includes standard ₹75,000 deduction automatically.',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),

              // 80C
              _buildSliderCard(
                title: 'Section 80C (PPF, ELSS, EPF, LIC)',
                valueString: currencyFormatter.format(_section80C),
                currentValue: _section80C,
                min: 0,
                max: 150000,
                divisions: 30,
                accentColor: AppColors.neonCyan,
                onChanged: (v) => setState(() => _section80C = v),
              ),

              const SizedBox(height: 12),

              // 80D
              _buildSliderCard(
                title: 'Section 80D (Health Insurance)',
                valueString: currencyFormatter.format(_section80D),
                currentValue: _section80D,
                min: 0,
                max: 50000,
                divisions: 10,
                accentColor: AppColors.cyberViolet,
                onChanged: (v) => setState(() => _section80D = v),
              ),

              const SizedBox(height: 12),

              // HRA / Home Loan
              _buildSliderCard(
                title: 'HRA / Home Loan Interest (Sec 24b)',
                valueString: currencyFormatter.format(_hraHomeLoan),
                currentValue: _hraHomeLoan,
                min: 0,
                max: 200000,
                divisions: 20,
                accentColor: AppColors.electricAmber,
                onChanged: (v) => setState(() => _hraHomeLoan = v),
              ),

              const SizedBox(height: 12),

              // NPS 80CCD(1B)
              _buildSliderCard(
                title: 'National Pension Scheme (80CCD 1B)',
                valueString: currencyFormatter.format(_nps80CCD),
                currentValue: _nps80CCD,
                min: 0,
                max: 50000,
                divisions: 10,
                accentColor: AppColors.hotPink,
                onChanged: (v) => setState(() => _nps80CCD = v),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegimeSummary({
    required String regimeTitle,
    required String taxAmount,
    required bool isRecommended,
    required Color color,
  }) {
    return Column(
      children: [
        if (isRecommended)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.5)),
            ),
            child: Text(
              'BEST OPTION ✨',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        else
          const SizedBox(height: 18),
        Text(
          regimeTitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          taxAmount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueString,
    required double currentValue,
    required double min,
    required double max,
    required int divisions,
    required Color accentColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                valueString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: accentColor,
              inactiveTrackColor: AppColors.surfaceElevated,
              thumbColor: Colors.white,
              overlayColor: accentColor.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: currentValue.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
