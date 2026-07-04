import 'package:flutter/material.dart';

import '../models/excel_sheet_model.dart';
import '../services/excel_service.dart';
import '../widgets/app_button.dart';
import 'excel_viewer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.themeMode,
    required this.tableFontSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
  });

  final ThemeMode themeMode;
  final double tableFontSize;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<double> onFontSizeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ExcelService _excelService = ExcelService();

  ExcelWorkbookModel? _workbook;
  bool _isLoading = false;
  String? _lastError;

  Future<void> _openExcelFile() async {
    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    try {
      final pickedFile = await _excelService.pickExcelFile();
      if (pickedFile == null) {
        setState(() => _lastError = 'لم يتم اختيار أي ملف.');
        return;
      }

      final workbook = _excelService.readWorkbook(
        fileName: pickedFile.name,
        bytes: pickedFile.bytes,
      );

      if (!mounted) return;
      setState(() => _workbook = workbook);
    } on ExcelReadException catch (error) {
      _showError(error.message);
    } catch (_) {
      _showError('حدث خطأ غير متوقع أثناء فتح الملف.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _lastError = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _closeWorkbook() {
    setState(() {
      _workbook = null;
      _lastError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workbook = _workbook;

    if (workbook != null) {
      return ExcelViewerScreen(
        workbook: workbook,
        themeMode: widget.themeMode,
        tableFontSize: widget.tableFontSize,
        onThemeChanged: widget.onThemeChanged,
        onFontSizeChanged: widget.onFontSizeChanged,
        onCloseFile: _closeWorkbook,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Excel Viewer Pro'),
        actions: [
          IconButton(
            tooltip: widget.themeMode == ThemeMode.dark ? 'الوضع الفاتح' : 'الوضع الداكن',
            onPressed: () => widget.onThemeChanged(
              widget.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
            ),
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.upload_file_rounded,
                          color: colorScheme.primary,
                          size: 50,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'افتح ملف Excel من الهاتف',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'اختر ملف xlsx وسيتم عرض الشيتات والصفوف داخل التطبيق بدون الحاجة إلى Microsoft Excel أو WebView.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'فتح ملف Excel',
                        icon: Icons.folder_open_rounded,
                        onPressed: _isLoading ? null : _openExcelFile,
                      ),
                    ],
                  ),
                ),
              ),
              if (_lastError != null) ...[
                const SizedBox(height: 18),
                _ErrorCard(message: _lastError!),
              ],
              const SizedBox(height: 18),
              const _FeatureGrid(),
            ],
          ),
          if (_isLoading) const _LoadingOverlay(),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.18),
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 18),
                Text('جاري قراءة الملف...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    final features = [
      ('عرض الشيتات', Icons.view_list_rounded),
      ('بحث داخل الصفوف', Icons.search_rounded),
      ('تكبير الخط', Icons.text_increase_rounded),
      ('وضع فاتح وداكن', Icons.contrast_rounded),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: features.map((feature) {
        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 52) / 2,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(feature.$2),
                  const SizedBox(width: 10),
                  Expanded(child: Text(feature.$1)),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}
