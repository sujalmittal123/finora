import 'package:flutter/foundation.dart';

enum VibeCategory {
  caffeine('☕', 'Caffeine & Bites', 'Food & Drinks'),
  dopamine('🛍️', 'Dopamine Shopping', 'Lifestyle'),
  lateRides('🚕', 'Late Cabs', 'Transport'),
  midnightCraving('🍕', 'Midnight Craving', 'Food'),
  gamingSubs('🎮', 'Gaming & Digital', 'Entertainment'),
  rentBills('🏠', 'Rent & Utilities', 'Bills'),
  fitness('💪', 'Fitness & Wellness', 'Health'),
  salary('💰', 'Payday / Inflow', 'Income'),
  investment('📈', 'Crypto & Stocks', 'Wealth');

  final String emoji;
  final String label;
  final String group;
  const VibeCategory(this.emoji, this.label, this.group);

  static VibeCategory fromName(String? name) {
    if (name == null) return VibeCategory.caffeine;
    for (final c in VibeCategory.values) {
      if (c.name == name) return c;
    }
    return VibeCategory.caffeine;
  }
}

@immutable
class TransactionItem {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final VibeCategory category;
  final bool isExpense;
  final String accountName;
  final String? splitWith;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.isExpense = true,
    this.accountName = 'Main Account',
    this.splitWith,
  });

  TransactionItem copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    VibeCategory? category,
    bool? isExpense,
    String? accountName,
    String? splitWith,
  }) {
    return TransactionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
      accountName: accountName ?? this.accountName,
      splitWith: splitWith ?? this.splitWith,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.name,
        'isExpense': isExpense,
        'accountName': accountName,
        'splitWith': splitWith,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: VibeCategory.fromName(json['category'] as String?),
      isExpense: json['isExpense'] as bool? ?? true,
      accountName: json['accountName'] as String? ?? 'Main Account',
      splitWith: json['splitWith'] as String?,
    );
  }
}

@immutable
class SubscriptionItem {
  final String id;
  final String name;
  final double amount;
  final String billingPeriod; // Monthly / Yearly
  final DateTime nextBillingDate;
  final String iconEmoji;
  final bool isPaused;

  const SubscriptionItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingPeriod,
    required this.nextBillingDate,
    required this.iconEmoji,
    this.isPaused = false,
  });

  int get daysRemaining {
    final diff = nextBillingDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  SubscriptionItem copyWith({
    String? id,
    String? name,
    double? amount,
    String? billingPeriod,
    DateTime? nextBillingDate,
    String? iconEmoji,
    bool? isPaused,
  }) {
    return SubscriptionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'billingPeriod': billingPeriod,
        'nextBillingDate': nextBillingDate.toIso8601String(),
        'iconEmoji': iconEmoji,
        'isPaused': isPaused,
      };

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionItem(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      billingPeriod: json['billingPeriod'] as String? ?? 'Monthly',
      nextBillingDate: DateTime.parse(json['nextBillingDate'] as String),
      iconEmoji: json['iconEmoji'] as String? ?? '🔁',
      isPaused: json['isPaused'] as bool? ?? false,
    );
  }
}

@immutable
class SavingsVault {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String emoji;
  final DateTime targetDate;

  const SavingsVault({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.emoji,
    required this.targetDate,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final ratio = currentAmount / targetAmount;
    return ratio > 1.0 ? 1.0 : ratio;
  }

  double get remainingAmount {
    final rem = targetAmount - currentAmount;
    return rem < 0 ? 0 : rem;
  }

  SavingsVault copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? emoji,
    DateTime? targetDate,
  }) {
    return SavingsVault(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      emoji: emoji ?? this.emoji,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'emoji': emoji,
        'targetDate': targetDate.toIso8601String(),
      };

  factory SavingsVault.fromJson(Map<String, dynamic> json) {
    return SavingsVault(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      emoji: json['emoji'] as String? ?? '🎯',
      targetDate: DateTime.parse(json['targetDate'] as String),
    );
  }
}

@immutable
class FriendItem {
  final String id;
  final String name;
  final String avatarInitial;
  final double amountOwed; // positive = they owe user, negative = user owes them
  final String lastActivity;
  final bool isSettled;

  const FriendItem({
    required this.id,
    required this.name,
    required this.avatarInitial,
    required this.amountOwed,
    required this.lastActivity,
    this.isSettled = false,
  });

  FriendItem copyWith({
    String? id,
    String? name,
    String? avatarInitial,
    double? amountOwed,
    String? lastActivity,
    bool? isSettled,
  }) {
    return FriendItem(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarInitial: avatarInitial ?? this.avatarInitial,
      amountOwed: amountOwed ?? this.amountOwed,
      lastActivity: lastActivity ?? this.lastActivity,
      isSettled: isSettled ?? this.isSettled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarInitial': avatarInitial,
        'amountOwed': amountOwed,
        'lastActivity': lastActivity,
        'isSettled': isSettled,
      };

  factory FriendItem.fromJson(Map<String, dynamic> json) {
    return FriendItem(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarInitial: json['avatarInitial'] as String? ?? 'F',
      amountOwed: (json['amountOwed'] as num?)?.toDouble() ?? 0.0,
      lastActivity: json['lastActivity'] as String? ?? '',
      isSettled: json['isSettled'] as bool? ?? false,
    );
  }
}

@immutable
class SplitGroup {
  final String id;
  final String name;
  final String emoji;
  final double totalSpend;
  final double yourShare;
  final List<String> memberNames;

