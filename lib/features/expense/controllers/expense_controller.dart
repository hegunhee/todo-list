import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/services/expense_service.dart';

/// 지출 컨트롤러
class ExpenseController extends Notifier<List<Expense>> {
  late final ExpenseService _service;

  @override
  List<Expense> build() {
    _service = ExpenseService();
    return _service.getSampleExpenses();
  }

  /// 지출 추가
  Future<void> addExpense(Expense expense) async {
    await _service.addExpense(expense);
    state = [...state, expense];
  }

  /// 지출 수정
  Future<void> updateExpense(String id, Expense expense) async {
    await _service.updateExpense(expense);
    state = [
      for (final item in state)
        if (item.id == id) expense else item,
    ];
  }

  /// 지출 삭제
  Future<void> deleteExpense(String id) async {
    await _service.deleteExpense(id);
    state = state.where((expense) => expense.id != id).toList();
  }
}

/// 지출 컨트롤러 Provider
final expenseControllerProvider = NotifierProvider<ExpenseController, List<Expense>>(
  ExpenseController.new,
);

/// 필터 컨트롤러
class FilterController extends Notifier<ExpenseStatus?> {
  @override
  ExpenseStatus? build() => null;

  void setFilter(ExpenseStatus? status) {
    state = status;
  }
}

/// 필터 컨트롤러 Provider
final filterControllerProvider = NotifierProvider<FilterController, ExpenseStatus?>(
  FilterController.new,
);

/// 필터링된 지출 목록
final filteredExpenseProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expenseControllerProvider);
  final filter = ref.watch(filterControllerProvider);

  if (filter == null) {
    return expenses;
  }

  return expenses.where((expense) => expense.status == filter).toList();
});

/// 총 지출 금액
final totalExpenseProvider = Provider<int>((ref) {
  final expenses = ref.watch(filteredExpenseProvider);
  return expenses.fold<int>(0, (sum, expense) => sum + expense.amount);
});
