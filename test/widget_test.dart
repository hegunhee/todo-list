import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expense/controllers/expense_controller.dart';
import 'package:expense_tracker/features/expense/screens/expense_list_screen.dart';
import 'mocks/mock_expense_service.dart';

void main() {
  testWidgets('지출 목록 화면이 정상적으로 렌더링된다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          expenseServiceProvider.overrideWithValue(MockExpenseService()),
        ],
        child: const MaterialApp(home: ExpenseListScreen()),
      ),
    );

    expect(find.byType(ExpenseListScreen), findsOneWidget);
    expect(find.text('지출 목록'), findsOneWidget);
  });
}
