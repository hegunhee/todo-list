import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expense/screens/search_screen.dart';
import 'package:expense_tracker/features/expense/screens/statistics_screen.dart';

/// 지출 목록 화면
class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(filteredExpenseProvider);
    final totalAmount = ref.watch(totalExpenseProvider);
    final selectedFilter = ref.watch(filterControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '지출 목록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bar_chart,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black,
              size: 24,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 탭
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterChip(
                    label: '전체',
                    isSelected: selectedFilter == null,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '잘 쓴 돈',
                    isSelected: selectedFilter == ExpenseStatus.good,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.good),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '그저 그런 돈',
                    isSelected: selectedFilter == ExpenseStatus.normal,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.normal),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '아까운 돈',
                    isSelected: selectedFilter == ExpenseStatus.regret,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.regret),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: '후회한 돈',
                    isSelected: selectedFilter == ExpenseStatus.bad,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.bad),
                  ),
                ],
              ),
            ),
          ),

          // 총 금액
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedFilter == null ? '총 지출' : selectedFilter.label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(totalAmount)}원',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 지출 목록
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Text(
                      '지출 내역이 없습니다',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF999999),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final showDate = index == 0 ||
                          !_isSameDay(expense.date, expenses[index - 1].date);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDate) ...[
                            if (index > 0) const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                _formatDate(expense.date),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                            ),
                          ],
                          _ExpenseCard(expense: expense),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return '오늘';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return '어제';
    } else {
      return DateFormat('M월 d일').format(date);
    }
  }
}

/// 필터 칩
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
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
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              expense.category.icon,
              color: const Color(0xFF666666),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 제목, 카테고리, 상태
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
                // 감정 변경이 있는 경우
                if (expense.previousStatus != null && expense.statusChangeReason != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getStatusEmoji(expense.previousStatus!)} ${expense.previousStatus!.label} → ${_getStatusEmoji(expense.status)} ${expense.status.label}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(expense.status),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expense.statusChangeReason!,
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(expense.status),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                else
                  Text(
                    '${_getStatusEmoji(expense.status)} ${expense.status.label}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(expense.status),
                    ),
                  ),
                if (expense.memo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '메모: ${expense.memo!}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
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
