import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExcelViewerProApp());
}

class ExcelViewerProApp extends StatefulWidget {
  const ExcelViewerProApp({super.key});

  @override
  State<ExcelViewerProApp> createState() => _ExcelViewerProAppState();
}

class _ExcelViewerProAppState extends State<ExcelViewerProApp> {
  static const _themeModeKey = 'theme_mode';
  static const _fontSizeKey = 'table_font_size';

  ThemeMode _themeMode = ThemeMode.light;
  double _tableFontSize = 14;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final storedTheme = prefs.getString(_themeModeKey) ?? 'light';
    final storedFontSize = prefs.getDouble(_fontSizeKey) ?? 14;

    if (!mounted) return;
    setState(() {
      _themeMode = storedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      _tableFontSize = storedFontSize.clamp(11, 24).toDouble();
      _settingsLoaded = true;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');

    if (!mounted) return;
    setState(() => _themeMode = mode);
  }

  Future<void> _setTableFontSize(double value) async {
    final safeValue = value.clamp(11, 24).toDouble();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, safeValue);

    if (!mounted) return;
    setState(() => _tableFontSize = safeValue);
  }

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    );

    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF60A5FA),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excel Viewer Pro',
      themeMode: _themeMode,
      locale: const Locale('ar'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: _buildTheme(lightScheme),
      darkTheme: _buildTheme(darkScheme),
      home: _settingsLoaded
          ? SplashScreen(
              themeMode: _themeMode,
              tableFontSize: _tableFontSize,
              onThemeChanged: _setThemeMode,
              onFontSizeChanged: _setTableFontSize,
            )
          : const _InitialLoader(),
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _InitialLoader extends StatelessWidget {
  const _InitialLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
