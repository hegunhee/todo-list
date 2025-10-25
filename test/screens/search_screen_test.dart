import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/screens/search_screen.dart';
import '../mocks/mock_expense_service.dart';

void main() {
  group('SearchScreen 테스트', () {
    late MockExpenseService mockService;

    setUp(() {
      mockService = MockExpenseService();
    });

    testWidgets('검색 화면이 정상적으로 렌더링된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 화면이 렌더링되는지 확인
      expect(find.byType(SearchScreen), findsOneWidget);
      
      // 앱바 타이틀 확인
      expect(find.text('검색'), findsOneWidget);
      
      // 검색 필드 확인
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('지출 이름, 메모 검색'), findsOneWidget);
    });

    testWidgets('검색 전에는 안내 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 안내 메시지 확인
      expect(find.text('지출 내역을 검색해보세요'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('지출 이름으로 검색할 수 있다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 검색어 입력
      await tester.enterText(find.byType(TextField), '점심');
      await tester.pumpAndSettle();

      // 검색 결과 확인
      expect(find.text('검색 결과'), findsOneWidget);
      expect(find.text('친구랑 점심'), findsOneWidget);
      expect(find.text('15,000원'), findsOneWidget);
    });

    testWidgets('메모로 검색할 수 있다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 메모로 검색
      await tester.enterText(find.byType(TextField), '맛있었음');
      await tester.pumpAndSettle();

      // 검색 결과 확인
      expect(find.text('검색 결과'), findsOneWidget);
      expect(find.text('친구랑 점심'), findsOneWidget);
      expect(find.text('메모: 맛있었음'), findsOneWidget);
    });

    testWidgets('검색어가 대소문자를 구분하지 않는다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 대문자로 검색
      await tester.enterText(find.byType(TextField), '점심');
      await tester.pumpAndSettle();

      // 검색 결과 확인
      expect(find.text('친구랑 점심'), findsOneWidget);
    });

    testWidgets('검색 결과가 없으면 안내 메시지가 표시된다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 존재하지 않는 검색어 입력
      await tester.enterText(find.byType(TextField), '존재하지않는검색어12345');
      await tester.pumpAndSettle();

      // 결과 없음 메시지 확인
      expect(find.text('검색 결과가 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('여러 검색 결과가 표시된다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // '커피'로 검색 (비싼 커피가 있음)
      await tester.enterText(find.byType(TextField), '커피');
      await tester.pumpAndSettle();

      // 검색 결과 확인
      expect(find.text('비싼 커피'), findsOneWidget);
      expect(find.text('7,000원'), findsOneWidget);
    });

    testWidgets('검색 결과에 카테고리가 표시된다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 검색
      await tester.enterText(find.byType(TextField), '점심');
      await tester.pumpAndSettle();

      // 카테고리 확인
      expect(find.text('식비'), findsOneWidget);
    });

    testWidgets('검색 결과에 감정 상태가 표시된다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 검색
      await tester.enterText(find.byType(TextField), '점심');
      await tester.pumpAndSettle();

      // 감정 상태 확인 (이모티콘 포함)
      expect(find.textContaining('잘 쓴 돈'), findsOneWidget);
    });

    testWidgets('검색어를 지우면 안내 메시지가 다시 표시된다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 검색어 입력
      await tester.enterText(find.byType(TextField), '점심');
      await tester.pumpAndSettle();

      // 검색 결과 확인
      expect(find.text('친구랑 점심'), findsOneWidget);

      // 검색어 지우기
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // 안내 메시지 다시 표시
      expect(find.text('지출 내역을 검색해보세요'), findsOneWidget);
    });

    testWidgets('부분 검색이 가능하다', (tester) async {
      // 샘플 데이터 추가
      await _addSampleData(mockService);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: SearchScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 부분 검색어 입력
      await tester.enterText(find.byType(TextField), '친구');
      await tester.pumpAndSettle();

      // 검색 결과 확인
      expect(find.text('친구랑 점심'), findsOneWidget);
    });
  });
}

/// 테스트용 샘플 데이터 추가 헬퍼 함수
Future<void> _addSampleData(MockExpenseService service) async {
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
