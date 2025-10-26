import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/services/expense_service.dart';

void main() {
  group('ExpenseService CRUD 테스트', () {
    late ExpenseService service;
    late Directory testDir;

    setUp(() async {
      // 테스트용 임시 디렉토리 생성
      testDir = Directory.systemTemp.createTempSync('hive_test_');
      
      // Hive 초기화
      Hive.init(testDir.path);
      
      // 어댑터 등록
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ExpenseCategoryAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ExpenseStatusAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(ExpenseAdapter());
      }

      // 서비스 초기화
      service = ExpenseService();
      await service.init();
      
      // 테스트용 샘플 데이터 추가
      await _addSampleData(service);
    });

    tearDown(() async {
      // 테스트 후 박스 삭제 및 정리
      await Hive.close();
      if (testDir.existsSync()) {
        testDir.deleteSync(recursive: true);
      }
    });

    test('샘플 데이터가 정상적으로 조회된다', () {
      final expenses = service.getAllExpenses();
      
      expect(expenses.length, 5);
      // 최신순 정렬되므로 가장 최근 항목 확인
      expect(expenses.any((e) => e.title == '친구랑 점심'), true);
      expect(expenses.any((e) => e.title == '영화 관람'), true);
    });

    test('지출을 추가할 수 있다', () async {
      final newExpense = Expense(
        id: '100',
        title: '테스트 지출',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
        memo: '테스트 메모',
      );

      await service.addExpense(newExpense);
      
      final expenses = service.getAllExpenses();
      expect(expenses.length, 6);
      expect(expenses.any((e) => e.id == '100'), true);
      expect(expenses.firstWhere((e) => e.id == '100').title, '테스트 지출');
    });

    test('지출을 수정할 수 있다', () async {
      final updatedExpense = Expense(
        id: '1',
        title: '수정된 제목',
        amount: 20000,
        category: ExpenseCategory.shopping,
        status: ExpenseStatus.regret,
        date: DateTime.now(),
        memo: '수정된 메모',
      );

      await service.updateExpense(updatedExpense);
      
      final expenses = service.getAllExpenses();
      final updated = expenses.firstWhere((e) => e.id == '1');
      
      expect(updated.title, '수정된 제목');
      expect(updated.amount, 20000);
      expect(updated.category, ExpenseCategory.shopping);
      expect(updated.status, ExpenseStatus.regret);
    });

    test('지출을 삭제할 수 있다', () async {
      await service.deleteExpense('1');
      
      final expenses = service.getAllExpenses();
      expect(expenses.length, 4);
      expect(expenses.any((e) => e.id == '1'), false);
    });

    test('모든 지출을 조회할 수 있다', () {
      final expenses = service.getAllExpenses();
      
      expect(expenses.isNotEmpty, true);
      expect(expenses.length, 5);
    });

    test('지출이 최신순으로 정렬된다', () {
      final expenses = service.getAllExpenses();
      
      for (var i = 0; i < expenses.length - 1; i++) {
        expect(
          expenses[i].date.isAfter(expenses[i + 1].date) ||
          expenses[i].date.isAtSameMomentAs(expenses[i + 1].date),
          true,
        );
      }
    });

    test('제목으로 검색할 수 있다', () {
      final results = service.searchByTitle('점심');
      
      expect(results.length, 1);
      expect(results[0].title, '친구랑 점심');
    });

    test('검색어가 비어있으면 모든 지출을 반환한다', () {
      final results = service.searchByTitle('');
      
      expect(results.length, 5);
    });

    test('검색은 대소문자를 구분하지 않는다', () {
      final results = service.searchByTitle('점심');
      
      expect(results.isNotEmpty, true);
    });

    test('카테고리별로 필터링할 수 있다', () {
      final foodExpenses = service.filterByCategory(ExpenseCategory.food);
      
      expect(foodExpenses.length, 2);
      expect(foodExpenses.every((e) => e.category == ExpenseCategory.food), true);
    });

    test('상태별로 필터링할 수 있다', () {
      final goodExpenses = service.filterByStatus(ExpenseStatus.good);
      
      expect(goodExpenses.length, 2);
      expect(goodExpenses.every((e) => e.status == ExpenseStatus.good), true);
    });

    test('여러 지출을 추가하고 조회할 수 있다', () async {
      final expense1 = Expense(
        id: '101',
        title: '지출1',
        amount: 1000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      final expense2 = Expense(
        id: '102',
        title: '지출2',
        amount: 2000,
        category: ExpenseCategory.transport,
        status: ExpenseStatus.normal,
        date: DateTime.now(),
      );

      await service.addExpense(expense1);
      await service.addExpense(expense2);
      
      final expenses = service.getAllExpenses();
      expect(expenses.length, 7);
    });

    test('존재하지 않는 지출을 삭제해도 에러가 발생하지 않는다', () async {
      await service.deleteExpense('999');
      
      final expenses = service.getAllExpenses();
      expect(expenses.length, 5);
    });

    test('같은 ID로 지출을 추가하면 덮어쓴다', () async {
      final newExpense = Expense(
        id: '1',
        title: '덮어쓰기 테스트',
        amount: 99999,
        category: ExpenseCategory.culture,
        status: ExpenseStatus.bad,
        date: DateTime.now(),
      );

      await service.addExpense(newExpense);
      
      final expenses = service.getAllExpenses();
      final updated = expenses.firstWhere((e) => e.id == '1');
      
      expect(expenses.length, 5); // 개수는 그대로
      expect(updated.title, '덮어쓰기 테스트');
      expect(updated.amount, 99999);
    });
  });
}

/// 테스트용 샘플 데이터 추가 헬퍼 함수
Future<void> _addSampleData(ExpenseService service) async {
  final now = DateTime.now();
  
  final sampleExpenses = [
    Expense(
      id: '1',
      title: '친구랑 점심',
      amount: 15000,
      category: ExpenseCategory.food,
      status: ExpenseStatus.good,
      date: now,
      memo: '맛있었음',
    ),
    Expense(
      id: '2',
      title: '택시비',
      amount: 8000,
      category: ExpenseCategory.transport,
      status: ExpenseStatus.normal,
      date: now.subtract(const Duration(days: 1)),
    ),
    Expense(
      id: '3',
      title: '영화 관람',
      amount: 14000,
      category: ExpenseCategory.culture,
      status: ExpenseStatus.good,
      date: now.subtract(const Duration(days: 2)),
    ),
    Expense(
      id: '4',
      title: '충동 구매한 옷',
      amount: 50000,
      category: ExpenseCategory.shopping,
      status: ExpenseStatus.regret,
      date: now.subtract(const Duration(days: 3)),
      memo: '별로 안 입을 것 같음',
    ),
    Expense(
      id: '5',
      title: '비싼 커피',
      amount: 7000,
      category: ExpenseCategory.food,
      status: ExpenseStatus.bad,
      date: now.subtract(const Duration(days: 4)),
    ),
  ];
  
  for (final expense in sampleExpenses) {
    await service.addExpense(expense);
  }
}
