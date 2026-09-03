import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/financial_models.dart';

class FinanceState {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyBudget;
  final int streakDays;
  final List<TransactionItem> transactions;
  final List<SubscriptionItem> subscriptions;
  final List<SavingsVault> vaults;

  const FinanceState({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyBudget,
    required this.streakDays,
    required this.transactions,
    required this.subscriptions,
    required this.vaults,
  });

  // Calculate today's spent amount from today's expense transactions
  double get todaySpent {
    final now = DateTime.now();
    return transactions
        .where((tx) =>
            tx.isExpense &&
            tx.date.year == now.year &&
            tx.date.month == now.month &&
            tx.date.day == now.day)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Calculate Safe to Spend Today: (Monthly Budget - Total Month Expenses) / Days left in Month
  double get safeToSpendToday {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = (daysInMonth - now.day) + 1;

    final thisMonthExpenses = transactions
        .where((tx) =>
            tx.isExpense &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    final remainingBudget = monthlyBudget - thisMonthExpenses;
    if (remainingBudget <= 0) return 0.0;

    final dailyTarget = remainingBudget / (daysLeft > 0 ? daysLeft : 1);
    final remainingForToday = dailyTarget - todaySpent;
    return remainingForToday > 0 ? remainingForToday : 0.0;
  }

  // Total monthly expenses
  double get monthlyExpenses {
    final now = DateTime.now();
    return transactions
        .where((tx) =>
            tx.isExpense &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  // Flex (Wants) vs Frugal (Needs) breakdown ratio (0.0 to 1.0)
  double get flexRatio {
    if (monthlyExpenses <= 0) return 0.35;
    final flexExpenses = transactions
        .where((tx) =>
            tx.isExpense &&
            (tx.category == VibeCategory.dopamine ||
                tx.category == VibeCategory.caffeine ||
                tx.category == VibeCategory.gamingSubs ||
                tx.category == VibeCategory.midnightCraving))
        .fold(0.0, (sum, tx) => sum + tx.amount);
    return flexExpenses / monthlyExpenses;
  }

  FinanceState copyWith({
    double? totalBalance,
    double? monthlyIncome,
    double? monthlyBudget,
    int? streakDays,
    List<TransactionItem>? transactions,
    List<SubscriptionItem>? subscriptions,
    List<SavingsVault>? vaults,
  }) {
    return FinanceState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      streakDays: streakDays ?? this.streakDays,
      transactions: transactions ?? this.transactions,
      subscriptions: subscriptions ?? this.subscriptions,
      vaults: vaults ?? this.vaults,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  FinanceNotifier() : super(_initialMockData());

  static FinanceState _initialMockData() {
    final now = DateTime.now();
    return FinanceState(
      totalBalance: 48500.00,
      monthlyIncome: 65000.00,
      monthlyBudget: 42000.00,
      streakDays: 8,
      transactions: [
        TransactionItem(
          id: 'tx-1',
          title: 'Blue Tokai Cold Brew',
          amount: 280.00,
          date: now.subtract(const Duration(hours: 2)),
          category: VibeCategory.caffeine,
          accountName: 'HDFC UPI',
        ),
        TransactionItem(
          id: 'tx-2',
          title: 'Uber to Office Hub',
          amount: 340.00,
          date: now.subtract(const Duration(hours: 5)),
          category: VibeCategory.lateRides,
          accountName: 'Credit Card',
        ),
        TransactionItem(
          id: 'tx-3',
          title: 'Steam Sale: Elden Ring',
          amount: 1499.00,
          date: now.subtract(const Duration(days: 1, hours: 3)),
          category: VibeCategory.gamingSubs,
          accountName: 'Main Account',
        ),
        TransactionItem(
          id: 'tx-4',
          title: 'Freelance Design Milestone',
          amount: 18500.00,
          date: now.subtract(const Duration(days: 2)),
          category: VibeCategory.salary,
          isExpense: false,
          accountName: 'Main Account',
        ),
        TransactionItem(
          id: 'tx-5',
          title: 'Midnight Pizza with Gang',
          amount: 890.00,
          date: now.subtract(const Duration(days: 3)),
          category: VibeCategory.midnightCraving,
          splitWith: 'Aryan, Tanya',
          accountName: 'HDFC UPI',
        ),
        TransactionItem(
          id: 'tx-6',
          title: 'Zara Oversized Tee',
          amount: 2290.00,
          date: now.subtract(const Duration(days: 4)),
          category: VibeCategory.dopamine,
          accountName: 'Credit Card',
        ),
      ],
      subscriptions: [
        SubscriptionItem(
          id: 'sub-1',
          name: 'Netflix 4K Ultra',
          amount: 649.00,
          billingPeriod: 'Monthly',
          nextBillingDate: now.add(const Duration(days: 2)),
          iconEmoji: '🎬',
        ),
        SubscriptionItem(
          id: 'sub-2',
          name: 'Spotify Premium Duo',
          amount: 149.00,
          billingPeriod: 'Monthly',
          nextBillingDate: now.add(const Duration(days: 6)),
          iconEmoji: '🎧',
        ),
        SubscriptionItem(
          id: 'sub-3',
          name: 'Cult.fit Gym & Yoga',
          amount: 1800.00,
          billingPeriod: 'Monthly',
          nextBillingDate: now.add(const Duration(days: 14)),
          iconEmoji: '💪',
        ),
        SubscriptionItem(
          id: 'sub-4',
          name: 'ChatGPT Plus Sub',
          amount: 1999.00,
          billingPeriod: 'Monthly',
          nextBillingDate: now.add(const Duration(days: 19)),
          iconEmoji: '🤖',
        ),
      ],
      vaults: [
        SavingsVault(
          id: 'vault-1',
          title: 'Sony WH-1000XM5 ANC',
          targetAmount: 26990.00,
          currentAmount: 19500.00,
          emoji: '🎧',
          targetDate: now.add(const Duration(days: 45)),
        ),
        SavingsVault(
          id: 'vault-2',
          title: 'Goa Weekend Trip 🏖️',
          targetAmount: 35000.00,
          currentAmount: 21000.00,
          emoji: '✈️',
          targetDate: now.add(const Duration(days: 60)),
        ),
        SavingsVault(
          id: 'vault-3',
          title: 'M3 Pro MacBook Stash',
          targetAmount: 149000.00,
          currentAmount: 68000.00,
          emoji: '💻',
          targetDate: now.add(const Duration(days: 180)),
        ),
      ],
    );
  }

  void addTransaction({
    required String title,
    required double amount,
    required VibeCategory category,
    required bool isExpense,
    String accountName = 'Main Account',
    String? splitWith,
  }) {
    final newTx = TransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
      isExpense: isExpense,
      accountName: accountName,
      splitWith: splitWith,
    );

    final updatedTransactions = [newTx, ...state.transactions];
    final updatedBalance = isExpense
        ? state.totalBalance - amount
        : state.totalBalance + amount;

    state = state.copyWith(
      transactions: updatedTransactions,
      totalBalance: updatedBalance,
    );
  }

  void deleteTransaction(String id) {
    final txToDelete = state.transactions.firstWhere((tx) => tx.id == id);
    final updatedList = state.transactions.where((tx) => tx.id != id).toList();
    final updatedBalance = txToDelete.isExpense
        ? state.totalBalance + txToDelete.amount
        : state.totalBalance - txToDelete.amount;

    state = state.copyWith(
      transactions: updatedList,
      totalBalance: updatedBalance,
    );
  }

  void depositToVault(String vaultId, double amount) {
    final updatedVaults = state.vaults.map((vault) {
      if (vault.id == vaultId) {
        return vault.copyWith(
          currentAmount: vault.currentAmount + amount,
        );
      }
      return vault;
    }).toList();

    state = state.copyWith(
      vaults: updatedVaults,
      totalBalance: state.totalBalance - amount,
    );
  }

  void createVault({
    required String title,
    required double targetAmount,
    required String emoji,
    required int daysToTarget,
  }) {
    final newVault = SavingsVault(
      id: 'vault-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      targetAmount: targetAmount,
      currentAmount: 0.0,
      emoji: emoji,
      targetDate: DateTime.now().add(Duration(days: daysToTarget)),
    );

    state = state.copyWith(
      vaults: [...state.vaults, newVault],
    );
  }
}

final financeProvider =
    StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier();
});
