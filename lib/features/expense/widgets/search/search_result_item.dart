import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/features/expense/models/expense.dart';

/// 검색 결과 아이템 위젯
class SearchResultItem extends StatelessWidget {
  /// 생성자
  const SearchResultItem({
    super.key,
    required this.expense,
    required this.onTap,
  });

  /// 지출 데이터
  final Expense expense;
  /// 탭 콜백
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 카테고리 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                expense.category.icon,
                color: const Color(0xFF666666),
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
                  Row(
                    children: [
                      Text(
                        _getCategoryLabel(expense.category),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        ' · ${DateFormat('M월 d일').format(expense.date)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 감정 상태 (변경 이력 포함)
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
                  // 메모 (있는 경우)
                  if (expense.memo != null && expense.memo!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '메모: ${expense.memo}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  String _getCategoryLabel(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return '식비';
      case ExpenseCategory.transport:
        return '교통';
      case ExpenseCategory.shopping:
        return '쇼핑';
      case ExpenseCategory.culture:
        return '문화생활';
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
}
