import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';

/// 감정별 요약 카드 위젯
class EmotionSummaryCard extends StatelessWidget {
  final ExpenseStatus status;
  final int count;
  final int totalAmount;

  const EmotionSummaryCard({
    super.key,
    required this.status,
    required this.count,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(status).withOpacity(0.3),
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
              const Text(
                '총 지출',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${NumberFormat('#,###').format(totalAmount)}원',
                style: const TextStyle(
                  fontSize: 20,
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
}
