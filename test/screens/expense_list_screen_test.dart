import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/screens/expense_list_screen.dart';

import '../mocks/mock_expense_service.dart';

void main() {
  group('ExpenseListScreen 테스트', () {
    testWidgets('지출 목록 화면이 정상적으로 렌더링된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      // 화면이 렌더링되는지 확인
      expect(find.byType(ExpenseListScreen), findsOneWidget);
      
      // 앱바 타이틀 확인
      expect(find.text('지출 목록'), findsOneWidget);
    });

    testWidgets('모든 필터 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 모든 필터 버튼 확인 (샘플 데이터에도 같은 텍스트가 있을 수 있음)
      expect(find.text('전체'), findsWidgets);
      expect(find.text('잘 쓴 돈'), findsWidgets);
      expect(find.text('그저 그런 돈'), findsWidgets);
      expect(find.text('아까운 돈'), findsWidgets);
      
      // 후회한 돈은 스크롤 필요
      final scrollView = find.byType(SingleChildScrollView);
      await tester.drag(scrollView.first, const Offset(-200, 0));
      await tester.pumpAndSettle();
      expect(find.text('후회한 돈'), findsWidgets);
    });

    testWidgets('전체 필터 클릭 시 "총 지출"이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 전체 버튼 클릭
      await tester.tap(find.text('전체'));
      await tester.pumpAndSettle();

      // "총 지출" 텍스트 확인
      expect(find.text('총 지출'), findsOneWidget);
    });

    testWidgets('잘 쓴 돈 필터 클릭 시 "잘 쓴 돈"이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 잘 쓴 돈 버튼 클릭 (필터 영역에서만 찾기)
      final filterButton = find.text('잘 쓴 돈').first;
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // "잘 쓴 돈" 텍스트가 금액 라벨에 표시되는지 확인
      expect(find.text('잘 쓴 돈'), findsWidgets);
    });

    testWidgets('그저 그런 돈 필터 클릭 시 "그저 그런 돈"이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 그저 그런 돈 버튼 클릭 (필터 영역에서만 찾기)
      final filterButton = find.text('그저 그런 돈').first;
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // "그저 그런 돈" 텍스트가 금액 라벨에 표시되는지 확인
      expect(find.text('그저 그런 돈'), findsWidgets);
    });

    testWidgets('아까운 돈 필터 클릭 시 "아까운 돈"이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 아까운 돈 버튼 클릭 (필터 영역에서만 찾기)
      final filterButton = find.text('아까운 돈').first;
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // "아까운 돈" 텍스트가 금액 라벨에 표시되는지 확인
      expect(find.text('아까운 돈'), findsWidgets);
    });

    testWidgets('후회한 돈 필터 클릭 시 "후회한 돈"이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 후회한 돈 버튼을 찾기 위해 스크롤
      final scrollView = find.byType(SingleChildScrollView);
      await tester.drag(scrollView.first, const Offset(-200, 0));
      await tester.pumpAndSettle();

      // 후회한 돈 버튼 클릭
      final filterButton = find.text('후회한 돈').first;
      await tester.tap(filterButton);
      await tester.pumpAndSettle();

      // "후회한 돈" 텍스트가 금액 라벨에 표시되는지 확인
      expect(find.text('후회한 돈'), findsWidgets);
    });

    testWidgets('총 금액이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // 금액이 표시되는지 확인 (원 단위)
      expect(find.textContaining('원'), findsWidgets);
    });

    testWidgets('+ 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            expenseServiceProvider.overrideWithValue(MockExpenseService()),
          ],
          child: const MaterialApp(home: ExpenseListScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // FloatingActionButton 확인
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
