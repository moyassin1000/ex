import 'package:flutter/material.dart';

import '../models/excel_sheet_model.dart';
import '../widgets/app_button.dart';
import '../widgets/excel_table.dart';
import '../widgets/sheet_tabs.dart';

class ExcelViewerScreen extends StatefulWidget {
  const ExcelViewerScreen({
    super.key,
    required this.workbook,
    required this.themeMode,
    required this.tableFontSize,
    required this.onThemeChanged,
    required this.onFontSizeChanged,
    required this.onCloseFile,
  });

  final ExcelWorkbookModel workbook;
  final ThemeMode themeMode;
  final double tableFontSize;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<double> onFontSizeChanged;
  final VoidCallback onCloseFile;

  @override
  State<ExcelViewerScreen> createState() => _ExcelViewerScreenState();
}

class _ExcelViewerScreenState extends State<ExcelViewerScreen> {
  int _selectedSheetIndex = 0;
  String _query = '';

  ExcelSheetModel get _currentSheet => widget.workbook.sheets[_selectedSheetIndex];

  List<List<String>> get _filteredRows {
    final sheet = _currentSheet;
    final query = _query.trim().toLowerCase();
    if (query.isEmpty || sheet.rows.length <= 1) return sheet.rows;

    final header = sheet.rows.first;
    final matches = sheet.rows.skip(1).where((row) {
      return row.join(' ').toLowerCase().contains(query);
    }).toList(growable: false);

    return [header, ...matches];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredRows = _filteredRows;

    return Scaffold(
      appBar: AppBar(
        title: const Text('عارض ملف Excel'),
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: Column(
                children: [
                  _InfoPanel(
                    fileName: widget.workbook.fileName,
                    sheetCount: widget.workbook.sheetCount,
                    sheetName: _currentSheet.name,
                    rowCount: _currentSheet.maxRows,
                  ),
                  const SizedBox(height: 12),
                  SheetTabs(
                    sheetNames: widget.workbook.sheets.map((sheet) => sheet.name).toList(),
                    selectedIndex: _selectedSheetIndex,
                    onSelected: (index) {
                      setState(() {
                        _selectedSheetIndex = index;
                        _query = '';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      hintText: 'بحث داخل الشيت الحالي',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () => setState(() => _query = ''),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _query.isEmpty
                              ? 'إجمالي الصفوف: ${_currentSheet.maxRows}'
                              : 'نتائج البحث: ${filteredRows.length > 0 ? filteredRows.length - 1 : 0}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                      _FontButton(
                        icon: Icons.text_decrease_rounded,
                        tooltip: 'تصغير الخط',
                        onPressed: () => widget.onFontSizeChanged(widget.tableFontSize - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${widget.tableFontSize.toStringAsFixed(0)}'),
                      ),
                      _FontButton(
                        icon: Icons.text_increase_rounded,
                        tooltip: 'تكبير الخط',
                        onPressed: () => widget.onFontSizeChanged(widget.tableFontSize + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ExcelTable(
                  rows: filteredRows,
                  maxColumns: _currentSheet.maxColumns,
                  fontSize: widget.tableFontSize,
                  emptyMessage: _query.isEmpty
                      ? 'لا توجد بيانات في هذا الشيت.'
                      : 'لا توجد نتائج مطابقة للبحث.',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: AppButton(
                label: 'إغلاق الملف',
                icon: Icons.close_rounded,
                isDanger: true,
                onPressed: widget.onCloseFile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.fileName,
    required this.sheetCount,
    required this.sheetName,
    required this.rowCount,
  });

  final String fileName;
  final int sheetCount;
  final String sheetName;
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.description_rounded),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _InfoChip(label: 'الشيتات', value: '$sheetCount')),
                const SizedBox(width: 8),
                Expanded(child: _InfoChip(label: 'الشيت الحالي', value: sheetName)),
                const SizedBox(width: 8),
                Expanded(child: _InfoChip(label: 'الصفوف', value: '$rowCount')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _FontButton extends StatelessWidget {
  const _FontButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
