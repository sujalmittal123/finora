import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finora/core/theme/app_colors.dart';
import 'package:finora/features/auth/presentation/providers/auth_provider.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final finance = ref.watch(financeProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final displayName = user?.displayName ?? 'Finora User';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Accounts & Profile 👤',
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
              // ─── User Profile Banner ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.surfaceElevated,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? const Icon(Icons.person,
                              color: AppColors.neonEmerald, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email.isNotEmpty ? email : 'Google Account Linked',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.neonEmerald
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified Firebase Auth ✅',
                              style: TextStyle(
                                color: AppColors.neonEmerald,
                                fontSize: 10,
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

              // ─── Liquid Net Worth Summary ──────────────────────────────────
              const Text(
                'PAYMENT STASHES & CARDS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              _buildAccountCard(
                icon: '🏦',
                title: 'HDFC Bank (UPI Primary)',
                subtitle: 'Active for daily taps',
                balance: currencyFormatter.format(finance.totalBalance),
                isDefault: true,
              ),
              _buildAccountCard(
                icon: '💳',
                title: 'OneCard Metal Credit',
                subtitle: 'Dopamine shopping limit',
                balance: currencyFormatter.format(8500),
                isDefault: false,
              ),
              _buildAccountCard(
                icon: '💵',
                title: 'Physical Cash Stash',
                subtitle: 'Emergency wallet',
                balance: currencyFormatter.format(3800),
                isDefault: false,
              ),

              const SizedBox(height: 24),

              // ─── Settings & Sign Out ──────────────────────────────────────
              const Text(
                'PREFERENCES & APP',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Text('🌙', style: TextStyle(fontSize: 20)),
                      title: const Text(
                        'Obsidian Dark Theme',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Text(
                        'Always Active',
                        style: TextStyle(
                          color: AppColors.neonEmerald,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Text('🤖', style: TextStyle(fontSize: 20)),
                      title: const Text(
                        'Nova AI Financial Engine',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      trailing: const Text(
                        'v1.0 Enabled',
                        style: TextStyle(
                          color: AppColors.cyberViolet,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout,
                          color: AppColors.neonCrimson),
                      title: const Text(
                        'Sign Out',
                        style: TextStyle(
                          color: AppColors.neonCrimson,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onTap: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required String icon,
    required String title,
    required String subtitle,
    required String balance,
    required bool isDefault,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault
              ? AppColors.neonEmerald.withValues(alpha: 0.3)
              : AppColors.glassBorderSubtle,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
