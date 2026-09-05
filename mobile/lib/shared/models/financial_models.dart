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
