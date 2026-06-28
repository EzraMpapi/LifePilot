import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/expense_entry.dart';
import '../expense_providers.dart';

/// Opens the add/edit form as a modal bottom sheet. Pass an existing
/// [entry] to edit it; omit it to create a new one.
Future<void> showExpenseForm(BuildContext context, {ExpenseEntry? entry}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ExpenseForm(entry: entry),
  );
}

class _ExpenseForm extends ConsumerStatefulWidget {
  final ExpenseEntry? entry;
  const _ExpenseForm({this.entry});

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(
    text: widget.entry != null ? widget.entry!.amount.toStringAsFixed(0) : '',
  );
  late final _noteController = TextEditingController(text: widget.entry?.note ?? '');
  late ExpenseCategory _category = widget.entry?.category ?? ExpenseCategory.food;
  late TransactionType _type = widget.entry?.type ?? TransactionType.expense;
  late DateTime _date = widget.entry?.date ?? DateTime.now();
  bool _saving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final amount = double.parse(_amountController.text.trim());
    final controller = ref.read(expenseControllerProvider);

    if (_isEditing) {
      await controller.edit(widget.entry!.copyWith(
        amount: amount,
        category: _category,
        type: _type,
        date: _date,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      ));
    } else {
      await controller.add(
        amount: amount,
        category: _category,
        type: _type,
        date: _date,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEditing ? 'Edit entry' : 'Add entry',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
                    ButtonSegment(value: TransactionType.income, label: Text('Income')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) => setState(() => _type = selection.first),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: !_isEditing,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Enter an amount';
                    final parsed = double.tryParse(value.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ExpenseCategory>(
                  // Using `value` (not the newer `initialValue`) deliberately —
                  // `initialValue` was only added after Flutter 3.33, and this
                  // project's pubspec.yaml floor is 3.3.0. If your SDK is recent
                  // enough to warn that `value` is deprecated, that's expected
                  // and safe to ignore, or switch to `initialValue` yourself.
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ExpenseCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(cat.icon, size: 18, color: cat.color),
                          const SizedBox(width: 10),
                          Text(cat.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(
                      '${_date.day}/${_date.month}/${_date.year}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note (optional)'),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save changes' : 'Add entry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
