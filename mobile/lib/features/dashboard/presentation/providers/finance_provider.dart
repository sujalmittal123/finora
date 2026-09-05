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
  final List<FriendItem> friends;
  final List<SplitGroup> groups;
  final List<EmiItem> emis;
  final List<PaymentMethodItem> paymentMethods;

  const FinanceState({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyBudget,
    required this.streakDays,
    required this.transactions,
    required this.subscriptions,
    required this.vaults,
    required this.friends,
    required this.groups,
    required this.emis,
    required this.paymentMethods,
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

  // Remaining budget
  double get remainingMonthlyBudget {
    final rem = monthlyBudget - monthlyExpenses;
    return rem > 0 ? rem : 0.0;
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

  // Total amount you are owed across all unsettled friends
  double get totalOwedToYou {
    return friends
        .where((f) => !f.isSettled && f.amountOwed > 0)
        .fold(0.0, (sum, f) => sum + f.amountOwed);
  }

  // Total amount you owe across all unsettled friends
  double get totalYouOwe {
    return friends
        .where((f) => !f.isSettled && f.amountOwed < 0)
        .fold(0.0, (sum, f) => sum + f.amountOwed.abs());
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
    List<FriendItem>? friends,
    List<SplitGroup>? groups,
    List<EmiItem>? emis,
    List<PaymentMethodItem>? paymentMethods,
  }) {
    return FinanceState(
      totalBalance: totalBalance ?? this.totalBalance,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      streakDays: streakDays ?? this.streakDays,
      transactions: transactions ?? this.transactions,
      subscriptions: subscriptions ?? this.subscriptions,
      vaults: vaults ?? this.vaults,
      friends: friends ?? this.friends,
      groups: groups ?? this.groups,
      emis: emis ?? this.emis,
      paymentMethods: paymentMethods ?? this.paymentMethods,
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
      friends: [
        FriendItem(
          id: 'friend-1',
          name: 'Aryan Sharma',
          avatarInitial: 'A',
          amountOwed: 450.00, // Aryan owes user ₹450
          lastActivity: 'Midnight Pizza split',
        ),
        FriendItem(
          id: 'friend-2',
          name: 'Tanya Mehta',
          avatarInitial: 'T',
          amountOwed: -220.00, // User owes Tanya ₹220
          lastActivity: 'Blue Tokai cold brew',
        ),
        FriendItem(
          id: 'friend-3',
          name: 'Rohan Verma',
          avatarInitial: 'R',
          amountOwed: 890.00,
          lastActivity: 'Elden Ring DLC pass',
        ),
      ],
      groups: [
        SplitGroup(
          id: 'grp-1',
          name: 'Goa Weekend Gang 🏖️',
          emoji: '🏖️',
          totalSpend: 18400.00,
          yourShare: 4600.00,
          memberNames: ['You', 'Aryan', 'Tanya', 'Rohan'],
        ),
        SplitGroup(
          id: 'grp-2',
          name: 'Flat 402 Utilities 🏠',
          emoji: '🏠',
          totalSpend: 6200.00,
          yourShare: 2066.00,
          memberNames: ['You', 'Aryan', 'Sameer'],
        ),
      ],
      emis: [
        EmiItem(
          id: 'emi-1',
          title: 'iPhone 16 Pro (No Cost EMI)',
          totalAmount: 119900.00,
          monthlyAmount: 9990.00,
          paidMonths: 4,
          totalMonths: 12,
          nextDueDate: now.add(const Duration(days: 11)),
          bankName: 'HDFC Bank',
        ),
        EmiItem(
          id: 'emi-2',
          title: 'Dyson Airwrap Stash',
          totalAmount: 45900.00,
          monthlyAmount: 7650.00,
          paidMonths: 2,
          totalMonths: 6,
          nextDueDate: now.add(const Duration(days: 22)),
          bankName: 'OneCard Metal',
        ),
      ],
      paymentMethods: [
        PaymentMethodItem(
          id: 'pm-1',
          name: 'HDFC Salary Platinum',
          type: 'Debit',
          last4Digits: '8492',
          cardBrand: 'Visa',
          monthlyLimit: 100000.00,
          currentSpent: 24500.00,
          isDefault: true,
        ),
        PaymentMethodItem(
          id: 'pm-2',
          name: 'OneCard Metal Credit',
          type: 'Credit',
          last4Digits: '1923',
          cardBrand: 'Mastercard',
          monthlyLimit: 75000.00,
          currentSpent: 18490.00,
          isDefault: false,
        ),
        PaymentMethodItem(
          id: 'pm-3',
          name: 'UPI Primary (sujal@okhdfcbank)',
          type: 'UPI',
          last4Digits: 'UPI',
          cardBrand: 'UPI',
          monthlyLimit: 50000.00,
          currentSpent: 9200.00,
          isDefault: false,
        ),
      ],
    );
  }

  void updateMonthlyBudget(double newBudget) {
    state = state.copyWith(monthlyBudget: newBudget);
  }

  void addFriend({
    required String name,
    double initialAmount = 0.0,
  }) {
    final newFriend = FriendItem(
      id: 'friend-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      avatarInitial: name.isNotEmpty ? name[0].toUpperCase() : 'F',
      amountOwed: initialAmount,
      lastActivity: 'Added recently',
    );
    state = state.copyWith(friends: [...state.friends, newFriend]);
  }

  void settleFriendDebt(String friendId) {
    final updated = state.friends.map((f) {
      if (f.id == friendId) {
        return f.copyWith(amountOwed: 0.0, isSettled: true);
      }
      return f;
    }).toList();
    state = state.copyWith(friends: updated);
  }

  void createGroup({
    required String name,
    required String emoji,
    required List<String> members,
    required double initialSpend,
  }) {
    final newGroup = SplitGroup(
      id: 'grp-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      totalSpend: initialSpend,
      yourShare: members.isNotEmpty ? initialSpend / members.length : 0,
      memberNames: members,
    );
    state = state.copyWith(groups: [...state.groups, newGroup]);
  }

  void addEmi({
    required String title,
    required double totalAmount,
    required double monthlyAmount,
    required int totalMonths,
    required String bankName,
  }) {
    final newEmi = EmiItem(
      id: 'emi-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      totalAmount: totalAmount,
      monthlyAmount: monthlyAmount,
      paidMonths: 0,
      totalMonths: totalMonths,
      nextDueDate: DateTime.now().add(const Duration(days: 30)),
      bankName: bankName,
    );
    state = state.copyWith(emis: [...state.emis, newEmi]);
  }

  void payEmiInstallment(String emiId) {
    final updated = state.emis.map((emi) {
      if (emi.id == emiId && emi.paidMonths < emi.totalMonths) {
        return emi.copyWith(paidMonths: emi.paidMonths + 1);
      }
      return emi;
    }).toList();
    state = state.copyWith(emis: updated);
  }

  void addPaymentMethod({
    required String name,
    required String type,
    required String last4,
    required String cardBrand,
    required double limit,
  }) {
    final newPm = PaymentMethodItem(
      id: 'pm-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      last4Digits: last4,
      cardBrand: cardBrand,
      monthlyLimit: limit,
      currentSpent: 0.0,
    );
    state = state.copyWith(paymentMethods: [...state.paymentMethods, newPm]);
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
