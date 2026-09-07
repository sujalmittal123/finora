import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finora/shared/models/financial_models.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class AiState {
  final List<AiChatMessage> messages;
  final bool isThinking;
  final List<String> promptChips;

  const AiState({
    required this.messages,
    required this.isThinking,
    required this.promptChips,
  });

  AiState copyWith({
    List<AiChatMessage>? messages,
    bool? isThinking,
    List<String>? promptChips,
  }) {
    return AiState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      promptChips: promptChips ?? this.promptChips,
    );
  }
}

class AiNotifier extends StateNotifier<AiState> {
  final Ref ref;

  AiNotifier(this.ref) : super(_initialAiState());

  static AiState _initialAiState() {
    return AiState(
      isThinking: false,
      promptChips: [
        '⚡ Can I afford sneakers this weekend?',
        '🔥 Roast my spending habits',
        '💡 Where is my cash leaking most?',
        '🏖️ How to hit Goa trip target faster?',
      ],
      messages: [
        AiChatMessage(
          id: 'msg-0',
          text:
              "Hey! I'm **Nova**, your Finora AI money co-pilot 🔮\n\nI monitor your safe-to-spend allowance, detect subscription leaks, and keep your savings goals on streak. What's on your mind today?",
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          suggestions: [
            'How much can I spend today?',
            'Check my Netflix & subscriptions',
            'Give me a 3-step saving plan',
          ],
        ),
      ],
    );
  }

  Future<void> sendMessage(String userText) async {
    if (userText.trim().isEmpty) return;

    final userMsg = AiChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      text: userText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
    );

    // Grab live financial state
    final financeState = ref.read(financeProvider);
    final safeToSpend = financeState.safeToSpendToday;
    final totalBalance = financeState.totalBalance;
    final flexRatio = financeState.flexRatio;

    // Simulate AI thinking latency
    await Future.delayed(const Duration(milliseconds: 900));

    // Intelligent context-aware response generation
    final responseText = _generateSmartResponse(
      query: userText.toLowerCase(),
      safeToSpend: safeToSpend,
      totalBalance: totalBalance,
      flexRatio: flexRatio,
      financeState: financeState,
    );

    final aiMsg = AiChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      insightBadge: 'AI Co-Pilot Live Insight',
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isThinking: false,
    );
  }

  String _generateSmartResponse({
    required String query,
    required double safeToSpend,
    required double totalBalance,
    required double flexRatio,
    required FinanceState financeState,
  }) {
    if (query.contains('roast')) {
      return "🔥 **Spicy Spending Roast:**\n\nYou've spent **₹${financeState.todaySpent.toStringAsFixed(0)}** today alone. Your 'Flex vs Needs' ratio is sitting at **${(flexRatio * 100).toStringAsFixed(0)}% dopamine spending**! ☕💸\n\nThose ₹280 iced lattes are basically funding a barista's dream vacation instead of your Goa trip. Skip two dining orders this week and save an instant ₹1,800!";
    } else if (query.contains('sneaker') ||
        query.contains('afford') ||
        query.contains('buy')) {
      if (safeToSpend > 2500) {
        return "✅ **Affordability Verdict: GREEN LIGHT**\n\nYour Safe-to-Spend allowance today is **₹${safeToSpend.toStringAsFixed(0)}** and your total liquid stash is **₹${totalBalance.toStringAsFixed(0)}**.\n\nYou can afford a purchase up to ₹3,500 without breaking your monthly streak, as long as you keep tomorrow's dining under ₹400!";
      } else {
        return "⚠️ **Affordability Verdict: PAUSE & THINK**\n\nYour daily safe limit is **₹${safeToSpend.toStringAsFixed(0)}**. Splurging now will pull cash directly from your **Goa Trip** savings vault.\n\n💡 *Pro-tip*: Wait 48 hours. If you still want them by Friday and stay under budget, buy them guilt-free!";
      }
    } else if (query.contains('leak') ||
        query.contains('where') ||
        query.contains('subscription')) {
      final subCount = financeState.subscriptions.length;
      if (subCount == 0) {
        return "🧛 **No vampire leaks yet!**\n\nYou don't have any subscriptions tracked. Add them from Tools → Subscriptions and I'll start hunting for leaks 🔎";
      }
      final subTotal = financeState.subscriptions
          .fold(0.0, (sum, item) => sum + item.amount);
      final subLines = financeState.subscriptions
          .take(2)
          .map((s) => '- **${s.name}**: ${s.amount.toStringAsFixed(0)}/mo')
          .join('\n');
      return "🧛 **Vampire Leaks Detected:**\n\nYou have **$subCount active subscriptions** draining **₹${subTotal.toStringAsFixed(0)}/month** automatically.\n\n$subLines\n\nCutting just 1 unused subscription adds serious savings back to your stash!";
    } else if (query.contains('goa') ||
        query.contains('trip') ||
        query.contains('save')) {
      if (financeState.vaults.isEmpty) {
        return "🎯 **No savings vaults yet!**\n\nCreate your first savings goal from the Vaults tab and I'll help you track progress toward it.";
      }
      final goaVault = financeState.vaults.firstWhere(
        (v) => v.title.toLowerCase().contains('goa') ||
            v.title.toLowerCase().contains('trip'),
        orElse: () => financeState.vaults.first,
      );
      final pct = (goaVault.progressPercentage * 100).toStringAsFixed(0);
      return "🏖️ **${goaVault.title} Progress: $pct% Complete**\n\nYou have saved **₹${goaVault.currentAmount.toStringAsFixed(0)}** of **₹${goaVault.targetAmount.toStringAsFixed(0)}**.\n\n⚡ *Speed-Up Strategy*: Small daily deposits and splitting costs with friends get you to 100% faster!";
    } else {
      return "📊 **Financial Snapshot:**\n\n• **Safe to Spend Today**: ₹${safeToSpend.toStringAsFixed(0)}\n• **Total Stash**: ₹${totalBalance.toStringAsFixed(0)}\n• **Active Streak**: ${financeState.streakDays} Days 🔥\n\nYou are in the top 15% of mindful spenders this week! Keep the momentum going.";
    }
  }
}

final aiProvider = StateNotifierProvider<AiNotifier, AiState>((ref) {
  return AiNotifier(ref);
});
