import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/budgets/presentation/screens/budgets_screen.dart';
import '../../features/accounts/presentation/screens/accounts_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    routes: [
      // Auth
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/transactions',
            builder: (_, __) => const TransactionsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                builder: (_, __) => const AddTransactionScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/budgets',
            builder: (_, __) => const BudgetsScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (_, __) => const AccountsScreen(),
          ),
        ],
      ),
    ],
  );
});
