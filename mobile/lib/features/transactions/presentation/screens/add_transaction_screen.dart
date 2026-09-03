import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:finora/shared/models/financial_models.dart';
import 'package:finora/features/dashboard/presentation/providers/finance_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  String _amountString = '0';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _splitController = TextEditingController();
  VibeCategory _selectedCategory = VibeCategory.caffeine;
  bool _isExpense = true;
  String _selectedAccount = 'HDFC UPI';
  bool _showSplitField = false;

  final List<String> _accounts = ['HDFC UPI', 'Credit Card', 'Cash Stash'];

  @override
  void dispose() {
    _titleController.dispose();
    _splitController.dispose();
    super.dispose();
  }

  void _onNumpadTap(String val) {
    setState(() {
      if (val == 'C') {
        _amountString = '0';
      } else if (val == '⌫') {
        if (_amountString.length > 1) {
          _amountString = _amountString.substring(0, _amountString.length - 1);
        } else {
          _amountString = '0';
        }
      } else if (val == '.') {
        if (!_amountString.contains('.')) {
          _amountString += '.';
        }
      } else {
        if (_amountString == '0') {
          _amountString = val;
        } else {
          _amountString += val;
        }
      }
    });
  }

  void _handleSave() {
    final amount = double.tryParse(_amountString) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount greater than 0')),
      );
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? '${_selectedCategory.emoji} ${_selectedCategory.label}'
        : _titleController.text.trim();

    ref.read(financeProvider.notifier).addTransaction(
          title: title,
          amount: amount,
          category: _selectedCategory,
          isExpense: _isExpense,
          accountName: _selectedAccount,
          splitWith: _showSplitField ? _splitController.text.trim() : null,
        );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isExpense ? 'Log Expense 💸' : 'Log Inflow 💰',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          // Expense / Income Toggle
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildTypeSwitch('Out', true),
                _buildTypeSwitch('In', false),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Amount Display ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _isExpense
                            ? AppColors.neonCrimson
                            : AppColors.neonEmerald,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _amountString,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Details Section (Category & Title) ─────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Optional custom note
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'What was this for? (Optional note)',
                        prefixIcon: const Icon(Icons.edit_note,
                            color: AppColors.textMuted),
                        fillColor: AppColors.surfaceCard,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Vibe Category Picker
                    const Text(
                      'SELECT SPENDING VIBE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: VibeCategory.values.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            }
                          },
                          backgroundColor: AppColors.surfaceCard,
                          selectedColor: _isExpense
                              ? AppColors.neonCrimson.withValues(alpha: 0.25)
                              : AppColors.neonEmerald.withValues(alpha: 0.25),
                          side: BorderSide(
                            color: isSelected
                                ? (_isExpense
                                    ? AppColors.neonCrimson
                                    : AppColors.neonEmerald)
                                : AppColors.glassBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(cat.emoji,
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                cat.label,
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Account & Split Toggles Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedAccount,
                                dropdownColor: AppColors.surfaceElevated,
                                icon: const Icon(Icons.keyboard_arrow_down,
                                    color: AppColors.textSecondary),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                items: _accounts.map((acc) {
                                  return DropdownMenuItem(
                                    value: acc,
                                    child: Text(acc),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedAccount = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ActionChip(
                          onPressed: () {
                            setState(() => _showSplitField = !_showSplitField);
                          },
                          backgroundColor: _showSplitField
                              ? AppColors.cyberViolet.withValues(alpha: 0.25)
                              : AppColors.surfaceCard,
                          side: BorderSide(
                            color: _showSplitField
                                ? AppColors.cyberViolet
                                : AppColors.glassBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('👥 Split Bill'),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (_showSplitField) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _splitController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Split with (e.g. Aryan, Riya ₹450 each)',
                          fillColor: AppColors.surfaceCard,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ─── Numeric Keypad ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  _buildNumpadRow(['1', '2', '3']),
                  const SizedBox(height: 8),
                  _buildNumpadRow(['4', '5', '6']),
                  const SizedBox(height: 8),
                  _buildNumpadRow(['7', '8', '9']),
                  const SizedBox(height: 8),
                  _buildNumpadRow(['.', '0', '⌫']),
                  const SizedBox(height: 14),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isExpense
                            ? AppColors.neonCrimson
                            : AppColors.neonEmerald,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _isExpense ? 'Log Expense' : 'Log Inflow',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSwitch(String label, bool isExpenseTab) {
    final isSelected = _isExpense == isExpenseTab;
    return GestureDetector(
      onTap: () => setState(() => _isExpense = isExpenseTab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isExpenseTab ? AppColors.neonCrimson : AppColors.neonEmerald)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => _onNumpadTap(key),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderSubtle),
                ),
                child: Center(
                  child: Text(
                    key,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
