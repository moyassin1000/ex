import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

import '../models/excel_sheet_model.dart';

class ExcelReadException implements Exception {
  const ExcelReadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PickedExcelFile {
  const PickedExcelFile({
    required this.name,
    required this.bytes,
  });

  final String name;
  final List<int> bytes;
}

class ExcelService {
  Future<PickedExcelFile?> pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.single;
    final fileName = file.name;

    if (!fileName.toLowerCase().endsWith('.xlsx')) {
      throw const ExcelReadException('من فضلك اختر ملف Excel بصيغة xlsx فقط.');
    }

    final bytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());

    if (bytes == null || bytes.isEmpty) {
      throw const ExcelReadException('تعذر قراءة الملف أو أن الملف فارغ.');
    }

    return PickedExcelFile(name: fileName, bytes: bytes);
  }

  ExcelWorkbookModel readWorkbook({
    required String fileName,
    required List<int> bytes,
  }) {
    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        throw const ExcelReadException('الملف لا يحتوي على أي شيتات.');
      }

      final sheets = <ExcelSheetModel>[];

      for (final sheetName in excel.tables.keys) {
        final sheet = excel.tables[sheetName];
        if (sheet == null) continue;

        final maxColumns = _resolveMaxColumns(sheet);
        final rows = sheet.rows.map((row) {
          final values = List<String>.generate(maxColumns, (index) {
            if (index >= row.length) return '';
            return _cellValueToText(row[index]?.value);
          });
          return values;
        }).toList(growable: false);

        sheets.add(
          ExcelSheetModel(
            name: sheetName,
            rows: rows,
            maxColumns: maxColumns,
          ),
        );
      }

      final workbook = ExcelWorkbookModel(fileName: fileName, sheets: sheets);
      if (workbook.isEmpty) {
        throw const ExcelReadException('تم فتح الملف لكنه لا يحتوي على بيانات قابلة للعرض.');
      }

      return workbook;
    } on ExcelReadException {
      rethrow;
    } catch (_) {
      throw const ExcelReadException(
        'حدث خطأ أثناء قراءة الملف. تأكد أن الملف بصيغة xlsx وغير تالف.',
      );
    }
  }

  int _resolveMaxColumns(Sheet sheet) {
    final detected = sheet.maxColumns;
    if (detected > 0) return detected;

    var maxColumns = 0;
    for (final row in sheet.rows) {
      if (row.length > maxColumns) maxColumns = row.length;
    }
    return maxColumns == 0 ? 1 : maxColumns;
  }

  String _cellValueToText(CellValue? value) {
    return switch (value) {
      null => '',
      TextCellValue() => value.value.toString(),
      FormulaCellValue() => '=${value.formula}',
      IntCellValue() => value.value.toString(),
      BoolCellValue() => value.value ? 'نعم' : 'لا',
      DoubleCellValue() => _formatDouble(value.value),
      DateCellValue() => _formatDate(value.asDateTimeLocal()),
      TimeCellValue() => _formatDuration(value.asDuration()),
      DateTimeCellValue() => _formatDateTime(value.asDateTimeLocal()),
    };
  }

  String _formatDouble(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toString();
  }

  String _formatDate(DateTime value) {
    return '${value.year}-${_two(value.month)}-${_two(value.day)}';
  }

  String _formatDateTime(DateTime value) {
    return '${_formatDate(value)} ${_two(value.hour)}:${_two(value.minute)}';
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    return '${_two(hours)}:${_two(minutes)}:${_two(seconds)}';
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}
