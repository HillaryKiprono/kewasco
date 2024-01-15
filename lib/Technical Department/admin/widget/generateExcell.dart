import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:confirmation_success/confirmation_success.dart'; // Import the package
import '../../api_endpoints/api_connections.dart';


class GenerateJobCardExcell extends StatefulWidget {
  GenerateJobCardExcell({super.key});

  @override
  State<GenerateJobCardExcell> createState() => _GenerateJobCardExcellState();
}

class _GenerateJobCardExcellState extends State<GenerateJobCardExcell> {
  late Future<void> generateExcelFuture;
  bool isLoading = false;


  List<Map<String, dynamic>> data = [];

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.get(Uri.parse(API.generateExcel));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  // Future<void> generateExcelFromXAMPP() async {
  //   try {
  //     data = await fetchData();
  //     final excelGenerator = ExcelGenerator(data);
  //     await excelGenerator.generateExcelDocument();
  //   } catch (e) {
  //     // Handle error if fetching data or generating Excel fails
  //     print('Error generating Excel: $e');
  //   }
  // }

  Future<void> generateExcelFromXAMPP() async {
    try {
      setState(() {
        isLoading = true;
      });
      data = await fetchData();
      final excelGenerator = ExcelGenerator(data);
      await excelGenerator.generateExcelDocument();
      // Show the confirmation success dialog
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return const ConfirmationSuccess(
      //         reactColor: Colors.yellow,
      //         bubbleColors: [],
      //         numofBubbles: 35,
      //         maxBubbleRadius: 8,
      //         child: Text("VOILA!",
      //             style: TextStyle(color: Colors.black, fontSize: 18)));
      //
      //   },
      // );
    } catch (e) {
      // Handle error if fetching data or generating Excel fails
      print('Error generating Excel: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the Future in initState so that it's only called once
    generateExcelFuture = generateExcelFromXAMPP();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? SpinKitWave(
            color: Colors.blue
        ) // Use SpinKitFadingCircle
            : ElevatedButton(
          onPressed: () {
            setState(() {
              // Reset the Future when the button is pressed again
              generateExcelFuture = generateExcelFromXAMPP();
            });
          },
          child: Text("Generate Excel"),
        ),
      ),
    );
  }
}



class ExcelGenerator {
  List<Map<String, dynamic>> data;

  ExcelGenerator(this.data);

  Future<void> generateExcelDocument() async  {
    // Create Excel workbook and sheet
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // Add headers to the sheet
    var headers = [
      'AccountNo',
      'DateStarted',
      'TimeStarted',
      'Department',
      'Section',
      'SelectedTaskName',
      'WorkLocation',
      'Northings',
      'Eastings',
      'WorkStatus',
      'DateCompleted',
      'TimeCompleted',
      'WorkDescription',
      'Material',
      'AssignedWorker',
      'Supervisor',
    ];

    for (var col = 0; col < headers.length; col++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).value = headers[col];
    }

    // Add data rows to the sheet
    for (var row = 0; row < data.length; row++) {
      final rowData = data[row];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1)).value = rowData['accountNo'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1)).value = rowData['dateStarted'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row + 1)).value = rowData['timeStarted'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row + 1)).value = rowData['department'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row + 1)).value = rowData['section'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row + 1)).value = rowData['selectedTaskName'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row + 1)).value = rowData['workLocation'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row + 1)).value = rowData['northings'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row + 1)).value = rowData['eastings'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: row + 1)).value = rowData['workStatus'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: row + 1)).value = rowData['dateCompleted'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 11, rowIndex: row + 1)).value = rowData['timeCompleted'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 12, rowIndex: row + 1)).value = rowData['workDescription'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 13, rowIndex: row + 1)).value = rowData['material'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 14, rowIndex: row + 1)).value = rowData['assignedWorker'];
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 15, rowIndex: row + 1)).value = rowData['username'];

    }


    // Save the Excel file
    final directory = await getApplicationDocumentsDirectory();
 //   final filePath = '${directory.path}/JobCard Report.xlsx';
    final filePath = 'C:\\Users\\Developer\\Documents\\JobCard Report.xlsx';


    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!); // Use non-nullable List<int>


    // Open the generated Excel file using the default app for .xlsx files
    if (await file.exists()) {
      await Process.run('open', [filePath]);
    }
  }
}
