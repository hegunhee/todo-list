import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/screens/add_expense_screen.dart';
import 'package:intl/intl.dart';

/// 감정별 상세 화면
class EmotionDetailScreen extends ConsumerWidget {
  final ExpenseStatus status;

  const EmotionDetailScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getStatusEmoji(status),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              status.label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: status.color,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: expensesAsync.when(
        data: (expenses) {
          // 해당 감정의 지출만 필터링
          final filteredExpenses = expenses.where((e) => e.status == status).toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          if (filteredExpenses.isEmpty) {
            return _buildEmptyState();
          }

          final totalAmount = filteredExpenses.fold(0, (sum, e) => sum + e.amount);

          return Column(
            children: [
              // 상단 요약 카드
              _buildSummaryCard(filteredExpenses.length, totalAmount),
              // 지출 목록
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    return _ExpenseCard(expense: filteredExpenses[index]);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getStatusEmoji(status),
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 16),
          Text(
            '아직 ${status.label} 지출이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int count, int totalAmount) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: status.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: status.color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            _getStatusEmoji(status),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '총 $count건',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${NumberFormat('#,###').format(totalAmount)}원',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusEmoji(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.good:
        return '😊';
      case ExpenseStatus.normal:
        return '😐';
      case ExpenseStatus.regret:
        return '😕';
      case ExpenseStatus.bad:
        return '😩';
    }
  }
}

/// 지출 카드
class _ExpenseCard extends ConsumerWidget {
  const _ExpenseCard({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddExpenseScreen(expense: expense),
          ),
        );
      },
      onLongPress: () {
        _showDeleteDialog(context, ref);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getCategoryColor(expense.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                expense.category.icon,
                color: _getCategoryColor(expense.category),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // 지출 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expense.category.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy년 MM월 dd일').format(expense.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                  // 감정 변경 이력
                  if (expense.previousStatus != null && expense.statusChangeReason != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_getStatusEmoji(expense.previousStatus!)} → ${_getStatusEmoji(expense.status)} ${expense.statusChangeReason}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(expense.status),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // 금액
            Text(
              '${NumberFormat('#,###').format(expense.amount)}원',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.culture:
        return Colors.purple;
    }
  }

  String _getStatusEmoji(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.good:
        return '😊';
      case ExpenseStatus.normal:
        return '😐';
      case ExpenseStatus.regret:
        return '😕';
      case ExpenseStatus.bad:
        return '😩';
    }
  }

  Color _getStatusColor(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.good:
        return const Color(0xFF4CAF50);
      case ExpenseStatus.normal:
        return const Color(0xFF9E9E9E);
      case ExpenseStatus.regret:
        return const Color(0xFFFF9800);
      case ExpenseStatus.bad:
        return const Color(0xFFF44336);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                Navigator.of(context).pop();
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
                ref.read(expenseControllerProvider.notifier).deleteExpense(expense.id);
                Navigator.of(context).pop();
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
}
