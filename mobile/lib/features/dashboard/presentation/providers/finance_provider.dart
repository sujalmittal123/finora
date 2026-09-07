import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../shared/models/financial_models.dart';

const String _financeBoxName = 'finora_state';
const String _financeKey = 'finance';

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
  final List<AccountItem> accounts;
  final List<BudgetItem> budgets;
  final bool hasCompletedSetup;

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
    this.accounts = const [],
    this.budgets = const [],
    this.hasCompletedSetup = false,
  });

  /// Fresh state with no data — everything starts at zero.
  factory FinanceState.empty() {
    return const FinanceState(
      totalBalance: 0.0,
      monthlyIncome: 0.0,
      monthlyBudget: 0.0,
      streakDays: 0,
      transactions: [],
      subscriptions: [],
      vaults: [],
      friends: [],
      groups: [],
      emis: [],
      paymentMethods: [],
    );
  }

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

  double spentInCategory(VibeCategory category) {
    final now = DateTime.now();
    return transactions
        .where((tx) =>
            tx.isExpense &&
            tx.category == category &&
            tx.date.year == now.year &&
            tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
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
    List<AccountItem>? accounts,
    List<BudgetItem>? budgets,
    bool? hasCompletedSetup,
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
      accounts: accounts ?? this.accounts,
      budgets: budgets ?? this.budgets,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalBalance': totalBalance,
        'monthlyIncome': monthlyIncome,
        'monthlyBudget': monthlyBudget,
        'streakDays': streakDays,
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'subscriptions': subscriptions.map((e) => e.toJson()).toList(),
        'vaults': vaults.map((e) => e.toJson()).toList(),
        'friends': friends.map((e) => e.toJson()).toList(),
        'groups': groups.map((e) => e.toJson()).toList(),
        'emis': emis.map((e) => e.toJson()).toList(),
        'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
        'accounts': accounts.map((e) => e.toJson()).toList(),
        'budgets': budgets.map((e) => e.toJson()).toList(),
        'hasCompletedSetup': hasCompletedSetup,
      };

  factory FinanceState.fromJson(Map<String, dynamic> json) {
    List<T> parseList<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      return (json[key] as List<dynamic>? ?? [])
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return FinanceState(
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0.0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
      streakDays: (json['streakDays'] as num?)?.toInt() ?? 0,
      transactions:
          parseList('transactions', TransactionItem.fromJson),
      subscriptions:
          parseList('subscriptions', SubscriptionItem.fromJson),
      vaults: parseList('vaults', SavingsVault.fromJson),
      friends: parseList('friends', FriendItem.fromJson),
      groups: parseList('groups', SplitGroup.fromJson),
      emis: parseList('emis', EmiItem.fromJson),
      paymentMethods: parseList('paymentMethods', PaymentMethodItem.fromJson),
      accounts: parseList('accounts', AccountItem.fromJson),
      budgets: parseList('budgets', BudgetItem.fromJson),
      hasCompletedSetup: json['hasCompletedSetup'] as bool? ?? false,
    );
  }
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  FinanceNotifier() : super(_loadState());

  static final Box<dynamic> _box = Hive.box<dynamic>(_financeBoxName);

  static FinanceState _loadState() {
    try {
      final raw = _box.get(_financeKey);
      if (raw == null) return FinanceState.empty();
      return FinanceState.fromJson(jsonDecode(raw as String)
          as Map<String, dynamic>);
    } catch (e) {
      return FinanceState.empty();
    }
  }

  void _persist() {
    try {
      _box.put(_financeKey, jsonEncode(state.toJson()));
    } catch (e) {
      // Persistence failure should never crash the UI.
    }
  }

  /// Marks onboarding as complete after the user enters their own data.
  void completeSetup({
    required double monthlyIncome,
    required double monthlyBudget,
    AccountItem? firstAccount,
  }) {
    var balance = state.totalBalance;
    var accounts = state.accounts;
    if (firstAccount != null && firstAccount.name.trim().isNotEmpty) {
      accounts = [...accounts, firstAccount];
      balance = firstAccount.balance;
    }
    state = state.copyWith(
      monthlyIncome: monthlyIncome,
      monthlyBudget: monthlyBudget,
      totalBalance: balance,
      accounts: accounts,
      hasCompletedSetup: true,
    );
    _persist();
  }

  void setMonthlyIncome(double income) {
    state = state.copyWith(monthlyIncome: income);
    _persist();
  }

  void updateMonthlyBudget(double newBudget) {
    state = state.copyWith(monthlyBudget: newBudget);
    _persist();
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
    _persist();
  }

  void settleFriendDebt(String friendId) {
    final updated = state.friends.map((f) {
      if (f.id == friendId) {
        return f.copyWith(amountOwed: 0.0, isSettled: true);
      }
      return f;
    }).toList();
    state = state.copyWith(friends: updated);
    _persist();
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
    _persist();
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
    _persist();
  }

  void payEmiInstallment(String emiId) {
    final updated = state.emis.map((emi) {
      if (emi.id == emiId && emi.paidMonths < emi.totalMonths) {
        return emi.copyWith(paidMonths: emi.paidMonths + 1);
      }
      return emi;
    }).toList();
    state = state.copyWith(emis: updated);
    _persist();
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
    _persist();
  }

  void addAccount({
    required String name,
    required String type,
    String last4 = '',
    double balance = 0.0,
    bool isDefault = false,
  }) {
    final newAccount = AccountItem(
      id: 'acc-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      last4Digits: last4,
      balance: balance,
      isDefault: isDefault,
    );
    state = state.copyWith(accounts: [...state.accounts, newAccount]);
    _persist();
  }

  void deleteAccount(String id) {
    state = state.copyWith(
      accounts: state.accounts.where((a) => a.id != id).toList(),
    );
    _persist();
  }

  void addBudget({
    required VibeCategory category,
    required double monthlyLimit,
  }) {
    final newBudget = BudgetItem(
      id: 'budget-${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      monthlyLimit: monthlyLimit,
    );
    state = state.copyWith(budgets: [...state.budgets, newBudget]);
    _persist();
  }

  void updateBudget(String id, double newLimit) {
    final updated = state.budgets.map((b) {
      if (b.id == id) return b.copyWith(monthlyLimit: newLimit);
      return b;
    }).toList();
    state = state.copyWith(budgets: updated);
    _persist();
  }

  void deleteBudget(String id) {
    state = state.copyWith(
      budgets: state.budgets.where((b) => b.id != id).toList(),
    );
    _persist();
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

    final updatedAccounts = state.accounts.map((a) {
      if (a.name == accountName) {
        final delta = isExpense ? -amount : amount;
        return a.copyWith(balance: a.balance + delta);
      }
      return a;
    }).toList();

    state = state.copyWith(
      transactions: updatedTransactions,
      totalBalance: updatedBalance,
      accounts: updatedAccounts,
    );
    _persist();
  }

  void deleteTransaction(String id) {
    final txToDelete = state.transactions.firstWhere((tx) => tx.id == id);
    final updatedList = state.transactions.where((tx) => tx.id != id).toList();
    final updatedBalance = txToDelete.isExpense
        ? state.totalBalance + txToDelete.amount
        : state.totalBalance - txToDelete.amount;

    final updatedAccounts = state.accounts.map((a) {
      if (a.name == txToDelete.accountName) {
        final delta = txToDelete.isExpense ? txToDelete.amount : -txToDelete.amount;
        return a.copyWith(balance: a.balance + delta);
      }
      return a;
    }).toList();

    state = state.copyWith(
      transactions: updatedList,
      totalBalance: updatedBalance,
      accounts: updatedAccounts,
    );
    _persist();
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
    _persist();
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
    _persist();
  }
}

final financeProvider =
    StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier();
});
