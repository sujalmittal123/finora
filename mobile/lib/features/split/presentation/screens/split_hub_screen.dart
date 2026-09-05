import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:finora/core/theme/app_colors.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class SplitHubScreen extends ConsumerStatefulWidget {
  const SplitHubScreen({super.key});

  @override
  ConsumerState<SplitHubScreen> createState() => _SplitHubScreenState();
}

class _SplitHubScreenState extends ConsumerState<SplitHubScreen> {
  int _selectedTab = 0; // 0 = FRIENDS, 1 = GROUPS, 2 = SETTLED

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final netBalance = finance.totalOwedToYou - finance.totalYouOwe;
    final isAllSettled = finance.friends.every((f) => f.isSettled || f.amountOwed == 0);

    String headerTitle = "You're all settled";
    if (!isAllSettled) {
      if (netBalance > 0) {
        headerTitle = 'You are owed ${currencyFormatter.format(netBalance)}';
      } else if (netBalance < 0) {
        headerTitle = 'You owe ${currencyFormatter.format(netBalance.abs())}';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header: Title + Action Icons (Refresh & Settings) ──────────
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      headerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorderSubtle),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.refresh,
                              color: AppColors.neonEmerald, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Balances refreshed with latest transactions'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.glassBorderSubtle),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.settings_outlined,
                              color: AppColors.neonEmerald, size: 20),
                          onPressed: () => _showSplitSettings(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Subheader: "+ Add Friend" & "+ Create Group" Buttons ──────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildSubActionPill(
                    icon: Icons.add,
                    label: 'Add Friend',
                    onTap: () => _showAddFriendDialog(context, ref),
                  ),
                  const SizedBox(width: 12),
                  _buildSubActionPill(
                    icon: Icons.add,
                    label: 'Create Group',
                    onTap: () => _showCreateGroupDialog(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Segmented Pill Tab Bar: [FRIENDS] [GROUPS] [SETTLED] ───────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Row(
                  children: [
                    _buildSegmentTab('FRIENDS', 0),
                    _buildSegmentTab('GROUPS', 1),
                    _buildSegmentTab('SETTLED', 2),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Tab View Body ──────────────────────────────────────────────
            Expanded(
              child: _buildTabContent(finance, currencyFormatter),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubActionPill({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassBorderSubtle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.neonEmerald, size: 16),
            const SizedBox(width: 6),
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
      ),
    );
  }

  Widget _buildSegmentTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD9D9D9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(FinanceState finance, NumberFormat currencyFormatter) {
    if (_selectedTab == 0) {
      // FRIENDS
      final activeFriends = finance.friends.where((f) => !f.isSettled).toList();
      if (activeFriends.isEmpty) {
        return _buildEmptyState(
          icon: Icons.person_outline,
          text:
              "You're all settled. Add friends and split expenses to track who owes what.",
        );
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: activeFriends.length,
        itemBuilder: (context, index) {
          final friend = activeFriends[index];
          final theyOweYou = friend.amountOwed > 0;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceElevated,
                  child: Text(
                    friend.avatarInitial,
                    style: const TextStyle(
                      color: AppColors.neonEmerald,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        friend.lastActivity,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      theyOweYou
                          ? '+${currencyFormatter.format(friend.amountOwed)}'
                          : '-${currencyFormatter.format(friend.amountOwed.abs())}',
                      style: TextStyle(
                        color: theyOweYou
                            ? AppColors.neonEmerald
                            : AppColors.neonCrimson,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(financeProvider.notifier)
                            .settleFriendDebt(friend.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Settled debt with ${friend.name} ✅'),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.neonEmerald.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Settle Up',
                          style: TextStyle(
                            color: AppColors.neonEmerald,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else if (_selectedTab == 1) {
      // GROUPS
      if (finance.groups.isEmpty) {
        return _buildEmptyState(
          icon: Icons.group_outlined,
          text: 'No active groups yet. Tap "+ Create Group" to start a trip or flat stash.',
        );
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: finance.groups.length,
        itemBuilder: (context, index) {
          final group = finance.groups[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.glassBorderSubtle),
            ),
            child: Row(
              children: [
                Text(group.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${group.memberNames.length} Members: ${group.memberNames.join(', ')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      currencyFormatter.format(group.totalSpend),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your share: ${currencyFormatter.format(group.yourShare)}',
                      style: const TextStyle(
                        color: AppColors.cyberViolet,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    } else {
      // SETTLED
      final settledFriends = finance.friends.where((f) => f.isSettled).toList();
      if (settledFriends.isEmpty) {
        return _buildEmptyState(
          icon: Icons.check_circle_outline,
          text: "No settled history yet. When you settle up with friends, they'll show here.",
        );
      }
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: settledFriends.length,
        itemBuilder: (context, index) {
          final f = settledFriends[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceElevated,
                  child: Text(f.avatarInitial,
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const Text(
                        'Settled all expenses',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '₹0.00',
                  style: TextStyle(
                      color: AppColors.textMuted, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String text,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceElevated,
                border: Border.all(color: AppColors.glassBorderSubtle),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

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
              'Add Friend to Split Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Friend Name (e.g. Aryan Sharma)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Initial Balance (Optional ₹)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                  if (name.isNotEmpty) {
                    ref.read(financeProvider.notifier).addFriend(
                          name: name,
                          initialAmount: amount,
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Add Friend'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final membersCtrl = TextEditingController();
    final spendCtrl = TextEditingController();

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
              'Create Split Group',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Group Name (e.g. Goa Trip 🏖️)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: membersCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Members (comma separated)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: spendCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Initial Total Spend (₹)',
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final members = membersCtrl.text
                      .split(',')
                      .map((m) => m.trim())
                      .where((m) => m.isNotEmpty)
                      .toList();
                  final spend = double.tryParse(spendCtrl.text.trim()) ?? 0.0;
                  if (name.isNotEmpty) {
                    ref.read(financeProvider.notifier).createGroup(
                          name: name,
                          emoji: '🏖️',
                          members: ['You', ...members],
                          initialSpend: spend,
                        );
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSplitSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Split Preferences',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.currency_rupee, color: AppColors.neonEmerald),
              title: const Text('Default Currency: INR (₹)',
                  style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined,
                  color: AppColors.cyberViolet),
              title: const Text('Settlement Reminders',
                  style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: true,
                onChanged: (_) {},
                activeColor: AppColors.neonEmerald,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
