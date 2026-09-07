import 'package:flutter_test/flutter_test.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';
import 'package:finora/shared/models/financial_models.dart';

void main() {
  test('FinanceState JSON roundtrip preserves user data', () {
    final state = FinanceState(
      totalBalance: 50000.0,
      monthlyIncome: 60000.0,
      monthlyBudget: 40000.0,
      streakDays: 3,
      transactions: [
        TransactionItem(
          id: 'tx-1',
          title: 'Coffee',
          amount: 250.0,
          date: DateTime(2026, 9, 6, 10, 30),
          category: VibeCategory.caffeine,
          isExpense: true,
          accountName: 'HDFC Savings',
        ),
        TransactionItem(
          id: 'tx-2',
          title: 'Salary',
          amount: 60000.0,
          date: DateTime(2026, 9, 1),
          category: VibeCategory.salary,
          isExpense: false,
          accountName: 'HDFC Savings',
          splitWith: null,
        ),
      ],
      accounts: [
        AccountItem(
          id: 'acc-1',
          name: 'HDFC Savings',
          type: 'Bank',
          balance: 50000.0,
          isDefault: true,
        ),
      ],
      budgets: [
        BudgetItem(
          id: 'budget-1',
          category: VibeCategory.caffeine,
          monthlyLimit: 2000.0,
        ),
      ],
      subscriptions: [
        SubscriptionItem(
          id: 'sub-1',
          name: 'Spotify',
          amount: 149.0,
          billingPeriod: 'Monthly',
          nextBillingDate: DateTime(2026, 10, 1),
          iconEmoji: '🎧',
        ),
      ],
      vaults: [
        SavingsVault(
          id: 'vault-1',
          title: 'Goa Trip',
          targetAmount: 35000.0,
          currentAmount: 12000.0,
          emoji: '✈️',
          targetDate: DateTime(2026, 12, 31),
        ),
      ],
      friends: [
        FriendItem(
          id: 'friend-1',
          name: 'Aryan',
          avatarInitial: 'A',
          amountOwed: 450.0,
          lastActivity: 'Lunch split',
        ),
      ],
      groups: [
        SplitGroup(
          id: 'grp-1',
          name: 'Goa Gang',
          emoji: '🏖️',
          totalSpend: 10000.0,
          yourShare: 2500.0,
          memberNames: ['You', 'Aryan', 'Tanya', 'Rohan'],
        ),
      ],
      emis: [
        EmiItem(
          id: 'emi-1',
          title: 'iPhone EMI',
          totalAmount: 119900.0,
          monthlyAmount: 9990.0,
          paidMonths: 4,
          totalMonths: 12,
          nextDueDate: DateTime(2026, 10, 5),
          bankName: 'HDFC Bank',
        ),
      ],
      paymentMethods: [
        PaymentMethodItem(
          id: 'pm-1',
          name: 'OneCard',
          type: 'Credit',
          last4Digits: '1923',
          cardBrand: 'Mastercard',
          monthlyLimit: 75000.0,
          currentSpent: 18490.0,
        ),
      ],
      hasCompletedSetup: true,
    );

    final restored = FinanceState.fromJson(state.toJson());

    expect(restored.totalBalance, 50000.0);
    expect(restored.monthlyIncome, 60000.0);
    expect(restored.monthlyBudget, 40000.0);
    expect(restored.streakDays, 3);
    expect(restored.hasCompletedSetup, true);
    expect(restored.transactions.length, 2);
    expect(restored.transactions.first.title, 'Coffee');
    expect(restored.transactions.first.category, VibeCategory.caffeine);
    expect(restored.transactions.first.isExpense, true);
    expect(restored.accounts.single.balance, 50000.0);
    expect(restored.budgets.single.category, VibeCategory.caffeine);
    expect(restored.subscriptions.single.name, 'Spotify');
    expect(restored.vaults.single.title, 'Goa Trip');
    expect(restored.friends.single.amountOwed, 450.0);
    expect(restored.groups.single.memberNames.length, 4);
    expect(restored.emis.single.paidMonths, 4);
    expect(restored.paymentMethods.single.utilizationRatio, greaterThan(0.2));
  });

  test('Empty state starts with no data', () {
    final empty = FinanceState.empty();
    expect(empty.totalBalance, 0.0);
    expect(empty.monthlyIncome, 0.0);
    expect(empty.transactions, isEmpty);
    expect(empty.hasCompletedSetup, false);
    expect(empty.safeToSpendToday, 0.0);
  });
}
