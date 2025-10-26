import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';

/// 감정별 지출 없음 상태 위젯
class EmptyEmotionState extends StatelessWidget {
  final ExpenseStatus status;

  const EmptyEmotionState({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
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
