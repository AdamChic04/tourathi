import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/providers/app_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class TouRathiApp extends StatefulWidget {
  const TouRathiApp({super.key});

  @override
  State<TouRathiApp> createState() => _TouRathiAppState();
}

class _TouRathiAppState extends State<TouRathiApp> {
  late final AppProvider _appProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appProvider = AppProvider();
    _router = AppRouter.router(_appProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _appProvider,
      child: Consumer<AppProvider>(
        builder: (context, app, _) {
          return MaterialApp.router(
            title: 'TouRathi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(isArabic: app.isArabic),
            darkTheme: AppTheme.darkTheme(isArabic: app.isArabic),
            themeMode: app.themeMode,
            locale: app.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
            builder: (context, child) {
              return Directionality(
                textDirection:
                    app.isArabic ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
