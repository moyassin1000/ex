class ExcelSheetModel {
  const ExcelSheetModel({
    required this.name,
    required this.rows,
    required this.maxColumns,
  });

  final String name;
  final List<List<String>> rows;
  final int maxColumns;

  int get maxRows => rows.length;

  bool get isEmpty {
    if (rows.isEmpty) return true;
    return rows.every((row) => row.every((cell) => cell.trim().isEmpty));
  }
}

class ExcelWorkbookModel {
  const ExcelWorkbookModel({
    required this.fileName,
    required this.sheets,
  });

  final String fileName;
  final List<ExcelSheetModel> sheets;

  int get sheetCount => sheets.length;

  bool get isEmpty => sheets.isEmpty || sheets.every((sheet) => sheet.isEmpty);
}
