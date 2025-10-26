import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/core/controllers/theme_controller.dart';
import 'package:expense_tracker/core/themes/app_theme.dart';
import 'package:expense_tracker/features/expense/models/expense.dart';
import 'package:expense_tracker/features/expense/screens/expense_list_screen.dart';
// import 'package:expense_tracker/firebase_options.dart';

/// 앱 시작점
void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Hive 초기화
      await Hive.initFlutter();
      
      // Hive 어댑터 등록
      Hive.registerAdapter(ExpenseCategoryAdapter());
      Hive.registerAdapter(ExpenseStatusAdapter());
      Hive.registerAdapter(ExpenseAdapter());

      // Firebase 초기화 (iOS용 GoogleService-Info.plist 필요)
      // try {
      //   await Firebase.initializeApp(
      //     options: DefaultFirebaseOptions.currentPlatform,
      //   );

      //   // Crashlytics 설정
      //   FlutterError.onError = (errorDetails) {
      //     FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      //   };

      //   // 비동기 에러 처리
      //   PlatformDispatcher.instance.onError = (error, stack) {
      //     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      //     return true;
      //   };
      // } catch (e) {
      //   // Firebase 설정 실패 시 무시 (iOS 시뮬레이터 등)
      //   print('Firebase initialization skipped: $e');
      // }

      await EasyLocalization.ensureInitialized();
      await GoogleFonts.pendingFonts();

      runApp(
        EasyLocalization(
          supportedLocales: const [Locale('ko'), Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('ko'),
          child: const ProviderScope(child: MyApp()),
        ),
      );
    },
    (error, stack) {
      // Zone에서 캐치되지 않은 에러 처리
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      debugPrint('Uncaught error: $error');
    },
  );
}

/// 앱의 루트 위젯
class MyApp extends ConsumerWidget {
  /// MyApp 생성자
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: '쓰는 가계부',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const ExpenseListScreen(),
    );
  }
}
