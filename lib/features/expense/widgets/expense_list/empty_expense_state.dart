import 'package:flutter/material.dart';

/// 지출 내역 없음 상태 위젯
class EmptyExpenseState extends StatelessWidget {
  const EmptyExpenseState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '지출 내역이 없습니다',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF999999),
        ),
      ),
    );
  }
}
