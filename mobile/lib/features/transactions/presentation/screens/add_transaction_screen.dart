import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String _type = 'EXPENSE';
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type toggle
            Row(
              children: [
                Expanded(child: _TypeButton(label: 'Expense', selected: _type == 'EXPENSE', color: AppColors.expense, onTap: () => setState(() => _type = 'EXPENSE'))),
                const SizedBox(width: 12),
                Expanded(child: _TypeButton(label: 'Income', selected: _type == 'INCOME', color: AppColors.income, onTap: () => setState(() => _type = 'INCOME'))),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: '0.00',
                prefixText: '₹ ',
                border: InputBorder.none,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                hintText: 'Note (optional)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _TypeButton({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
