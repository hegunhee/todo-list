import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expense/screens/search_screen.dart';
import 'package:expense_tracker/features/expense/screens/statistics_screen.dart';
import 'package:expense_tracker/features/expense/widgets/expense_list/filter_chip_widget.dart';
import 'package:expense_tracker/features/expense/widgets/expense_list/expense_summary_card.dart';
import 'package:expense_tracker/features/expense/widgets/expense_list/empty_expense_state.dart';
import 'package:expense_tracker/features/expense/widgets/expense_list/expense_card_widget.dart';

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
                  FilterChipWidget(
                    label: '전체',
                    isSelected: selectedFilter == null,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(null),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: '잘 쓴 돈',
                    isSelected: selectedFilter == ExpenseStatus.good,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.good),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: '그저 그런 돈',
                    isSelected: selectedFilter == ExpenseStatus.normal,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.normal),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: '아까운 돈',
                    isSelected: selectedFilter == ExpenseStatus.regret,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.regret),
                  ),
                  const SizedBox(width: 8),
                  FilterChipWidget(
                    label: '후회한 돈',
                    isSelected: selectedFilter == ExpenseStatus.bad,
                    onTap: () => ref.read(filterControllerProvider.notifier).setFilter(ExpenseStatus.bad),
                  ),
                ],
              ),
            ),
          ),

          // 총 금액 (위젯으로 분리)
          ExpenseSummaryCard(
            totalAmount: totalAmount,
            selectedFilter: selectedFilter,
          ),

          const SizedBox(height: 8),

          // 지출 목록
          Expanded(
            child: expenses.isEmpty
                ? const EmptyExpenseState()
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
                          ExpenseCardWidget(expense: expense),
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
