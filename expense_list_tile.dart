import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/expense_entry.dart';

class ExpenseListTile extends StatelessWidget {
  final ExpenseEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseListTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = entry.type == TransactionType.income;
    final amountColor = isIncome ? theme.colorScheme.primary : theme.colorScheme.error;
    final sign = isIncome ? '+' : '−';

    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: CircleAvatar(
          backgroundColor: entry.category.color.withValues(alpha: 0.15),
          foregroundColor: entry.category.color,
          child: Icon(entry.category.icon, size: 20),
        ),
        title: Text(entry.note?.isNotEmpty == true ? entry.note! : entry.category.label),
        subtitle: Text('${entry.category.label} · ${Formatters.dayMonth(entry.date)}'),
        trailing: Text(
          '$sign${Formatters.currency(entry.amount)}',
          style: theme.textTheme.titleMedium?.copyWith(color: amountColor),
        ),
      ),
    );
  }
}
