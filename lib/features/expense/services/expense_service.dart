import 'package:expense_tracker/features/expense/models/expense.dart';

/// 지출 데이터 처리 서비스
class ExpenseService {
  /// 샘플 데이터
  List<Expense> getSampleExpenses() {
    return [
      Expense(
        id: '1',
        title: '친구랑 점심',
        amount: 15000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
        memo: null,
      ),
      Expense(
        id: '2',
        title: '영화 관람',
        amount: 12000,
        category: ExpenseCategory.culture,
        status: ExpenseStatus.regret,
        date: DateTime.now(),
        memo: '생각보다 재미없었음',
      ),
      Expense(
        id: '3',
        title: '택시비',
        amount: 6500,
        category: ExpenseCategory.transport,
        status: ExpenseStatus.bad,
        date: DateTime.now().subtract(const Duration(days: 2)),
        memo: null,
      ),
      Expense(
        id: '4',
        title: '카페',
        amount: 5500,
        category: ExpenseCategory.food,
        status: ExpenseStatus.normal,
        date: DateTime.now().subtract(const Duration(days: 2)),
        memo: null,
      ),
      Expense(
        id: '5',
        title: '온라인 쇼핑',
        amount: 42000,
        category: ExpenseCategory.shopping,
        status: ExpenseStatus.good,
        date: DateTime.now().subtract(const Duration(days: 2)),
        memo: '세일할 때 샀다!',
      ),
    ];
  }

  /// 지출 추가
  Future<void> addExpense(Expense expense) async {
    // TODO: 실제 저장 로직 (Firebase, Local DB 등)
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 지출 수정
  Future<void> updateExpense(Expense expense) async {
    // TODO: 실제 수정 로직
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// 지출 삭제
  Future<void> deleteExpense(String id) async {
    // TODO: 실제 삭제 로직
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
