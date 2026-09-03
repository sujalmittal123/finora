import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:finora/core/theme/app_colors.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final finance = ref.watch(financeProvider);
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');

    var list = finance.transactions;
    if (_selectedFilter == 'Expenses') {
      list = list.where((t) => t.isExpense).toList();
    } else if (_selectedFilter == 'Income') {
      list = list.where((t) => !t.isExpense).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Transactions 💸',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.neonEmerald),
            onPressed: () => context.go('/transactions/add'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: ['All', 'Expenses', 'Income'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                      backgroundColor: AppColors.surfaceCard,
                      selectedColor: AppColors.neonEmerald.withValues(alpha: 0.2),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.neonEmerald
                            : AppColors.glassBorder,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      label: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.neonEmerald
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Transactions List
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('💸', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'No $_selectedFilter transactions yet',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final tx = list[index];
                        return Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.neonCrimson,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            ref
                                .read(financeProvider.notifier)
                                .deleteTransaction(tx.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${tx.title}"'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    ref
                                        .read(financeProvider.notifier)
                                        .addTransaction(
                                          title: tx.title,
                                          amount: tx.amount,
                                          category: tx.category,
                                          isExpense: tx.isExpense,
                                          accountName: tx.accountName,
                                          splitWith: tx.splitWith,
                                        );
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: AppColors.glassBorderSubtle),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tx.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
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
                                      if (tx.splitWith != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '👥 ${tx.splitWith}',
                                          style: const TextStyle(
                                            color: AppColors.cyberViolet,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  '${tx.isExpense ? '-' : '+'}₹${tx.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: tx.isExpense
                                        ? AppColors.neonCrimson
                                        : AppColors.neonEmerald,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
