import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/financial_models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/finance_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final finance = ref.watch(financeProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final displayName = user?.displayName ?? 'Operator';
    final firstName = displayName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Holographic Top Header ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showProfileMenu(context, ref),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.neonEmerald,
                                  AppColors.neonCyan,
                                  AppColors.cyberViolet,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.neonEmerald
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.surfaceElevated,
                              child: Text(
                                firstName.isNotEmpty
                                    ? firstName[0].toUpperCase()
                                    : 'F',
                                style: const TextStyle(
                                  color: AppColors.neonEmerald,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.neonEmerald,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'TELEMETRY LIVE',
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
                            const SizedBox(height: 2),
                            Text(
                              'gm, ${firstName.toLowerCase()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Money Aura Streak Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.electricAmber.withValues(alpha: 0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.electricAmber.withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(
                            '${finance.streakDays}d Streak',
                            style: const TextStyle(
                              color: AppColors.electricAmber,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── 3D Holographic Safe-to-Spend Balance Dial ───────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF141926),
                        Color(0xFF0C0E17),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.neonEmerald.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonEmerald.withValues(alpha: 0.12),
                        blurRadius: 36,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Hologram Ambient Glow Painter
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _HolographicDialGridPainter(),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.neonEmerald
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'DAILY QUANTUM TARGET',
                                        style: TextStyle(
                                          color: AppColors.neonEmerald,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyberViolet
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '✨ God-Tier Velocity',
                                    style: TextStyle(
                                      color: AppColors.cyberViolet,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Currency Main Dial Number
                            Text(
                              currencyFormatter.format(finance.safeToSpendToday),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 44,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.8,
                                height: 1.0,
                                shadows: [
                                  Shadow(
                                    color: AppColors.neonEmerald,
                                    blurRadius: 28,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            Row(
                              children: [
                                const Text(
                                  'SAFE TO SPEND TODAY',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '₹${finance.todaySpent.toStringAsFixed(0)} spent',
                                  style: const TextStyle(
                                    color: AppColors.neonCrimson,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Mini Hologram Telemetry Stats
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: AppColors.glassBorderSubtle),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildHoloStat(
                                    label: 'Total Liquid Stash',
                                    value: currencyFormatter
                                        .format(finance.totalBalance),
                                    color: AppColors.neonCyan,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: AppColors.divider,
                                  ),
                                  _buildHoloStat(
                                    label: 'Burn Velocity',
                                    value: currencyFormatter
                                        .format(finance.monthlyExpenses),
                                    color: AppColors.neonCrimson,
                                  ),
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: AppColors.divider,
                                  ),
                                  _buildHoloStat(
                                    label: 'Monthly Target',
                                    value: currencyFormatter
                                        .format(finance.monthlyBudget),
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Living Nova AI Twin Banner (Interactive Executable) ────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1E1438),
                        Color(0xFF0F111E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.cyberViolet.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyberViolet.withValues(alpha: 0.12),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.aiMagicGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyberViolet
                                      .withValues(alpha: 0.5),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text('🔮', style: TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOVA AI PREDICTIVE TWIN',
                                  style: TextStyle(
                                    color: AppColors.cyberViolet,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'You\'re ₹320 under budget today! Lock ₹300 into Goa Vault now to finish 4 days early.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ref
                                    .read(financeProvider.notifier)
                                    .depositToVault('vault-2', 300);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.surfaceCard,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                    content: const Text(
                                      '⚡ Stashed ₹300 into Goa Vault! Nova predictive target updated.',
                                      style: TextStyle(
                                        color: AppColors.neonEmerald,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.flash_on,
                                  size: 16, color: Colors.black),
                              label: const Text('Execute: Stash ₹300 ⚡'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.neonEmerald,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => context.go('/ai-assistant'),
                            icon: const Icon(Icons.arrow_forward_rounded,
                                color: AppColors.cyberViolet),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceElevated,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Quantum Quick-Vibe Action Dock ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUANTUM QUICK-LOG ⚡',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildQuickVibeCapsule(
                            context: context,
                            ref: ref,
                            emoji: '☕',
                            label: 'Caffeine',
                            amount: 250,
                            category: VibeCategory.caffeine,
                            accentColor: AppColors.neonEmerald,
                          ),
                          _buildQuickVibeCapsule(
                            context: context,
                            ref: ref,
                            emoji: '🚕',
                            label: 'Late Cab',
                            amount: 320,
                            category: VibeCategory.lateRides,
                            accentColor: AppColors.neonCyan,
                          ),
                          _buildQuickVibeCapsule(
                            context: context,
                            ref: ref,
                            emoji: '🛍️',
                            label: 'Dopamine',
                            amount: 1200,
                            category: VibeCategory.dopamine,
                            accentColor: AppColors.cyberViolet,
                          ),
                          _buildQuickVibeCapsule(
                            context: context,
                            ref: ref,
                            emoji: '🍕',
                            label: 'Midnight Craving',
                            amount: 450,
                            category: VibeCategory.midnightCraving,
                            accentColor: AppColors.neonCrimson,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Vampire Subscription Sonar Radar ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.electricAmber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _radarController,
                                builder: (context, child) {
                                  return Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.electricAmber,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.electricAmber
                                              .withValues(
                                                  alpha: 0.8 *
                                                      (1 -
                                                          _radarController
                                                              .value)),
                                          blurRadius:
                                              12 * _radarController.value,
                                          spreadRadius:
                                              6 * _radarController.value,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'VAMPIRE SUBSCRIPTION RADAR 🧛',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${finance.subscriptions.length} Active Debits',
                            style: const TextStyle(
                              color: AppColors.electricAmber,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: finance.subscriptions.map((sub) {
                            final isUrgent = sub.daysRemaining <= 3;
                            return Container(
                              width: 165,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isUrgent
                                      ? AppColors.electricAmber
                                      : AppColors.glassBorderSubtle,
                                  width: isUrgent ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(sub.iconEmoji,
                                          style: const TextStyle(fontSize: 22)),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isUrgent
                                              ? AppColors.electricAmber
                                                  .withValues(alpha: 0.2)
                                              : Colors.white
                                                  .withValues(alpha: 0.05),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'in ${sub.daysRemaining}d',
                                          style: TextStyle(
                                            color: isUrgent
                                                ? AppColors.electricAmber
                                                : AppColors.textMuted,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    sub.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '₹${sub.amount.toStringAsFixed(0)}/${sub.billingPeriod == 'Monthly' ? 'mo' : 'yr'}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Recent Telemetry Activity Header ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RECENT TELEMETRY FEED',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/transactions'),
                      child: const Text(
                        'View all →',
                        style: TextStyle(
                          color: AppColors.neonEmerald,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Activity List ──────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final tx = finance.transactions[index];
                    return _buildTransactionTile(tx);
                  },
                  childCount: finance.transactions.length > 5
                      ? 5
                      : finance.transactions.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 110),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHoloStat({
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
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickVibeCapsule({
    required BuildContext context,
    required WidgetRef ref,
    required String emoji,
    required String label,
    required double amount,
    required VibeCategory category,
    required Color accentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          ref.read(financeProvider.notifier).addTransaction(
                title: '$emoji $label Quick Add',
                amount: amount,
                category: category,
                isExpense: true,
                accountName: 'UPI',
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.surfaceCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              content: Text(
                'Logged ₹${amount.toStringAsFixed(0)} for $label $emoji',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₹${amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(TransactionItem tx) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                tx.category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dateFormat.format(tx.date)} · ${tx.accountName}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${tx.isExpense ? '-' : '+'}₹${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(
              color:
                  tx.isExpense ? AppColors.neonCrimson : AppColors.neonEmerald,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context, WidgetRef ref) {
    final user = ref.read(authStateProvider).valueOrNull;
    final displayName = user?.displayName ?? 'Finora Operator';
    final firstName = displayName.split(' ').first;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 34,
              backgroundColor: AppColors.surfaceElevated,
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : 'F',
                style: const TextStyle(
                  color: AppColors.neonEmerald,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'Google Account Verified',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.neonCrimson),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.neonCrimson,
                  fontWeight: FontWeight.w800,
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Painter for Dial Hologram Grid Lines ─────────────────────────────
class _HolographicDialGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.neonEmerald.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
