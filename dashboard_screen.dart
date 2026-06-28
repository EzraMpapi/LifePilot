import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../expenses/presentation/expense_providers.dart';

/// The home/dashboard screen.
///
/// Design intent: the header reads like the top of a page in a daily
/// planner (serif date heading, a warm rule beneath it) rather than a
/// dense SaaS metrics grid — that's this screen's signature element,
/// matching the "personal life OS, not corporate dashboard" brief.
///
/// Honesty note: only Expenses has real data behind it so far (this
/// iteration's one complete vertical slice). Every other card below
/// is clearly labeled "Coming soon" rather than showing fabricated
/// numbers — a fake weather reading or a made-up "AI suggestion" would
/// be actively misleading on a screen whose whole point is to be a
/// trustworthy daily overview.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authControllerProvider);
    final expensesAsync = ref.watch(expenseListProvider);
    final now = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _DateHeader(
              greeting: _greetingFor(now.hour),
              name: userAsync.value?.displayName.split(' ').first ?? '',
              date: now,
            ),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: expensesAsync.when(
                    loading: () => const _LoadingCard(),
                    error: (_, __) => const _ComingSoonCard(
                      icon: Icons.error_outline,
                      title: 'Spending this month',
                      subtitle: 'Could not load expenses.',
                    ),
                    data: (entries) {
                      final thisMonth = entries.where(
                        (e) => e.date.year == now.year && e.date.month == now.month,
                      );
                      final summary = ExpenseSummary.from(thisMonth.toList());
                      return _MonthlySpendingCard(summary: summary, month: now);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DashboardGrid(),
          ],
        ),
      ),
    );
  }

  String _greetingFor(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _DateHeader extends StatelessWidget {
  final String greeting;
  final String name;
  final DateTime date;
  const _DateHeader({required this.greeting, required this.name, required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? greeting : '$greeting, $name',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(Formatters.fullDate(date), style: theme.textTheme.displaySmall),
        const SizedBox(height: 12),
        Container(height: 2, width: 64, color: theme.colorScheme.secondary),
      ],
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your day', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: const [
            _ComingSoonCard(icon: Icons.wb_sunny_outlined, title: 'Weather', subtitle: 'Coming soon'),
            _ComingSoonCard(icon: Icons.event_outlined, title: "Today's schedule", subtitle: 'Coming soon'),
            _ComingSoonCard(icon: Icons.notifications_outlined, title: 'Reminders', subtitle: 'Coming soon'),
            _ComingSoonCard(icon: Icons.flag_outlined, title: 'Goal progress', subtitle: 'Coming soon'),
            _ComingSoonCard(icon: Icons.note_outlined, title: 'Quick notes', subtitle: 'Coming soon'),
            _ComingSoonCard(icon: Icons.place_outlined, title: 'Recent locations', subtitle: 'Coming soon'),
            _ComingSoonCard(icon: Icons.auto_awesome_outlined, title: 'AI suggestions', subtitle: 'Coming soon'),
            _ComingSoonCard(icon: Icons.calendar_month_outlined, title: 'Calendar preview', subtitle: 'Coming soon'),
          ],
        ),
      ],
    );
  }
}

class _MonthlySpendingCard extends StatelessWidget {
  final ExpenseSummary summary;
  final DateTime month;
  const _MonthlySpendingCard({required this.summary, required this.month});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Text('Spending in ${Formatters.monthYear(month)}', style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 14),
            Text(Formatters.currency(summary.totalExpense), style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              summary.totalIncome > 0
                  ? 'Balance this month: ${Formatters.currency(summary.balance)}'
                  : 'No income logged this month yet.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ComingSoonCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            const Spacer(),
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 2),
            Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
