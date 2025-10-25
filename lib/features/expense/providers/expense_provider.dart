import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';

/// 지출 목록 상태 관리
class ExpenseNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() => _sampleExpenses;

  void addExpense(Expense expense) {
    state = [...state, expense];
  }

  void updateExpense(String id, Expense expense) {
    state = [
      for (final item in state)
        if (item.id == id) expense else item,
    ];
  }

  void deleteExpense(String id) {
    state = state.where((expense) => expense.id != id).toList();
  }
}

/// 지출 목록 Provider
final expenseProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(
  ExpenseNotifier.new,
);

/// 선택된 필터 상태 관리
class SelectedFilterNotifier extends Notifier<ExpenseStatus?> {
  @override
  ExpenseStatus? build() => null;

  void setFilter(ExpenseStatus? status) {
    state = status;
  }
}

/// 선택된 필터 (전체, 잘 쓴 돈, 그저 그런 돈, 아까운 돈)
final selectedFilterProvider = NotifierProvider<SelectedFilterNotifier, ExpenseStatus?>(
  SelectedFilterNotifier.new,
);

/// 필터링된 지출 목록
final filteredExpenseProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expenseProvider);
  final filter = ref.watch(selectedFilterProvider);

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

/// 샘플 데이터
final _sampleExpenses = [
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
    memo: '매모 생각보다 재미없었음',
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
    memo: '매모 세일할 때 샀다!',
  ),
];
