# Flutter 화면 분리 가이드

## 📦 현재 프로젝트 구조

```
lib/features/expense/
├── screens/           # 628줄, 490줄 등 큰 파일들
├── widgets/           # 새로 생성! 재사용 가능한 위젯들
├── models/
├── controllers/
└── services/
```

## 🎯 화면 분리 전략

### 1. **Widget 분리** (가장 일반적)
큰 화면을 작은 위젯으로 나누기

**Before (628줄):**
```dart
// add_expense_screen.dart - 모든 코드가 한 파일에
class AddExpenseScreen extends StatefulWidget { ... }
class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // 카테고리 선택 UI (100줄)
  // 감정 선택 UI (100줄)
  // 금액 입력 UI (80줄)
  // 기타 로직 (348줄)
}
```

**After (분리):**
```dart
// add_expense_screen.dart - 메인 로직만 (300줄)
class AddExpenseScreen extends StatefulWidget { ... }
class _AddExpenseScreenState extends State<AddExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CategorySelectorWidget(...),  // widgets/category_selector_widget.dart
          StatusSelectorWidget(...),     // widgets/status_selector_widget.dart
          AmountInputField(...),         // widgets/amount_input_field.dart
        ],
      ),
    );
  }
}
```

### 2. **Presentation/Logic 분리**
UI와 비즈니스 로직 분리

```
screens/
  add_expense_screen.dart        # UI만
controllers/
  add_expense_controller.dart    # 비즈니스 로직
```

### 3. **Feature 기반 분리**
기능별로 폴더 구조화

```
features/expense/
  add/
    screens/
    widgets/
    controllers/
  list/
    screens/
    widgets/
  statistics/
    screens/
    widgets/
```

## 🔧 실제 적용 예시

### 생성된 위젯들:

1. **CategorySelectorWidget** (`widgets/category_selector_widget.dart`)
   - 카테고리 선택 UI
   - 재사용 가능
   - 약 70줄

2. **StatusSelectorWidget** (`widgets/status_selector_widget.dart`)
   - 감정 상태 선택 UI
   - 재사용 가능
   - 약 85줄

3. **AmountInputField** (`widgets/amount_input_field.dart`)
   - 금액 입력 필드
   - 천 단위 구분 포함
   - 약 90줄

### 사용 방법:

```dart
import 'package:expense_tracker/features/expense/widgets/category_selector_widget.dart';
import 'package:expense_tracker/features/expense/widgets/status_selector_widget.dart';
import 'package:expense_tracker/features/expense/widgets/amount_input_field.dart';

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  ExpenseCategory? _selectedCategory;
  ExpenseStatus? _selectedStatus;
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카테고리 선택 (100줄 → 1줄)
        CategorySelectorWidget(
          selectedCategory: _selectedCategory,
          onChanged: (category) => setState(() => _selectedCategory = category),
        ),
        
        const SizedBox(height: 24),
        
        // 감정 선택 (100줄 → 1줄)
        StatusSelectorWidget(
          selectedStatus: _selectedStatus,
          onChanged: (status) => setState(() => _selectedStatus = status),
        ),
        
        const SizedBox(height: 24),
        
        // 금액 입력 (80줄 → 1줄)
        AmountInputField(
          controller: _amountController,
        ),
      ],
    );
  }
}
```

## 📊 분리 효과

| 파일 | Before | After | 감소 |
|------|--------|-------|------|
| add_expense_screen.dart | 628줄 | ~350줄 | -44% |
| 재사용 가능한 위젯 | 0개 | 3개 | +3 |

## 🎨 추가 분리 가능한 부분

### expense_list_screen.dart (490줄)
```dart
widgets/
  expense_card_widget.dart          # 지출 카드 UI
  expense_summary_widget.dart       # 상단 요약 카드
  filter_chip_widget.dart           # 필터 칩들
```

### search_screen.dart (384줄)
```dart
widgets/
  search_bar_widget.dart            # 검색바
  search_result_item.dart           # 검색 결과 아이템
  empty_search_state.dart           # 빈 상태 UI
```

## 💡 Best Practices

### 1. **위젯 분리 기준**
- ✅ 50줄 이상의 독립적인 UI
- ✅ 재사용 가능성이 있는 컴포넌트
- ✅ 명확한 책임이 있는 부분

### 2. **네이밍 규칙**
- `*Widget`: 재사용 가능한 위젯
- `*Screen`: 전체 화면
- `*Card`: 카드 형태 위젯
- `*Item`: 리스트 아이템

### 3. **폴더 구조**
```
lib/features/expense/
├── screens/              # 화면 (Screen)
├── widgets/              # 재사용 위젯 (Widget)
│   ├── common/          # 공통 위젯
│   └── specific/        # 특정 화면용 위젯
├── models/              # 데이터 모델
├── controllers/         # 상태 관리
└── services/            # 비즈니스 로직
```

## 🚀 다음 단계

1. **즉시 적용 가능**: 생성된 3개 위젯을 `add_expense_screen.dart`에 적용
2. **점진적 리팩토링**: 다른 화면들도 동일한 패턴으로 분리
3. **테스트 추가**: 각 위젯별 단위 테스트 작성

## 📝 참고 자료

- [Flutter Widget Composition](https://docs.flutter.dev/development/ui/widgets-intro)
- [Effective Dart: Design](https://dart.dev/guides/language/effective-dart/design)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
