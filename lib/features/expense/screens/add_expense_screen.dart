import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/widgets/expense_form/amount_input_field.dart';
import 'package:expense_tracker/features/expense/widgets/expense_form/category_selector_widget.dart';
import 'package:expense_tracker/features/expense/widgets/expense_form/status_selector_widget.dart';

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
  final _statusChangeReasonController = TextEditingController();

  ExpenseCategory? _selectedCategory = ExpenseCategory.food;
  ExpenseStatus? _selectedStatus = ExpenseStatus.good;
  ExpenseStatus? _originalStatus; // 원래 감정 상태 저장
  
  bool get _isEditMode => widget.expense != null;
  bool get _isStatusChanged => _isEditMode && _originalStatus != null && _originalStatus != _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    
    // 금액 입력 제한 리스너
    _amountController.addListener(() {
      final text = _amountController.text.replaceAll(',', '');
      final amount = int.tryParse(text) ?? 0;
      
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
    });
    
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
      _originalStatus = widget.expense!.status; // 원래 상태 저장
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    _statusChangeReasonController.dispose();
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

    // 감정이 변경되었는데 변경 사유를 입력하지 않은 경우
    if (_isStatusChanged && _statusChangeReasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('감정 변경 사유를 입력해주세요'),
          backgroundColor: Color(0xFFF44336),
        ),
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
      previousStatus: _isStatusChanged ? _originalStatus : widget.expense?.previousStatus,
      statusChangeReason: _isStatusChanged ? _statusChangeReasonController.text.trim() : widget.expense?.statusChangeReason,
    );

    if (_isEditMode) {
      ref.read(expenseControllerProvider.notifier).updateExpense(expense.id, expense);
    } else {
      ref.read(expenseControllerProvider.notifier).addExpense(expense);
    }
    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            '삭제 확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            '삭제 하시겠습니까?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(expenseControllerProvider.notifier).deleteExpense(widget.expense!.id);
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                Navigator.of(context).pop(); // 수정 화면 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('삭제되었습니다'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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
        actions: _isEditMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.black),
                  onPressed: () => _showDeleteDialog(context, ref),
                ),
              ]
            : null,
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

            // 금액 (위젯으로 분리)
            AmountInputField(
              controller: _amountController,
            ),

            const SizedBox(height: 24),

            // 지출 카테고리 (위젯으로 분리)
            CategorySelectorWidget(
              selectedCategory: _selectedCategory,
              onChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

            const SizedBox(height: 24),

            // 감정 카테고리 (위젯으로 분리)
            StatusSelectorWidget(
              selectedStatus: _selectedStatus,
              onChanged: (status) {
                setState(() {
                  _selectedStatus = status;
                });
              },
            ),

            // 감정 변경 사유 (감정이 변경된 경우에만 표시)
            if (_isStatusChanged) ...[
              const SizedBox(height: 24),
              const Text(
                '변경 사유',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _statusChangeReasonController,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: '왜 생각이 바뀌었나요?',
                  hintStyle: const TextStyle(color: Color(0xFF666666)),
                  filled: true,
                  fillColor: const Color(0xFFFFF9E6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFB74D), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFB74D), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ],

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
