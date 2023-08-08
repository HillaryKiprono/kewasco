import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';

class ExcelGenerator {
  List<Map<String, dynamic>> data;

  ExcelGenerator(this.data);

  Future<void> generateExcelDocument() async {
    // Create Excel workbook and sheet
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add headers to the sheet
    final headers = ['Category Name', 'Asset Name', 'Activity Name', 'Date', 'Time', 'Worker Name', 'Status'];
    for (var col = 0; col < headers.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).value = headers[col];
    }

    // Add data rows to the sheet
    for (var row = 0; row < data.length; row++) {
      final rowData = data[row];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1)).value = rowData['CategoryName'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1)).value = rowData['AssetName'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row + 1)).value = rowData['ActivityName'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row + 1)).value = rowData['Date'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row + 1)).value = rowData['Time'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row + 1)).value = rowData['WorkerName'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row + 1)).value = rowData['Status'];
    }

    // Save the Excel file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Kewasco Maintenance Report.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!); // Use non-nullable List<int>

    // Open the generated Excel file using the default app for .xlsx files
    if (await file.exists()) {
      await Process.run('open', [filePath]);
    }
  }
}
