# 위젯 구조 가이드

## 📦 위젯 폴더 구조

```
lib/features/expense/widgets/
├── expense_form/              # 지출 입력 폼 관련 위젯
│   ├── category_selector_widget.dart
│   ├── status_selector_widget.dart
│   └── amount_input_field.dart
├── search/                    # 검색 화면 관련 위젯
│   ├── search_bar_widget.dart
│   ├── empty_search_state.dart
│   ├── no_results_state.dart
│   └── search_result_item.dart
└── common/                    # 공통 위젯 (향후 확장)
    └── (공통으로 사용되는 위젯들)
```

## 📊 리팩토링 결과

### 지출 추가/수정 화면 (add_expense_screen.dart)
- **Before**: 628줄
- **After**: 395줄 (-37% 감소)
- **분리된 위젯**: 3개
  - CategorySelectorWidget (70줄)
  - StatusSelectorWidget (85줄)
  - AmountInputField (90줄)

### 검색 화면 (search_screen.dart)
- **Before**: 384줄
- **After**: 145줄 (-62% 감소)
- **분리된 위젯**: 4개
  - SearchBarWidget (52줄)
  - EmptySearchState (30줄)
  - NoResultsState (42줄)
  - SearchResultItem (180줄)

## 🎯 위젯 사용 가이드

### 1. 지출 입력 폼 위젯

#### CategorySelectorWidget
```dart
import 'package:expense_tracker/features/expense/widgets/expense_form/category_selector_widget.dart';

CategorySelectorWidget(
  selectedCategory: _selectedCategory,
  onChanged: (category) {
    setState(() => _selectedCategory = category);
  },
)
```

#### StatusSelectorWidget
```dart
import 'package:expense_tracker/features/expense/widgets/expense_form/status_selector_widget.dart';

StatusSelectorWidget(
  selectedStatus: _selectedStatus,
  onChanged: (status) {
    setState(() => _selectedStatus = status);
  },
)
```

#### AmountInputField
```dart
import 'package:expense_tracker/features/expense/widgets/expense_form/amount_input_field.dart';

AmountInputField(
  controller: _amountController,
)
```

### 2. 검색 화면 위젯

#### SearchBarWidget
```dart
import 'package:expense_tracker/features/expense/widgets/search/search_bar_widget.dart';

SearchBarWidget(
  controller: _searchController,
  onChanged: (value) {
    setState(() => _searchQuery = value);
  },
  onClear: () {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  },
)
```

#### EmptySearchState
```dart
import 'package:expense_tracker/features/expense/widgets/search/empty_search_state.dart';

const EmptySearchState()
```

#### NoResultsState
```dart
import 'package:expense_tracker/features/expense/widgets/search/no_results_state.dart';

NoResultsState(searchQuery: _searchQuery)
```

#### SearchResultItem
```dart
import 'package:expense_tracker/features/expense/widgets/search/search_result_item.dart';

SearchResultItem(
  expense: expense,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  },
)
```

## 📁 폴더별 용도

### expense_form/
지출 추가/수정 화면에서 사용되는 입력 폼 관련 위젯들
- 카테고리 선택
- 감정 상태 선택
- 금액 입력

### search/
검색 화면에서 사용되는 위젯들
- 검색바
- 빈 상태 표시
- 검색 결과 없음 표시
- 검색 결과 아이템

### common/
여러 화면에서 공통으로 사용되는 위젯들 (향후 확장)
- 공통 버튼
- 공통 다이얼로그
- 공통 로딩 인디케이터 등

## 🎨 위젯 분리 원칙

### 1. 분리 기준
- ✅ 50줄 이상의 독립적인 UI
- ✅ 재사용 가능성이 있는 컴포넌트
- ✅ 명확한 책임이 있는 부분
- ✅ 다른 화면에서도 사용될 가능성

### 2. 네이밍 규칙
- `*Widget`: 재사용 가능한 위젯
- `*Screen`: 전체 화면
- `*Item`: 리스트 아이템
- `*State`: 상태 표시 위젯

### 3. 폴더 구조 규칙
- 화면별로 관련 위젯을 그룹화
- 공통 위젯은 `common/` 폴더에
- 특정 기능별로 하위 폴더 생성

## 📈 향후 확장 계획

### 추가 분리 가능한 화면

#### expense_list_screen.dart (490줄)
```
widgets/expense_list/
├── expense_card_widget.dart          # 지출 카드
├── expense_summary_card.dart         # 상단 요약 카드
└── filter_chip_widget.dart           # 필터 칩들
```

#### emotion_detail_screen.dart (406줄)
```
widgets/emotion_detail/
├── emotion_summary_card.dart         # 감정별 요약 카드
└── expense_list_by_emotion.dart      # 감정별 지출 목록
```

#### statistics_screen.dart (179줄)
```
widgets/statistics/
├── pie_chart_widget.dart             # 파이 차트
├── bar_chart_widget.dart             # 막대 차트
└── stats_summary_card.dart           # 통계 요약 카드
```

## 💡 Best Practices

1. **단일 책임 원칙**: 각 위젯은 하나의 명확한 역할만 수행
2. **재사용성**: 다른 화면에서도 사용 가능하도록 설계
3. **독립성**: 외부 의존성 최소화
4. **명확한 인터페이스**: Props를 통한 명확한 데이터 전달
5. **일관된 스타일**: 프로젝트 전체에서 일관된 디자인 유지

## 🔍 참고 자료

- [Flutter Widget Composition](https://docs.flutter.dev/development/ui/widgets-intro)
- [Effective Dart: Design](https://dart.dev/guides/language/effective-dart/design)
- [Flutter Best Practices](https://flutter.dev/docs/development/ui/widgets/layout)
