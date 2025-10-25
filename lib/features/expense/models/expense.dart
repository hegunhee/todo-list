import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'expense.g.dart';

/// 지출 카테고리
@HiveType(typeId: 0)
enum ExpenseCategory {
  @HiveField(0)
  food('식비', Icons.restaurant),
  @HiveField(1)
  transport('교통', Icons.directions_car),
  @HiveField(2)
  shopping('쇼핑', Icons.shopping_bag),
  @HiveField(3)
  culture('문화생활', Icons.movie);

  const ExpenseCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 지출 상태 (잘 쓴 돈, 그저 그런 돈, 아까운 돈, 후회한 돈)
@HiveType(typeId: 1)
enum ExpenseStatus {
  @HiveField(0)
  good('잘 쓴 돈', Color(0xFF4CAF50)),
  @HiveField(1)
  normal('그저 그런 돈', Color(0xFF9E9E9E)),
  @HiveField(2)
  regret('아까운 돈', Color(0xFFFF9800)),
  @HiveField(3)
  bad('후회한 돈', Color(0xFFF44336));

  const ExpenseStatus(this.label, this.color);
  final String label;
  final Color color;
}

/// 지출 데이터 모델
@HiveType(typeId: 2)
class Expense {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final int amount;
  @HiveField(3)
  final ExpenseCategory category;
  @HiveField(4)
  final ExpenseStatus status;
  @HiveField(5)
  final DateTime date;
  @HiveField(6)
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
