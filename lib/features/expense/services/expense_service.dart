import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';

/// 지출 데이터 처리 서비스
class ExpenseService {
  static const String _boxName = 'expenses';
  Box<Expense>? _box;

  /// Hive Box 초기화
  Future<void> init() async {
    _box = await Hive.openBox<Expense>(_boxName);
    
    // 첫 실행 시 샘플 데이터 추가
    if (_box!.isEmpty) {
      await _addSampleData();
    }
  }

  /// 샘플 데이터 추가
  Future<void> _addSampleData() async {
    final sampleExpenses = [
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

    for (final expense in sampleExpenses) {
      await _box!.put(expense.id, expense);
    }
  }

  /// 모든 지출 조회
  List<Expense> getAllExpenses() {
    if (_box == null) return [];
    return _box!.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // 최신순 정렬
  }

  /// 지출 추가
  Future<void> addExpense(Expense expense) async {
    await _box?.put(expense.id, expense);
  }

  /// 지출 수정
  Future<void> updateExpense(Expense expense) async {
    await _box?.put(expense.id, expense);
  }

  /// 지출 삭제
  Future<void> deleteExpense(String id) async {
    await _box?.delete(id);
  }

  /// 제목으로 검색 (향후 검색 기능용)
  List<Expense> searchByTitle(String query) {
    if (_box == null || query.isEmpty) return getAllExpenses();
    
    return _box!.values
        .where((expense) => expense.title.toLowerCase().contains(query.toLowerCase()))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// 카테고리별 필터링
  List<Expense> filterByCategory(ExpenseCategory category) {
    if (_box == null) return [];
    
    return _box!.values
        .where((expense) => expense.category == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// 상태별 필터링
  List<Expense> filterByStatus(ExpenseStatus status) {
    if (_box == null) return [];
    
    return _box!.values
        .where((expense) => expense.status == status)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }
}
