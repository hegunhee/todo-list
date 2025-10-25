import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/services/expense_service.dart';

/// Mock ExpenseService for testing
class MockExpenseService implements ExpenseService {
  final List<Expense> _expenses = [];
  bool _initialized = false;

  @override
  Future<void> init() async {
    _initialized = true;
  }

  @override
  List<Expense> getAllExpenses() {
    return List.from(_expenses)..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
  }

  @override
  List<Expense> searchByTitle(String query) {
    if (query.isEmpty) return getAllExpenses();
    
    return _expenses
        .where((expense) => expense.title.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<Expense> filterByCategory(ExpenseCategory category) {
    return _expenses
        .where((expense) => expense.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  List<Expense> filterByStatus(ExpenseStatus status) {
    return _expenses
        .where((expense) => expense.status == status)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
