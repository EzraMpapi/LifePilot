import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/expense_entry.dart';
import '../expense_providers.dart';

/// Donut-style breakdown of expense (not income) totals by category.
/// Shows an empty state rather than an empty/broken chart when there's
/// nothing to plot yet.
class SpendingByCategoryChart extends StatelessWidget {
  final ExpenseSummary summary;
  const SpendingByCategoryChart({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (summary.byCategory.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'Add an expense to see your spending breakdown.',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      );
    }

    final entries = summary.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 160,
          width: 160,
          child: PieChart(
            PieChartData(
              sections: entries.map((e) {
                return PieChartSectionData(
                  value: e.value,
                  color: e.key.color,
                  title: '',
                  radius: 28,
                );
              }).toList(),
              centerSpaceRadius: 42,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: entries.take(5).map((e) {
              final pct = summary.totalExpense > 0 ? (e.value / summary.totalExpense * 100) : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: e.key.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(e.key.label, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
