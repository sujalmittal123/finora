import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finora/core/theme/app_colors.dart';
import 'package:finora/features/auth/presentation/providers/auth_provider.dart';
import 'package:finora/features/auth/presentation/providers/guest_provider.dart';
import 'package:finora/features/auth/presentation/providers/profile_provider.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  static const _accountTypes = ['Bank', 'Cash', 'UPI', 'Credit Card'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final finance = ref.watch(financeProvider);
    final profile = ref.watch(profileProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final displayName = profile.name.isNotEmpty
        ? profile.name
        : (user?.displayName ?? 'Finora User');
    final photoUrl = profile.photoUrl.isNotEmpty
        ? profile.photoUrl
        : user?.photoURL;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.neonEmerald),
            onPressed: () => _showAddAccountSheet(context, ref),
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
                      onBackgroundImageError: photoUrl != null ? (_, __) {} : null,
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
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.neonEmerald
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.neonEmerald.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Text(
                              'Verified Member ✅',
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
                    IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          color: AppColors.neonEmerald, size: 20),
                      tooltip: 'Edit profile',
                      onPressed: () => _showEditProfileSheet(context, ref, profile),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─── Accounts ──────────────────────────────────────────────────
              const Text(
                'YOUR ACCOUNTS',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              if (finance.accounts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Text('🏦', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 10),
                      const Text(
                        'No accounts yet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap + to add your bank accounts, cash, or cards.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...finance.accounts.map((account) {
                  final icon = switch (account.type) {
                    'Cash' => '💵',
                    'UPI' => '📱',
                    'Credit Card' => '💳',
                    _ => '🏦',
                  };
                  return _buildAccountCard(
                    icon: icon,
                    title: account.name,
                    subtitle: account.isDefault
                        ? '${account.type} · Default'
                        : account.type,
                    balance:
                        currencyFormatter.format(account.balance),
                    isDefault: account.isDefault,
                    onDelete: () => _confirmDeleteAccount(
                        context, ref, account.id, account.name),
                  );
                }),

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
                        if (ref.read(guestModeProvider)) {
                          ref.read(guestModeProvider.notifier).exitGuestMode();
                        } else {
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signOut();
                        }
                      },
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

  void _showEditProfileSheet(
      BuildContext context, WidgetRef ref, ProfileData profile) {
    final nameCtrl = TextEditingController(
        text: profile.name.isNotEmpty ? profile.name : '');
    final photoCtrl = TextEditingController(text: profile.photoUrl);

    showModalBottomSheet(useRootNavigator: true, 
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Edit Profile ✏️',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Your name',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.person_outline,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: photoCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Photo URL (optional)',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.image_outlined,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.surfaceCard,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final photoUrl = photoCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Enter your name')),
                    );
                    return;
                  }
                  ref.read(profileProvider.notifier).updateProfile(
                        name: name,
                        photoUrl: photoUrl,
                      );
                  ref.read(authServiceProvider).updateProfile(
                        name: name,
                        photoUrl: photoUrl,
                      );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonEmerald,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    String type = 'Bank';
    bool isDefault = false;

    showModalBottomSheet(useRootNavigator: true, 
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Add Account 🏦',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Account name (e.g. HDFC Savings)',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.account_balance,
                      color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: AppColors.surfaceElevated,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _accountTypes.map((t) {
                  return DropdownMenuItem(value: t, child: Text(t));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setSheetState(() => type = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: balanceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Current balance (₹)',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.currency_rupee,
                      color: AppColors.textMuted, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Set as default',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                activeTrackColor: AppColors.neonEmerald,
                value: isDefault,
                onChanged: (v) => setSheetState(() => isDefault = v),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Enter an account name')),
                      );
                      return;
                    }
                    final balance =
                        double.tryParse(balanceCtrl.text.trim()) ?? 0.0;
                    ref.read(financeProvider.notifier).addAccount(
                          name: name,
                          type: type,
                          balance: balance,
                          isDefault: isDefault,
                        );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonEmerald,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Save Account',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount(
      BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(useRootNavigator: true, 
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: const Text(
          'Delete account?',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: Text(
          'Remove "$name"? Your transactions will stay but this account will no longer be listed.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(financeProvider.notifier).deleteAccount(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.neonCrimson)),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard({
    required String icon,
    required String title,
    required String subtitle,
    required String balance,
    required bool isDefault,
    required VoidCallback onDelete,
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
          Row(
            children: [
              Text(
                balance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.neonCrimson, size: 18),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
