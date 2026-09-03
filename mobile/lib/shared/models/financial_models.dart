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
