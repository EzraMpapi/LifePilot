import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../domain/expense_entry.dart';
import 'expense_providers.dart';
import 'widgets/expense_form_sheet.dart';
import 'widgets/expense_list_tile.dart';
import 'widgets/spending_by_category_chart.dart';

/// Filter state for this screen — kept local (not a global provider)
/// since search/category filtering here is purely a view concern that
/// no other screen needs to know about.
class _Filters {
  final String query;
  final ExpenseCategory? category;
  const _Filters({this.query = '', this.category});

  _Filters copyWith({String? query, ExpenseCategory? category, bool clearCategory = false}) {
    return _Filters(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  _Filters _filters = const _Filters();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseEntry> _applyFilters(List<ExpenseEntry> entries) {
    return entries.where((e) {
      final matchesCategory = _filters.category == null || e.category == _filters.category;
      final matchesQuery = _filters.query.isEmpty ||
          (e.note?.toLowerCase().contains(_filters.query.toLowerCase()) ?? false) ||
          e.category.label.toLowerCase().contains(_filters.query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expensesAsync = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showExpenseForm(context),
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Something went wrong: $error')),
        data: (allEntries) {
          final filtered = _applyFilters(allEntries);
          final summary = ExpenseSummary.from(allEntries);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryRow(summary: summary),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spending by category', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 12),
                      SpendingByCategoryChart(summary: summary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by note or category',
                ),
                onChanged: (value) => setState(() => _filters = _filters.copyWith(query: value)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('All'),
                        selected: _filters.category == null,
                        onSelected: (_) => setState(() => _filters = _filters.copyWith(clearCategory: true)),
                      ),
                    ),
                    ...ExpenseCategory.values.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.label),
                          selected: _filters.category == cat,
                          onSelected: (_) => setState(() => _filters = _filters.copyWith(category: cat)),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      allEntries.isEmpty
                          ? 'No entries yet. Tap + to add your first one.'
                          : 'Nothing matches your search or filter.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ...filtered.map((entry) {
                  return ExpenseListTile(
                    entry: entry,
                    onTap: () => showExpenseForm(context, entry: entry),
                    onDelete: () => ref.read(expenseControllerProvider).delete(entry.id),
                  );
                }),
              const SizedBox(height: 80), // clears the FAB
            ],
          );
        },
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final ExpenseSummary summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Income',
            value: Formatters.currency(summary.totalIncome),
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Expenses',
            value: Formatters.currency(summary.totalExpense),
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Balance',
            value: Formatters.currency(summary.balance),
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
