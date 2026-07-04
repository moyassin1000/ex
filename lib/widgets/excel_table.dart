import 'package:flutter/material.dart';

class ExcelTable extends StatefulWidget {
  const ExcelTable({
    super.key,
    required this.rows,
    required this.maxColumns,
    required this.fontSize,
    required this.emptyMessage,
  });

  final List<List<String>> rows;
  final int maxColumns;
  final double fontSize;
  final String emptyMessage;

  @override
  State<ExcelTable> createState() => _ExcelTableState();
}

class _ExcelTableState extends State<ExcelTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  static const double _cellWidth = 150;
  static const double _rowHeight = 48;

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty || widget.rows.every(_rowIsEmpty)) {
      return _EmptyTable(message: widget.emptyMessage);
    }

    final tableWidth = (widget.maxColumns * _cellWidth).clamp(320, 60000).toDouble();
    final header = widget.rows.first;
    final dataRows = widget.rows.length > 1 ? widget.rows.sublist(1) : <List<String>>[];

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          notificationPredicate: (notification) => notification.depth == 1,
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  _TableRowView(
                    values: header,
                    maxColumns: widget.maxColumns,
                    fontSize: widget.fontSize,
                    isHeader: true,
                  ),
                  Expanded(
                    child: dataRows.isEmpty
                        ? _EmptyTable(message: widget.emptyMessage)
                        : Scrollbar(
                            controller: _verticalController,
                            thumbVisibility: true,
                            child: ListView.builder(
                              controller: _verticalController,
                              itemCount: dataRows.length,
                              itemBuilder: (context, index) {
                                return _TableRowView(
                                  values: dataRows[index],
                                  maxColumns: widget.maxColumns,
                                  fontSize: widget.fontSize,
                                  isHeader: false,
                                  isOdd: index.isOdd,
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _rowIsEmpty(List<String> row) {
    return row.every((cell) => cell.trim().isEmpty);
  }
}

class _TableRowView extends StatelessWidget {
  const _TableRowView({
    required this.values,
    required this.maxColumns,
    required this.fontSize,
    required this.isHeader,
    this.isOdd = false,
  });

  final List<String> values;
  final int maxColumns;
  final double fontSize;
  final bool isHeader;
  final bool isOdd;

  static const double _cellWidth = 150;
  static const double _rowHeight = 48;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isHeader
        ? colorScheme.primary
        : isOdd
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : colorScheme.surface;
    final textColor = isHeader ? colorScheme.onPrimary : colorScheme.onSurface;

    return SizedBox(
      height: _rowHeight,
      child: Row(
        children: List.generate(maxColumns, (index) {
          final value = index < values.length ? values[index] : '';
          return Container(
            width: _cellWidth,
            height: _rowHeight,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: BorderDirectional(
                bottom: BorderSide(color: colorScheme.outlineVariant),
                start: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: _looksArabic(value) ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: isHeader ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          );
        }),
      ),
    );
  }

  bool _looksArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }
}

class _EmptyTable extends StatelessWidget {
  const _EmptyTable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_rows_rounded, size: 52, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
