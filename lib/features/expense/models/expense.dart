import 'package:flutter/material.dart';

/// 지출 카테고리
enum ExpenseCategory {
  food('식비', Icons.restaurant),
  transport('교통', Icons.directions_car),
  shopping('쇼핑', Icons.shopping_bag),
  culture('문화생활', Icons.movie);

  const ExpenseCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 지출 상태 (잘 쓴 돈, 그저 그런 돈, 아까운 돈, 후회한 돈)
enum ExpenseStatus {
  good('잘 쓴 돈', Color(0xFF4CAF50)),
  normal('그저 그런 돈', Color(0xFF9E9E9E)),
  regret('아까운 돈', Color(0xFFFF9800)),
  bad('후회한 돈', Color(0xFFF44336));

  const ExpenseStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// 지출 데이터 모델
class Expense {
  final String id;
  final String title;
  final int amount;
  final ExpenseCategory category;
  final ExpenseStatus status;
  final DateTime date;
  final String? memo;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.status,
    required this.date,
    this.memo,
  });

  Expense copyWith({
    String? id,
    String? title,
    int? amount,
    ExpenseCategory? category,
    ExpenseStatus? status,
    DateTime? date,
    String? memo,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      status: status ?? this.status,
      date: date ?? this.date,
      memo: memo ?? this.memo,
    );
  }
}
