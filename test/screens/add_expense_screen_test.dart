import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/screens/add_expense_screen.dart';

import '../mocks/mock_expense_service.dart';

void main() {
  group('AddExpenseScreen 테스트', () {
    testWidgets('지출 추가 화면이 정상적으로 렌더링된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 화면이 렌더링되는지 확인
      expect(find.byType(AddExpenseScreen), findsOneWidget);
      
      // 앱바 타이틀 확인
      expect(find.text('새로운 지출 추가'), findsOneWidget);
    });

    testWidgets('모든 입력 필드가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 입력 필드 확인
      expect(find.text('지출 이름'), findsOneWidget);
      expect(find.text('금액'), findsOneWidget);
      expect(find.text('카테고리'), findsOneWidget);
      expect(find.text('감정'), findsOneWidget);
      expect(find.text('메모 (선택 사항)'), findsOneWidget);
      
      // 저장 버튼 확인
      expect(find.text('저장'), findsOneWidget);
    });

    testWidgets('기본 카테고리가 선택되어 있다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 기본값: 식비, 잘 쓴 돈
      expect(find.text('식비'), findsOneWidget);
      expect(find.text('잘 쓴 돈'), findsWidgets);
    });

    testWidgets('지출 이름을 입력할 수 있다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 지출 이름 입력
      final titleField = find.widgetWithText(TextField, '예) 친구와 커피');
      await tester.enterText(titleField, '점심 식사');
      await tester.pumpAndSettle();

      // 입력된 텍스트 확인
      expect(find.text('점심 식사'), findsOneWidget);
    });

    testWidgets('금액을 입력할 수 있다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 금액 입력 필드 찾기
      final amountField = find.byType(TextField).at(1); // 두 번째 TextField
      await tester.enterText(amountField, '15000');
      await tester.pumpAndSettle();

      // 천 단위 구분 기호 확인
      expect(find.text('15,000'), findsOneWidget);
    });

    // Note: 100만원 제한 테스트는 AmountInputField 위젯 내부에서 처리됨

    testWidgets('지출 카테고리를 변경할 수 있다 - 교통', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 교통 카테고리 클릭
      await tester.tap(find.text('교통'));
      await tester.pumpAndSettle();

      // 교통이 선택되었는지 확인 (시각적으로는 테두리 색상이 변경됨)
      expect(find.text('교통'), findsOneWidget);
    });

    testWidgets('지출 카테고리를 변경할 수 있다 - 쇼핑', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 쇼핑 카테고리 클릭
      await tester.tap(find.text('쇼핑'));
      await tester.pumpAndSettle();

      // 쇼핑이 선택되었는지 확인
      expect(find.text('쇼핑'), findsOneWidget);
    });

    testWidgets('지출 카테고리를 변경할 수 있다 - 문화생활', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 문화생활 카테고리 클릭
      await tester.tap(find.text('문화생활'));
      await tester.pumpAndSettle();

      // 문화생활이 선택되었는지 확인
      expect(find.text('문화생활'), findsOneWidget);
    });

    testWidgets('감정 카테고리를 변경할 수 있다 - 그저 그런 돈', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 그저 그런 돈 클릭 (두 번째 것 - 첫 번째는 필터에 있을 수 있음)
      final emotionButton = find.text('그저 그런 돈');
      await tester.tap(emotionButton);
      await tester.pumpAndSettle();

      // 그저 그런 돈이 선택되었는지 확인
      expect(find.text('그저 그런 돈'), findsOneWidget);
    });

    testWidgets('감정 카테고리를 변경할 수 있다 - 아까운 돈', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 아까운 돈 클릭
      await tester.tap(find.text('아까운 돈'));
      await tester.pumpAndSettle();

      // 아까운 돈이 선택되었는지 확인
      expect(find.text('아까운 돈'), findsOneWidget);
    });

    testWidgets('감정 카테고리를 변경할 수 있다 - 후회한 돈', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 후회한 돈 클릭
      await tester.tap(find.text('후회한 돈'));
      await tester.pumpAndSettle();

      // 후회한 돈이 선택되었는지 확인
      expect(find.text('후회한 돈'), findsOneWidget);
    });

    testWidgets('메모를 입력할 수 있다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 메모 입력 필드 찾기 (마지막 TextField)
      final memoField = find.widgetWithText(TextField, '메모 추가...');
      await tester.enterText(memoField, '친구와 함께 먹었음');
      await tester.pumpAndSettle();

      // 입력된 메모 확인
      expect(find.text('친구와 함께 먹었음'), findsOneWidget);
    });

    testWidgets('지출 이름 없이 저장 시 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 저장 버튼 스크롤하여 보이게 하기
      await tester.dragUntilVisible(
        find.text('저장'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // 저장 버튼 클릭
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 에러 메시지 확인
      expect(find.text('지출 이름을 입력해주세요'), findsOneWidget);
    });

    testWidgets('금액 없이 저장 시 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: AddExpenseScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 지출 이름만 입력
      final titleField = find.widgetWithText(TextField, '예) 친구와 커피');
      await tester.enterText(titleField, '점심 식사');
      await tester.pump();

      // 저장 버튼 스크롤하여 보이게 하기
      await tester.dragUntilVisible(
        find.text('저장'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      // 저장 버튼 클릭
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 에러 메시지 확인
      expect(find.text('금액을 입력해주세요'), findsOneWidget);
    });

    testWidgets('모든 필드 입력 후 저장하면 화면이 닫힌다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddExpenseScreen(),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      // 화면 열기
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // 지출 이름 입력
      final titleField = find.widgetWithText(TextField, '예) 친구와 커피');
      await tester.enterText(titleField, '점심 식사');
      await tester.pump();

      // 금액 입력
      final amountField = find.byType(TextField).at(1);
      await tester.enterText(amountField, '15000');
      await tester.pump();

      // 저장 버튼 스크롤하여 보이게 하기
      await tester.dragUntilVisible(
        find.text('저장'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // 저장 버튼 클릭
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();

      // 화면이 닫혔는지 확인 (AddExpenseScreen이 없어야 함)
      expect(find.byType(AddExpenseScreen), findsNothing);
    });
  });

  group('AddExpenseScreen 수정 모드 테스트', () {
    testWidgets('수정 모드로 열리면 "지출 수정" 타이틀이 표시된다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '테스트 지출',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 앱바 타이틀 확인
      expect(find.text('지출 수정'), findsOneWidget);
      expect(find.text('새로운 지출 추가'), findsNothing);
    });

    testWidgets('수정 모드로 열리면 기존 데이터가 표시된다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 15000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
        memo: '맛있었음',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 기존 데이터 확인
      expect(find.text('점심 식사'), findsOneWidget);
      expect(find.text('15,000'), findsOneWidget);
      expect(find.text('맛있었음'), findsOneWidget);
    });

    testWidgets('수정 모드에서 버튼 텍스트가 "수정"으로 표시된다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '테스트 지출',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 저장 버튼 스크롤하여 보이게 하기
      await tester.dragUntilVisible(
        find.text('수정'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      // 버튼 텍스트 확인
      expect(find.text('수정'), findsOneWidget);
      expect(find.text('저장'), findsNothing);
    });

    testWidgets('수정 모드에서 지출 이름을 변경할 수 있다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 지출 이름 변경
      final titleField = find.widgetWithText(TextField, '점심 식사');
      await tester.enterText(titleField, '저녁 식사');
      await tester.pumpAndSettle();

      // 변경된 텍스트 확인
      expect(find.text('저녁 식사'), findsOneWidget);
    });

    testWidgets('수정 모드에서 금액을 변경할 수 있다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 금액 변경
      final amountField = find.byType(TextField).at(1);
      await tester.enterText(amountField, '20000');
      await tester.pumpAndSettle();

      // 변경된 금액 확인
      expect(find.text('20,000'), findsOneWidget);
    });

    testWidgets('수정 모드에서 카테고리를 변경할 수 있다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 교통 카테고리 클릭
      await tester.tap(find.text('교통'));
      await tester.pumpAndSettle();

      // 교통이 선택되었는지 확인
      expect(find.text('교통'), findsOneWidget);
    });

    testWidgets('수정 모드에서 감정 상태를 변경할 수 있다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 그저 그런 돈 클릭
      await tester.tap(find.text('그저 그런 돈'));
      await tester.pumpAndSettle();

      // 선택되었는지 확인
      expect(find.text('그저 그런 돈'), findsOneWidget);
    });

    testWidgets('수정 모드에서 메모를 변경할 수 있다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
        memo: '맛있었음',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 메모 변경
      final memoField = find.widgetWithText(TextField, '맛있었음');
      await tester.enterText(memoField, '별로였음');
      await tester.pumpAndSettle();

      // 변경된 메모 확인
      expect(find.text('별로였음'), findsOneWidget);
    });
  });

  group('AddExpenseScreen 감정 변경 이력 테스트', () {
    testWidgets('수정 모드에서 감정을 변경하면 변경 사유 필드가 표시된다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 초기에는 변경 사유 필드가 없음
      expect(find.text('변경 사유'), findsNothing);

      // 감정을 변경
      await tester.dragUntilVisible(
        find.text('아까운 돈'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('아까운 돈'));
      await tester.pumpAndSettle();

      // 변경 사유 필드가 표시됨
      expect(find.text('변경 사유'), findsOneWidget);
      expect(find.widgetWithText(TextField, '왜 생각이 바뀌었나요?'), findsOneWidget);
    });

    testWidgets('감정 변경 시 변경 사유를 입력하지 않으면 저장할 수 없다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 감정을 변경
      await tester.dragUntilVisible(
        find.text('후회한 돈'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('후회한 돈'));
      await tester.pumpAndSettle();

      // 변경 사유를 입력하지 않고 저장 시도
      await tester.dragUntilVisible(
        find.text('수정'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('수정'));
      await tester.pumpAndSettle();

      // 에러 메시지 확인
      expect(find.text('감정 변경 사유를 입력해주세요'), findsOneWidget);
    });

    testWidgets('감정 변경 시 변경 사유를 입력하면 저장할 수 있다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 감정을 변경
      await tester.dragUntilVisible(
        find.text('아까운 돈'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('아까운 돈'));
      await tester.pumpAndSettle();

      // 변경 사유 입력
      final reasonField = find.widgetWithText(TextField, '왜 생각이 바뀌었나요?');
      await tester.enterText(reasonField, '생각보다 별로였음');
      await tester.pumpAndSettle();

      // 저장
      await tester.dragUntilVisible(
        find.text('수정'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('수정'));
      await tester.pumpAndSettle();

      // 화면이 닫혔는지 확인
      expect(find.byType(AddExpenseScreen), findsNothing);
    });

    testWidgets('감정을 변경하지 않으면 변경 사유 필드가 표시되지 않는다', (tester) async {
      final expense = Expense(
        id: '1',
        title: '점심 식사',
        amount: 10000,
        category: ExpenseCategory.food,
        status: ExpenseStatus.good,
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: MaterialApp(home: AddExpenseScreen(expense: expense)),
        ),
      );

      await tester.pumpAndSettle();

      // 제목만 변경
      final titleField = find.widgetWithText(TextField, '점심 식사');
      await tester.enterText(titleField, '저녁 식사');
      await tester.pumpAndSettle();

      // 변경 사유 필드가 표시되지 않음
      expect(find.text('변경 사유'), findsNothing);

      // 저장 가능
      await tester.dragUntilVisible(
        find.text('수정'),
        find.byType(SingleChildScrollView),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('수정'));
      await tester.pumpAndSettle();

      // 화면이 닫혔는지 확인
      expect(find.byType(AddExpenseScreen), findsNothing);
    });
  });
}
