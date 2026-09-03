import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/vaults/presentation/screens/vaults_screen.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/dashboard';
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authServiceProvider).authStateChanges,
    ),
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (_, __) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/ai-assistant',
            builder: (_, __) => const AiAssistantScreen(),
          ),
          GoRoute(
            path: '/vaults',
            builder: (_, __) => const VaultsScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (_, __) => const AccountsScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (_, __) => const TransactionsScreen(),
          ),
        ],
      ),

      GoRoute(
        path: '/transactions/add',
        builder: (_, __) => const AddTransactionScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
