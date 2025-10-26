import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/features/expense/models/expense.dart';

/// 지출 요약 카드 위젯
class ExpenseSummaryCard extends StatelessWidget {
  /// 생성자
  const ExpenseSummaryCard({
    super.key,
    required this.totalAmount,
    this.selectedFilter,
  });

  /// 총 금액
  final int totalAmount;
  /// 선택된 필터
  final ExpenseStatus? selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedFilter == null ? '총 지출' : selectedFilter!.label,
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
    );
  }
}
