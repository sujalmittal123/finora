import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _timeMachineDays = 14;
  int _selectedChartType = 0; // 0 = 3D Cyber Curve, 1 = 3D Isometric Bars

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final flexPercentage = (finance.flexRatio * 100).round();
    final needsPercentage = 100 - flexPercentage;

    // Time Machine calculation: projected balance = current balance - (daily burn * days)
    final dailyBurn = finance.monthlyExpenses / 30;
    final projectedBalance =
        finance.totalBalance - (dailyBurn * _timeMachineDays);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Row(
          children: [
            Text(
              'Spend Telemetry & 3D Burn 📈',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── 3D Holographic Burn Overview Card ────────────────────────
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF161A28),
                      Color(0xFF0D0F18),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'REAL-TIME BURN VELOCITY',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),

                          // Toggle: Curve vs Bars
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                _buildChartToggle('3D Curve', 0),
                                _buildChartToggle('3D Bars', 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currencyFormatter.format(finance.monthlyExpenses),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monthly target ceiling: ${currencyFormatter.format(finance.monthlyBudget)}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Chart Render Area
                      SizedBox(
                        height: 190,
                        child: _selectedChartType == 0
                            ? _build3DCyberCurveChart()
                            : _build3DDepthBarChart(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ─── 🔮 Interactive Cashflow Time Machine ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF221334),
                      Color(0xFF0F101A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.cyberViolet.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyberViolet.withValues(alpha: 0.12),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🔮', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 8),
                            Text(
                              'CASHFLOW TIME MACHINE',
                              style: TextStyle(
                                color: AppColors.cyberViolet,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cyberViolet.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+$_timeMachineDays Days Out',
                            style: const TextStyle(
                              color: AppColors.cyberViolet,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Projected Liquid Stash: ${currencyFormatter.format(projectedBalance > 0 ? projectedBalance : 0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Simulating daily burn rate of ₹${dailyBurn.toStringAsFixed(0)}/day',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: AppColors.cyberViolet,
                        inactiveTrackColor: AppColors.surfaceElevated,
                        thumbColor: AppColors.neonCyan,
                        overlayColor:
                            AppColors.cyberViolet.withValues(alpha: 0.2),
                        trackHeight: 5,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _timeMachineDays.toDouble(),
                        min: 3,
                        max: 45,
                        divisions: 42,
                        onChanged: (val) {
                          setState(() => _timeMachineDays = val.toInt());
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── 3D Holographic Flex vs. Needs Rings ───────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HOLOGRAPHIC FLEX VS. NEEDS GAUGES',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Concentric Progress Arc Visual
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: flexPercentage / 100,
                                strokeWidth: 8,
                                backgroundColor: AppColors.surfaceElevated,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.cyberViolet),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  value: needsPercentage / 100,
                                  strokeWidth: 6,
                                  backgroundColor: AppColors.surfaceElevated,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.neonEmerald),
                                ),
                              ),
                              Center(
                                child: Text(
                                  '$flexPercentage%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGaugeLegendRow(
                                color: AppColors.cyberViolet,
                                label: 'Flex / Dopamine',
                                pct: '$flexPercentage%',
                              ),
                              const SizedBox(height: 8),
                              _buildGaugeLegendRow(
                                color: AppColors.neonEmerald,
                                label: 'Essentials & Needs',
                                pct: '$needsPercentage%',
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Gen-Z Target: 50% Needs · 30% Flex · 20% Vaults',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ─── Top Spending Vibes Breakdown ─────────────────────────────
              const Text(
                'TOP SPENDING VIBE TELEMETRY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildCategoryRow('🛍️', 'Dopamine Shopping', '₹2,290', 0.42,
                  AppColors.cyberViolet),
              _buildCategoryRow('🎮', 'Gaming & Digital Subs', '₹1,499', 0.28,
                  AppColors.electricAmber),
              _buildCategoryRow('🍕', 'Midnight Cravings', '₹890', 0.16,
                  AppColors.neonCrimson),
              _buildCategoryRow(
                  '🚕', 'Late Cabs', '₹340', 0.08, AppColors.neonCyan),
              _buildCategoryRow('☕', 'Caffeine & Cold Brews', '₹280', 0.06,
                  AppColors.neonEmerald),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartToggle(String title, int typeIndex) {
    final isSelected = _selectedChartType == typeIndex;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = typeIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.neonCyan : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _build3DCyberCurveChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 4000,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceElevated,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '₹${spot.y.toStringAsFixed(0)}',
                  const TextStyle(
                    color: AppColors.neonEmerald,
                    fontWeight: FontWeight.w900,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 1200),
              FlSpot(1, 1850),
              FlSpot(2, 600),
              FlSpot(3, 2400),
              FlSpot(4, 950),
              FlSpot(5, 3100),
              FlSpot(6, 1400),
            ],
            isCurved: true,
            curveSmoothness: 0.45,
            color: AppColors.neonCyan,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4.5,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: AppColors.neonCyan,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.35),
                  AppColors.neonCyan.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DDepthBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 4000,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _buildDepthBarGroup(0, 1200, AppColors.neonEmerald),
          _buildDepthBarGroup(1, 1850, AppColors.neonEmerald),
          _buildDepthBarGroup(2, 600, AppColors.neonEmerald),
          _buildDepthBarGroup(3, 2400, AppColors.neonCrimson),
          _buildDepthBarGroup(4, 950, AppColors.neonEmerald),
          _buildDepthBarGroup(5, 3100, AppColors.neonCrimson),
          _buildDepthBarGroup(6, 1400, AppColors.neonEmerald),
        ],
      ),
    );
  }

  BarChartGroupData _buildDepthBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color,
              color.withValues(alpha: 0.35),
            ],
          ),
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 4000,
            color: AppColors.surfaceElevated,
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeLegendRow({
    required Color color,
    required String label,
    required String pct,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Text(
          pct,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(
      String emoji, String label, String amount, double pct, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
