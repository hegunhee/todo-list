import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/screens/statistics_screen.dart';
import 'package:expense_tracker/features/expense/screens/emotion_detail_screen.dart';
import '../mocks/mock_expense_service.dart';

void main() {
  late MockExpenseService mockService;

  setUp(() {
    mockService = MockExpenseService();
  });

  group('StatisticsScreen 테스트', () {
    testWidgets('데이터가 없을 때 안내 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: StatisticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 안내 메시지 확인
      expect(find.text('아직 지출 데이터가 없습니다'), findsOneWidget);
      expect(find.byIcon(Icons.insert_chart_outlined), findsOneWidget);
    });

    testWidgets('전체 요약 카드가 표시된다', (tester) async {
      // 샘플 데이터 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: StatisticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 전체 요약 확인
      expect(find.text('전체 지출'), findsOneWidget);
      expect(find.text('10,000원'), findsOneWidget);
      expect(find.text('총 1건'), findsOneWidget);
    });

    testWidgets('감정별 분석이 표시된다', (tester) async {
      // 샘플 데이터 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: StatisticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 감정별 분석 확인
      expect(find.text('감정별 분석'), findsOneWidget);
      expect(find.text('잘 쓴 돈'), findsOneWidget);
      expect(find.text('그저 그런 돈'), findsOneWidget);
      expect(find.text('아까운 돈'), findsOneWidget);
      expect(find.text('후회한 돈'), findsOneWidget);
    });

    testWidgets('퍼센테이지가 올바르게 계산된다', (tester) async {
      // 샘플 데이터 추가 (총 4건)
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심1',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));
      await mockService.addExpense(Expense(
        id: '2',
        title: '점심2',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));
      await mockService.addExpense(Expense(
        id: '3',
        title: '커피',
        amount: 5000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.normal,
        date: DateTime.now(),
      ));
      await mockService.addExpense(Expense(
        id: '4',
        title: '택시',
        amount: 15000,
        category: ExpenseCategory.transport,
        status: ExpenseStatus.regret,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: StatisticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 퍼센테이지 확인 (잘 쓴 돈: 2/4 = 50%)
      expect(find.text('50.0%'), findsOneWidget);
      // 그저 그런 돈과 아까운 돈: 각각 1/4 = 25% (총 2개)
      expect(find.text('25.0%'), findsNWidgets(2));
    });

    testWidgets('감정 카드를 클릭하면 상세 화면으로 이동한다', (tester) async {
      // 샘플 데이터 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: StatisticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 잘 쓴 돈 카드 찾기 (1건 · 10,000원 텍스트로 찾기)
      final goodCard = find.ancestor(
        of: find.text('1건 · 10,000원'),
        matching: find.byType(GestureDetector),
      );

      // 카드 클릭
      await tester.tap(goodCard.first);
      await tester.pumpAndSettle();

      // 상세 화면으로 이동했는지 확인
      expect(find.byType(EmotionDetailScreen), findsOneWidget);
    });

    testWidgets('건수가 0인 감정 카드는 클릭할 수 없다', (tester) async {
      // 잘 쓴 돈만 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: StatisticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 후회한 돈 카드 찾기 (0건)
      final badCard = find.ancestor(
        of: find.text('0건 · 0원'),
        matching: find.byType(GestureDetector),
      );

      // 카드 클릭 시도
      await tester.tap(badCard.first);
      await tester.pumpAndSettle();

      // 상세 화면으로 이동하지 않음
      expect(find.byType(EmotionDetailScreen), findsNothing);
    });

    testWidgets('프로그레스 바가 표시된다', (tester) async {
      // 샘플 데이터 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(home: StatisticsScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 프로그레스 바 확인
      expect(find.byType(LinearProgressIndicator), findsNWidgets(4)); // 4개의 감정
    });
  });

  group('EmotionDetailScreen 테스트', () {
    testWidgets('감정 이름이 앱바에 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: EmotionDetailScreen(status: ExpenseStatus.good),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 앱바에 감정 이름 확인
      expect(find.text('잘 쓴 돈'), findsOneWidget);
    });

    testWidgets('해당 감정의 지출만 표시된다', (tester) async {
      // 다양한 감정의 지출 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '좋은 점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));
      await mockService.addExpense(Expense(
        id: '2',
        title: '아까운 커피',
        amount: 5000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.regret,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: EmotionDetailScreen(status: ExpenseStatus.good),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 잘 쓴 돈만 표시
      expect(find.text('좋은 점심'), findsOneWidget);
      expect(find.text('아까운 커피'), findsNothing);
    });

    testWidgets('요약 카드가 표시된다', (tester) async {
      // 샘플 데이터 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));
      await mockService.addExpense(Expense(
        id: '2',
        title: '저녁',
        amount: 15000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: EmotionDetailScreen(status: ExpenseStatus.good),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 요약 카드 확인
      expect(find.text('총 2건'), findsOneWidget);
      expect(find.text('25,000원'), findsOneWidget);
    });

    testWidgets('데이터가 없을 때 안내 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: EmotionDetailScreen(status: ExpenseStatus.good),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 안내 메시지 확인
      expect(find.text('아직 잘 쓴 돈 지출이 없습니다'), findsOneWidget);
    });

    testWidgets('지출 카드를 클릭하면 수정 화면으로 이동한다', (tester) async {
      // 샘플 데이터 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: EmotionDetailScreen(status: ExpenseStatus.good),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 지출 카드 클릭
      await tester.tap(find.text('점심'));
      await tester.pumpAndSettle();

      // 수정 화면으로 이동 확인
      expect(find.text('지출 수정'), findsOneWidget);
    });

    testWidgets('감정 변경 이력이 표시된다', (tester) async {
      // 감정 변경 이력이 있는 지출 추가
      await mockService.addExpense(Expense(
        id: '1',
        title: '점심',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.regret,
        date: DateTime.now(),
        previousStatus: ExpenseStatus.good,
        statusChangeReason: '생각보다 별로였음',
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(mockService),
          ],
          child: const MaterialApp(
            home: EmotionDetailScreen(status: ExpenseStatus.regret),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 감정 변경 이력 확인
      expect(find.textContaining('생각보다 별로였음'), findsOneWidget);
    });
  });
}
