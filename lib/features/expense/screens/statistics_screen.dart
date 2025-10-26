import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/screens/emotion_detail_screen.dart';
import 'package:intl/intl.dart';

/// 통계 화면
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '감정 통계',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return _buildEmptyState();
          }

          final stats = _calculateStatistics(expenses);
          final totalAmount = stats.values.fold(0, (sum, stat) => sum + (stat['amount'] as int));
          final totalCount = stats.values.fold(0, (sum, stat) => sum + (stat['count'] as int));

          return _buildStatisticsContent(stats, totalAmount, totalCount, context);
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
          Icon(Icons.insert_chart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('아직 지출 데이터가 없습니다', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(Map<ExpenseStatus, Map<String, dynamic>> stats, int totalAmount, int totalCount, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(totalAmount, totalCount),
          const SizedBox(height: 24),
          const Text('감정별 분석', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 16),
          ...ExpenseStatus.values.map((status) {
            final stat = stats[status]!;
            final count = stat['count'] as int;
            final amount = stat['amount'] as int;
            final percentage = totalCount > 0 ? (count / totalCount * 100) : 0.0;
            return _buildStatCard(status: status, count: count, amount: amount, percentage: percentage, context: context);
          }).toList(),
        ],
      ),
    );
  }

  Map<ExpenseStatus, Map<String, dynamic>> _calculateStatistics(List<Expense> expenses) {
    final stats = <ExpenseStatus, Map<String, dynamic>>{};
    for (var status in ExpenseStatus.values) {
      stats[status] = {'count': 0, 'amount': 0};
    }
    for (var expense in expenses) {
      stats[expense.status]!['count'] = (stats[expense.status]!['count'] as int) + 1;
      stats[expense.status]!['amount'] = (stats[expense.status]!['amount'] as int) + expense.amount;
    }
    return stats;
  }

  Widget _buildSummaryCard(int totalAmount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Color(0xFF4CAF50).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('전체 지출', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('${NumberFormat('#,###').format(totalAmount)}원', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('총 $totalCount건', style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStatCard({required ExpenseStatus status, required int count, required int amount, required double percentage, required BuildContext context}) {
    return GestureDetector(
      onTap: count > 0 ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmotionDetailScreen(status: status),
          ),
        );
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_getStatusEmoji(status), style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(status.label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: status.color)),
                    const SizedBox(height: 4),
                    Text('$count건 · ${NumberFormat('#,###').format(amount)}원', style: const TextStyle(fontSize: 13, color: Color(0xFF666666))),
                  ],
                ),
              ),
              Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: status.color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percentage / 100, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(status.color), minHeight: 8),
          ),
        ],
      ),
      ),
    );
  }

  String _getStatusEmoji(ExpenseStatus status) {
    switch (status) {
      case ExpenseStatus.good: return '😊';
      case ExpenseStatus.normal: return '😐';
      case ExpenseStatus.regret: return '😕';
      case ExpenseStatus.bad: return '😩';
    }
  }
}
