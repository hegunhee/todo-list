import 'package:flutter/material.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';

/// 감정 상태 선택 위젯
class StatusSelectorWidget extends StatelessWidget {
  final ExpenseStatus? selectedStatus;
  final ValueChanged<ExpenseStatus?> onChanged;

  const StatusSelectorWidget({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '감정',
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
            final isSelected = selectedStatus == status;
            return GestureDetector(
              onTap: () => onChanged(status),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? status.color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? status.color : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getEmoji(status.label),
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      status.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
