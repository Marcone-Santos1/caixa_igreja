import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_theme.dart';
import 'app/router.dart';
import 'features/security/lock_screen.dart';
import 'providers/pin_lock_provider.dart';
import 'providers/shared_preferences_provider.dart';
import 'providers/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await initializeDateFormatting('pt_BR');
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const CaixaIgrejaApp(),
    ),
  );
}

class CaixaIgrejaApp extends ConsumerWidget {
  const CaixaIgrejaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsLock = ref.watch(needsAppLockProvider);
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final light = caixaIgrejaTheme();
    final dark = caixaIgrejaThemeDark();

    const locale = Locale('pt', 'BR');
    const locDelegates = <LocalizationsDelegate<dynamic>>[
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    if (needsLock) {
      return MaterialApp(
        title: 'Caixa Igreja',
        debugShowCheckedModeBanner: false,
        theme: light,
        darkTheme: dark,
        themeMode: themeMode,
        locale: locale,
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: locDelegates,
        home: const LockScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Caixa Igreja',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: locDelegates,
      routerConfig: router,
    );
  }
}
