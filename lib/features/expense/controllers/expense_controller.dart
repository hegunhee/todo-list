import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/services/expense_service.dart';

/// ExpenseService Provider
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  final service = ExpenseService();
  // 초기화는 ExpenseController에서 수행
  return service;
});

/// 지출 컨트롤러
class ExpenseController extends AsyncNotifier<List<Expense>> {
  late final ExpenseService _service;

  @override
  Future<List<Expense>> build() async {
    _service = ref.read(expenseServiceProvider);
    await _service.init();
    return _service.getAllExpenses();
  }

  /// 지출 추가
  Future<void> addExpense(Expense expense) async {
    await _service.addExpense(expense);
    state = AsyncValue.data([...state.value ?? [], expense]
      ..sort((a, b) => b.date.compareTo(a.date)));
  }

  /// 지출 수정
  Future<void> updateExpense(String id, Expense expense) async {
    await _service.updateExpense(expense);
    state = AsyncValue.data([
      for (final item in state.value ?? [])
        if (item.id == id) expense else item,
    ]..sort((a, b) => b.date.compareTo(a.date)));
  }

  /// 지출 삭제
  Future<void> deleteExpense(String id) async {
    await _service.deleteExpense(id);
    state = AsyncValue.data(
      (state.value ?? []).where((expense) => expense.id != id).toList(),
    );
  }

  /// 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _service.getAllExpenses();
    });
  }
}

/// 지출 컨트롤러 Provider
final expenseControllerProvider = AsyncNotifierProvider<ExpenseController, List<Expense>>(
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
  final expensesAsync = ref.watch(expenseControllerProvider);
  final filter = ref.watch(filterControllerProvider);

  return expensesAsync.when(
    data: (expenses) {
      if (filter == null) {
        return expenses;
      }
      return expenses.where((expense) => expense.status == filter).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

/// 총 지출 금액
final totalExpenseProvider = Provider<int>((ref) {
  final expenses = ref.watch(filteredExpenseProvider);
  return expenses.fold<int>(0, (sum, expense) => sum + expense.amount);
});