  const SplitGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.totalSpend,
    required this.yourShare,
    required this.memberNames,
  });

  SplitGroup copyWith({
    String? id,
    String? name,
    String? emoji,
    double? totalSpend,
    double? yourShare,
    List<String>? memberNames,
  }) {
    return SplitGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      totalSpend: totalSpend ?? this.totalSpend,
      yourShare: yourShare ?? this.yourShare,
      memberNames: memberNames ?? this.memberNames,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'totalSpend': totalSpend,
        'yourShare': yourShare,
        'memberNames': memberNames,
      };

  factory SplitGroup.fromJson(Map<String, dynamic> json) {
    return SplitGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '👥',
      totalSpend: (json['totalSpend'] as num).toDouble(),
      yourShare: (json['yourShare'] as num).toDouble(),
      memberNames: (json['memberNames'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
}

@immutable
class EmiItem {
  final String id;
  final String title;
  final double totalAmount;
  final double monthlyAmount;
  final int paidMonths;
  final int totalMonths;
  final DateTime nextDueDate;
  final String bankName;

  const EmiItem({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.monthlyAmount,
    required this.paidMonths,
    required this.totalMonths,
    required this.nextDueDate,
    required this.bankName,
  });

  double get progressPercentage =>
      totalMonths > 0 ? (paidMonths / totalMonths).clamp(0.0, 1.0) : 0.0;

  int get remainingMonths => (totalMonths - paidMonths).clamp(0, totalMonths);

  EmiItem copyWith({
    String? id,
    String? title,
    double? totalAmount,
    double? monthlyAmount,
    int? paidMonths,
    int? totalMonths,
    DateTime? nextDueDate,
    String? bankName,
  }) {
    return EmiItem(
      id: id ?? this.id,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      monthlyAmount: monthlyAmount ?? this.monthlyAmount,
      paidMonths: paidMonths ?? this.paidMonths,
      totalMonths: totalMonths ?? this.totalMonths,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      bankName: bankName ?? this.bankName,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'totalAmount': totalAmount,
        'monthlyAmount': monthlyAmount,
        'paidMonths': paidMonths,
        'totalMonths': totalMonths,
        'nextDueDate': nextDueDate.toIso8601String(),
        'bankName': bankName,
      };

  factory EmiItem.fromJson(Map<String, dynamic> json) {
    return EmiItem(
      id: json['id'] as String,
      title: json['title'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      monthlyAmount: (json['monthlyAmount'] as num).toDouble(),
      paidMonths: (json['paidMonths'] as num?)?.toInt() ?? 0,
      totalMonths: (json['totalMonths'] as num).toInt(),
      nextDueDate: DateTime.parse(json['nextDueDate'] as String),
      bankName: json['bankName'] as String? ?? '',
    );
  }
}

@immutable
class PaymentMethodItem {
  final String id;
  final String name;
  final String type; // Credit, Debit, UPI, Cash
  final String last4Digits;
  final String cardBrand; // Visa, Mastercard, RuPay, UPI
  final double monthlyLimit;
  final double currentSpent;
  final bool isDefault;

  const PaymentMethodItem({
    required this.id,
    required this.name,
    required this.type,
    required this.last4Digits,
    required this.cardBrand,
    required this.monthlyLimit,
    required this.currentSpent,
    this.isDefault = false,
  });

  double get utilizationRatio =>
      monthlyLimit > 0 ? (currentSpent / monthlyLimit).clamp(0.0, 1.0) : 0.0;

  PaymentMethodItem copyWith({
    String? id,
    String? name,
    String? type,
    String? last4Digits,
    String? cardBrand,
    double? monthlyLimit,
    double? currentSpent,
    bool? isDefault,
  }) {
    return PaymentMethodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      last4Digits: last4Digits ?? this.last4Digits,
      cardBrand: cardBrand ?? this.cardBrand,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currentSpent: currentSpent ?? this.currentSpent,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'last4Digits': last4Digits,
        'cardBrand': cardBrand,
        'monthlyLimit': monthlyLimit,
        'currentSpent': currentSpent,
        'isDefault': isDefault,
      };

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) {
    return PaymentMethodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'Bank',
      last4Digits: json['last4Digits'] as String? ?? '',
      cardBrand: json['cardBrand'] as String? ?? '',
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      currentSpent: (json['currentSpent'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

@immutable
class AccountItem {
  final String id;
  final String name;
  final String type; // Bank, Credit Card, Cash, UPI, Investment
  final String last4Digits;
  final double balance;
  final bool isDefault;

  const AccountItem({
    required this.id,
    required this.name,
    required this.type,
    this.last4Digits = '',
    this.balance = 0.0,
    this.isDefault = false,
  });

  AccountItem copyWith({
    String? id,
    String? name,
    String? type,
    String? last4Digits,
    double? balance,
    bool? isDefault,
  }) {
    return AccountItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      last4Digits: last4Digits ?? this.last4Digits,
      balance: balance ?? this.balance,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'last4Digits': last4Digits,
        'balance': balance,
        'isDefault': isDefault,
      };

  factory AccountItem.fromJson(Map<String, dynamic> json) {
    return AccountItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? 'Bank',
      last4Digits: json['last4Digits'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}

@immutable
class BudgetItem {
  final String id;
  final VibeCategory category;
  final double monthlyLimit;

  const BudgetItem({
    required this.id,
    required this.category,
    required this.monthlyLimit,
  });

  BudgetItem copyWith({
    String? id,
    VibeCategory? category,
    double? monthlyLimit,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      category: category ?? this.category,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category.name,
        'monthlyLimit': monthlyLimit,
      };

  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as String,
      category: VibeCategory.fromName(json['category'] as String?),
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }
}

@immutable
class AiChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> suggestions;
  final String? insightBadge;

  const AiChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestions = const [],
    this.insightBadge,
  });
}
