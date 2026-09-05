import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';

class FdRdCalculatorScreen extends StatefulWidget {
  const FdRdCalculatorScreen({super.key});

  @override
  State<FdRdCalculatorScreen> createState() => _FdRdCalculatorScreenState();
}

class _FdRdCalculatorScreenState extends State<FdRdCalculatorScreen> {
  int _mode = 0; // 0 = FD (Fixed Deposit), 1 = RD (Recurring Deposit)
  double _depositAmount = 100000;
  double _interestRate = 7.1;
  int _tenureYears = 3;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    // FD Formula: A = P * (1 + r/n)^(n*t) with quarterly compounding (n=4)
    // RD Formula: A = P * ((1 + i)^n - 1) / (1 - (1+i)^(-1/3))
    double investedAmount = 0;
    double maturityAmount = 0;

    if (_mode == 0) {
      // FD
      investedAmount = _depositAmount;
      const n = 4.0; // quarterly compounding
      final r = _interestRate / 100;
      final t = _tenureYears.toDouble();
      maturityAmount = investedAmount * math.pow(1 + (r / n), n * t);
    } else {
      // RD (Monthly deposit for tenureYears * 12 months)
      final totalMonths = _tenureYears * 12;
      investedAmount = _depositAmount * totalMonths;
      final r = _interestRate / 100;
      // Standard quarterly compounding formula for recurring deposits
      double sum = 0;
      for (int i = 1; i <= totalMonths; i++) {
        final remainingYears = (totalMonths - i + 1) / 12.0;
        sum += _depositAmount * math.pow(1 + (r / 4.0), 4.0 * remainingYears);
      }
      maturityAmount = sum;
    }

    final totalReturns = maturityAmount - investedAmount;
    final gainRatio =
        maturityAmount > 0 ? (totalReturns / maturityAmount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'FD / RD Calculator 🏦',
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
              // ─── Mode Segmented Control: [Fixed Deposit] [Recurring Deposit]
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildModeToggle('Fixed Deposit (FD)', 0),
                    _buildModeToggle('Recurring Deposit (RD)', 1),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Output Summary Card ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF13221B),
                      Color(0xFF0D141E),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.neonEmerald.withValues(alpha: 0.35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonEmerald.withValues(alpha: 0.1),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL MATURITY VALUE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormatter.format(maturityAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildOutputMetric(
                          label: 'Total Invested',
                          value: currencyFormatter.format(investedAmount),
                          color: AppColors.neonCyan,
                        ),
                        _buildOutputMetric(
                          label: 'Est. Wealth Return',
                          value: '+${currencyFormatter.format(totalReturns)}',
                          color: AppColors.neonEmerald,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: 1.0 - gainRatio,
                        minHeight: 7,
                        backgroundColor: AppColors.neonEmerald,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.neonCyan),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Input Sliders ─────────────────────────────────────────────
              _buildSliderInput(
                title: _mode == 0 ? 'Total Deposit Amount' : 'Monthly Deposit Amount',
                valueString: currencyFormatter.format(_depositAmount),
                currentValue: _depositAmount,
                min: _mode == 0 ? 10000 : 1000,
                max: _mode == 0 ? 1000000 : 50000,
                divisions: _mode == 0 ? 99 : 49,
                onChanged: (val) => setState(() => _depositAmount = val),
              ),

              const SizedBox(height: 16),

              _buildSliderInput(
                title: 'Interest Rate (% p.a.)',
                valueString: '${_interestRate.toStringAsFixed(1)}%',
                currentValue: _interestRate,
                min: 4.0,
                max: 10.0,
                divisions: 60,
                onChanged: (val) => setState(() => _interestRate = val),
              ),

              const SizedBox(height: 16),

              _buildSliderInput(
                title: 'Time Period (Tenure)',
                valueString: '$_tenureYears Years (${_tenureYears * 12} Months)',
                currentValue: _tenureYears.toDouble(),
                min: 1.0,
                max: 10.0,
                divisions: 9,
                onChanged: (val) => setState(() => _tenureYears = val.toInt()),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle(String title, int index) {
    final isSelected = _mode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _mode = index;
          _depositAmount = index == 0 ? 100000 : 5000;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonEmerald : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutputMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderInput({
    required String title,
    required String valueString,
    required double currentValue,
    required double min,
    required double max,
    required int divisions,
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
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                valueString,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.neonEmerald,
              inactiveTrackColor: AppColors.surfaceElevated,
              thumbColor: Colors.white,
              overlayColor: AppColors.neonEmerald.withValues(alpha: 0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              value: currentValue,
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
