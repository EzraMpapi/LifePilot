import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../widgets/app_shell.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';

/// Route paths as constants so screens navigate by name
/// (`context.go(AppRoutes.expenses)`) instead of hardcoded strings
/// scattered across the codebase.
abstract class AppRoutes {
  static const signIn = '/sign-in';
  static const dashboard = '/';
  static const expenses = '/expenses';
}

/// Builds the app's [GoRouter], wired to redirect based on auth state.
///
/// Important: this provider calls `ref.watch(authControllerProvider)`
/// (not `ref.read`) specifically so that when auth state changes
/// (sign in / sign out), Riverpod rebuilds this whole provider — which
/// gives GoRouter a freshly-built `redirect` closure that sees the new
/// state immediately. A `ref.read` here would compile fine but
/// silently break navigation: after signing in, `redirect` would keep
/// evaluating against the *old* auth state until something else
/// happened to trigger a rebuild, leaving the user stuck looking at
/// the sign-in screen despite having just signed in successfully.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isSignedIn = authState.value != null;
      final goingToSignIn = state.matchedLocation == AppRoutes.signIn;

      // Still resolving the initial auth check — don't redirect yet,
      // the loading screen below handles this case visually.
      if (authState.isLoading) return null;

      if (!isSignedIn && !goingToSignIn) return AppRoutes.signIn;
      if (isSignedIn && goingToSignIn) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            builder: (context, state) => const ExpensesScreen(),
          ),
        ],
      ),
    ],
  );
});
