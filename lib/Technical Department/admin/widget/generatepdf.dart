import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../../api_endpoints/api_connections.dart';
import 'generateExcel.dart';


class ReportScreen extends StatefulWidget {
  ReportScreen({Key? key}) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isGeneratingPDF = false;

  final String apiUrl = API.generateReports;
  List<Map<String, dynamic>> data = [];

  Future<List<Map<String, dynamic>>> fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  Future<void> generateExcelFromXAMPP() async {
    try {
      data = await fetchData();
      final excelGenerator = ExcelGenerator(data);
      await excelGenerator.generateExcelDocument();
    } catch (e) {
      // Handle error if fetching data or generating Excel fails
      print('Error generating Excel: $e');
    }
  }

  Future<void> generatePdf(BuildContext context) async {
    setState(() {
      _isGeneratingPDF = true;
    });
    final data = await fetchData();
    final pdf = pdfWidgets.Document();

    final groupedData = groupDataByCategoryName(data);

    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Kewasco Maintenance Report.pdf';

    final logoImage = pdfWidgets.Image(
      pdfWidgets.MemoryImage((await rootBundle.load('assets/images/logo.png')).buffer.asUint8List()),
      width: 100,
      height: 100,
    );
    final companyName = pdfWidgets.Text(
      'Kericho Water And Sanitation Company',
      style: pdfWidgets.TextStyle(fontSize: 20, fontWeight: pdfWidgets.FontWeight.bold),
    );

    final signatureRow = pdfWidgets.Row(
      mainAxisAlignment: pdfWidgets.MainAxisAlignment.spaceBetween,
      children: [
        pdfWidgets.Text('Name:.......................................................Signature.....................', style: pdfWidgets.TextStyle(fontSize: 14, fontWeight: pdfWidgets.FontWeight.bold)),
       // pdfWidgets.Text('(Sign here)', style: pdfWidgets.TextStyle(fontSize: 14, fontStyle: pdfWidgets.FontStyle.italic)),
      ],
    );
    pdf.addPage(
      pdfWidgets.MultiPage(
        build: (context) => [
          pdfWidgets.Row(children: [logoImage, companyName]),
          pdfWidgets.SizedBox(height: 20),
          ..._generatePaginatedContent(pdf, groupedData),

          pdfWidgets.SizedBox(height: 20), // Add spacing before the signature row
          signatureRow, // Add the signature row at the bottom of the last page
        ],
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    setState(() {
      _isGeneratingPDF = false;
    });
    await OpenFile.open(filePath, type: 'application/pdf');
  }

  List<pdfWidgets.Widget> _generatePaginatedContent(
      pdfWidgets.Document pdf,
      Map<String, List<Map<String, dynamic>>> groupedData,
      ) {
    final pageWidgets = <pdfWidgets.Widget>[];

    for (var entry in groupedData.entries) {
      final categoryIndex = groupedData.keys.toList().indexOf(entry.key) + 1;
      final categoryName = entry.key;
      final categoryData = entry.value;

      final categoryWidgets = _generateCategoryTable(categoryName, categoryData);

      if (pageWidgets.isNotEmpty) {
        pageWidgets.add(pdfWidgets.SizedBox(height: 20)); // Add spacing between tables on different pages
      }

      if (pageWidgets.length + categoryWidgets.length > 40) { // Adjust the number according to your requirement
        breakPage(pdf, pageWidgets);
      }

      pageWidgets.addAll(categoryWidgets);
    }

    return pageWidgets;
  }

  void breakPage(pdfWidgets.Document pdf, List<pdfWidgets.Widget> widgets) {
    pdf.addPage(
      pdfWidgets.MultiPage(
        build: (context) => widgets,
      ),
    );

    widgets.clear();
  }

  List<pdfWidgets.Widget> _generateCategoryTable(
      String categoryName,
      List<Map<String, dynamic>> categoryData,
      ) {
    final assetNames = categoryData.map((item) => item['AssetName']).toSet().toList();
    final rows = <pdfWidgets.TableRow>[];

    for (var assetName in assetNames) {
      final assetData = categoryData.where((item) => item['AssetName'] == assetName).toList();

      final workerData = <String, List<Map<String, dynamic>>>{};

      for (var item in assetData) {
        final workerName = item['WorkerName'];
        if (workerData.containsKey(workerName)) {
          workerData[workerName]!.add(item);
        } else {
          workerData[workerName] = [item];
        }
      }

      var isFirstAsset = true;
      var previousWorkerName = '';

      for (var workerEntry in workerData.entries) {
        final workerName = workerEntry.key;
        final workerItems = workerEntry.value;

        var isFirstWorker = true;

        for (var i = 0; i < workerItems.length; i++) {
          final item = workerItems[i];

          if (isFirstAsset && isFirstWorker) {
            rows.add(
              pdfWidgets.TableRow(
                children: [
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(assetName),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['ActivityName']),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Date']),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Time']),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(workerName),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Status']),
                  ),
                ],
              ),
            );

            isFirstAsset = false;
            isFirstWorker = false;
          } else {
            if (workerName == previousWorkerName) {
              rows.add(
                pdfWidgets.TableRow(
                  children: [
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(''),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['ActivityName']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Date']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Time']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(''),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Status']),
                    ),
                  ],
                ),
              );
            } else {
              rows.add(
                pdfWidgets.TableRow(
                  children: [
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(''),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['ActivityName']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Date']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Time']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(workerName),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Status']),
                    ),
                  ],
                ),
              );
            }
          }

          previousWorkerName = workerName;
        }
      }
    }


    return [
      pdfWidgets.Text(
        '$categoryName',
        style: pdfWidgets.TextStyle(
          fontSize: 18,
          fontWeight: pdfWidgets.FontWeight.bold,
        ),
      ),
      pdfWidgets.SizedBox(height: 10),
      pdfWidgets.Table(
        border: pdfWidgets.TableBorder.all(),
        columnWidths: {
          0: const pdfWidgets.FlexColumnWidth(5),
          1: const pdfWidgets.FlexColumnWidth(5),
          2: const pdfWidgets.FlexColumnWidth(5),
          3: const pdfWidgets.FlexColumnWidth(5),
          4: const pdfWidgets.FlexColumnWidth(5),
          5: const pdfWidgets.FlexColumnWidth(5),
        },
        children: [
          pdfWidgets.TableRow(
            decoration: pdfWidgets.BoxDecoration(
              color: PdfColor.fromHex('#2ea331'),
            ),
            children: [
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'ASSET DETAILS',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'MAINTENANCE ACTIVITY',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'DATE',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'TIME',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'RESPONSIBILITY',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'STATUS REPORT',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
            ],
          ),
          ...rows,
        ],
      ),
    ];
  }

  List<pdfWidgets.Widget> generateCategoryTable(
      int categoryIndex,
      String categoryName,
      List<Map<String, dynamic>> categoryData,
      ) {
    final assetNames = categoryData.map((item) => item['AssetName']).toSet().toList();
    final rows = <pdfWidgets.TableRow>[];

    for (var assetName in assetNames) {
      final assetData = categoryData.where((item) => item['AssetName'] == assetName).toList();

      final workerData = <String, List<Map<String, dynamic>>>{};

      for (var item in assetData) {
        final workerName = item['WorkerName'];
        if (workerData.containsKey(workerName)) {
          workerData[workerName]!.add(item);
        } else {
          workerData[workerName] = [item];
        }
      }

      var isFirstAsset = true;
      var previousWorkerName = '';

      for (var workerEntry in workerData.entries) {
        final workerName = workerEntry.key;
        final workerItems = workerEntry.value;

        var isFirstWorker = true;

        for (var i = 0; i < workerItems.length; i++) {
          final item = workerItems[i];

          if (isFirstAsset && isFirstWorker) {
            rows.add(
              pdfWidgets.TableRow(
                children: [
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(assetName),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['ActivityName']),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Date']),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Time']),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(workerName),
                  ),
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Status']),
                  ),
                ],
              ),
            );

            isFirstAsset = false;
            isFirstWorker = false;
          } else {
            if (workerName == previousWorkerName) {
              rows.add(
                pdfWidgets.TableRow(
                  children: [
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(''),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['ActivityName']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Date']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Time']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(''),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Status']),
                    ),
                  ],
                ),
              );
            } else {
              rows.add(
                pdfWidgets.TableRow(
                  children: [
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(''),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['ActivityName']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Date']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Time']),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(workerName),
                    ),
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Status']),
                    ),
                  ],
                ),
              );
            }
          }

          previousWorkerName = workerName;
        }
      }
    }

    return [
      pdfWidgets.Text(
        '$categoryIndex. $categoryName',
        style: pdfWidgets.TextStyle(
          fontSize: 18,
          fontWeight: pdfWidgets.FontWeight.bold,
        ),
      ),
      pdfWidgets.SizedBox(height: 10),
      pdfWidgets.Table(
        border: pdfWidgets.TableBorder.all(),
        columnWidths: {
          0: const pdfWidgets.FlexColumnWidth(5),
          1: const pdfWidgets.FlexColumnWidth(5),
          2: const pdfWidgets.FlexColumnWidth(5),
          3: const pdfWidgets.FlexColumnWidth(5),
          4: const pdfWidgets.FlexColumnWidth(5),
          5: const pdfWidgets.FlexColumnWidth(5),
        },
        children: [
          pdfWidgets.TableRow(
            decoration: pdfWidgets.BoxDecoration(
              color: PdfColor.fromHex('#2ea331'),
            ),
            children: [
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'ASSET DETAILS',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'MAINTENANCE ACTIVITY',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'DATE',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'TIME',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'RESPONSIBILITY',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'STATUS REPORT',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),




            ],
          ),
          ...rows,
        ],
      ),
    ];
  }

  Map<String, List<Map<String, dynamic>>> groupDataByCategoryName(List<Map<String, dynamic>> data) {
    final groupedData = <String, List<Map<String, dynamic>>>{};
    for (var item in data) {
      final categoryName = item['CategoryName'];
      if (groupedData.containsKey(categoryName)) {
        groupedData[categoryName]!.add(item);
      } else {
        groupedData[categoryName] = [item];
      }
    }
    return groupedData;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Report'),
      ),
      body: Center(
        child: Column(
          children: [
            // Other widgets...
            ElevatedButton(
              onPressed: _isGeneratingPDF
                  ? null
                  : () {
                generatePdf(context);
              },
              child: Text('Generate Report'),
            ),
            const SizedBox(height: 10),
            if (_isGeneratingPDF)
              CircularProgressIndicator(), // Use CircularProgressIndicator here
            ElevatedButton(
              onPressed: () {
                generateExcelFromXAMPP();
              },
              child: const Text('Generate Excel Document'),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Generate Report'),
  //     ),
  //     body: Center(
  //       child: Column(
  //         children: [
  //           // Image.asset(
  //           //   'assets/images/logo.png', // Replace 'assets/logo.png' with the actual path to your logo image
  //           //   width: 100,
  //           //   height: 100,
  //           // ),
  //           // const SizedBox(height: 10),
  //           // const Text(
  //           //   'Your Company Name', // Replace 'Your Company Name' with the actual name of your company
  //           //   style: TextStyle(
  //           //     fontSize: 20,
  //           //     fontWeight: FontWeight.bold,
  //           //   ),
  //           // ),
  //           // const SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: _isGeneratingPDF
  //                 ? null
  //                 : () {
  //               generatePdf(context);
  //             },
  //             child: Text('Generate Report'),
  //           ),
  //
  //           const SizedBox(height: 10),
  //           ElevatedButton(
  //             onPressed: () {
  //               generateExcelFromXAMPP();
  //             },
  //             child: const Text('Generate Excel Document'),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}