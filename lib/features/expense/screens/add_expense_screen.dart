import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';

/// 지출 추가/수정 화면
class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense; // 수정할 지출 (null이면 추가 모드)
  
  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  ExpenseCategory? _selectedCategory = ExpenseCategory.food;
  ExpenseStatus? _selectedStatus = ExpenseStatus.good;
  
  bool get _isEditMode => widget.expense != null;
  
  @override
  void initState() {
    super.initState();
    // 수정 모드인 경우 기존 데이터로 초기화
    if (_isEditMode) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      _memoController.text = widget.expense!.memo ?? '';
      _selectedCategory = widget.expense!.category;
      _selectedStatus = widget.expense!.status;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지출 이름을 입력해주세요')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('금액을 입력해주세요')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지출 카테고리를 선택해주세요')),
      );
      return;
    }

    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('감정 카테고리를 선택해주세요')),
      );
      return;
    }

    final amount = int.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

    final expense = Expense(
      id: _isEditMode ? widget.expense!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: amount,
      category: _selectedCategory!,
      status: _selectedStatus!,
      date: _isEditMode ? widget.expense!.date : DateTime.now(),
      memo: _memoController.text.isEmpty ? null : _memoController.text,
    );

    if (_isEditMode) {
      ref.read(expenseControllerProvider.notifier).updateExpense(expense.id, expense);
    } else {
      ref.read(expenseControllerProvider.notifier).addExpense(expense);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode ? '지출 수정' : '새로운 지출 추가',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 지출 이름
            const Text(
              '지출 이름',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: '예) 친구와 커피',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 금액
            const Text(
              '금액',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7), // 1,000,000 = 7자리
                _ThousandsSeparatorInputFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '₩0',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) {
                final amount = int.tryParse(value.replaceAll(',', '')) ?? 0;
                if (amount > 1000000) {
                  _amountController.text = '1,000,000';
                  _amountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _amountController.text.length),
                  );
                  
                  // 토스트 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('금액은 100만원을 초과할 수 없습니다'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // 지출 카테고리
            const Text(
              '지출 카테고리',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ExpenseCategory.values.map((category) {
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _CategoryChip(
                    label: category.label,
                    icon: category.icon,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 감정 카테고리
            const Text(
              '감정 카테고리',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ExpenseStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return _EmotionChip(
                  label: status.label,
                  color: status.color,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // 메모
            const Text(
              '메모 (선택 사항)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              maxLines: 3,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                hintText: '메모 추가...',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEditMode ? '수정' : '저장',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 카테고리 칩
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF666666),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 감정 칩
class _EmotionChip extends StatelessWidget {
  const _EmotionChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 2,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              _getEmoji(label),
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmoji(String label) {
    switch (label) {
      case '잘 쓴 돈':
        return '😊';
      case '그저 그런 돈':
        return '😐';
      case '아까운 돈':
        return '😕';
      case '후회한 돈':
        return '😩';
      default:
        return '😊';
    }
  }
}

/// 천 단위 구분 기호 포맷터
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final number = int.tryParse(newValue.text.replaceAll(',', ''));
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatNumber(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
