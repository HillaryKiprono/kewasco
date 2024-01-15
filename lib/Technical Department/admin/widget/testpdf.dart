import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../api_endpoints/api_connections2.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;

import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '../widget/generateExcel.dart';


class TestPdf extends StatefulWidget {
  const TestPdf({super.key});

  @override
  State<TestPdf> createState() => _TestPdfState();
}

class _TestPdfState extends State<TestPdf> {
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

                  //add this Column for Comments
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Comments']),
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

                    //add this line for Comments
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Comments']),
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

                    // Add this line for Comments

                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Comments']),
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
          // I added this for Comments
          6: const pdfWidgets.FlexColumnWidth(5),
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

              // I added this for Comments section
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'Comments',
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

                  // I added this for Comments
                  pdfWidgets.Padding(
                    padding: const pdfWidgets.EdgeInsets.all(2),
                    child: pdfWidgets.Text(item['Comments']),
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

                    // i Added this for Comments
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Comments']),
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

                    // I added this for Comments
                    pdfWidgets.Padding(
                      padding: const pdfWidgets.EdgeInsets.all(2),
                      child: pdfWidgets.Text(item['Comments']),
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

              //Comment section
              pdfWidgets.Padding(
                padding: const pdfWidgets.EdgeInsets.all(2),
                child: pdfWidgets.Text(
                  'Comments',
                  style: pdfWidgets.TextStyle(
                    fontWeight: pdfWidgets.FontWeight.bold,
                    fontSize: 8,
                  ),
                ),
              ),




            ],
          ),
          ...rows
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
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppPadding.P10 / 2,
                top: AppPadding.P10 / 2,
                right: AppPadding.P10 / 2),
            child: Card(
              color: AppColors.purpleLight,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Container(
                width: double.infinity,
                child: const ListTile(
                  title: Text(
                    "Generating Reports",
                    style: TextStyle(color: Colors.white),
                  ),
                  // subtitle: Text(
                  //   "7% of Sales Avg.",
                  //   style: TextStyle(color: Colors.white),
                  // ),
                  // trailing: Chip(
                  //   label: Text(
                  //     r"$46,450",
                  //     style: TextStyle(color: Colors.white),
                  //   ),
                  // ),
                ),
              ),
            ),
          ),

          Card(
            color: AppColors.purpleLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: AspectRatio(
              aspectRatio: 1.23,
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(
                        height: 37,
                      ),
                      const Text(
                        'Generate Pdf Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 37,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, left: 6),
                          child: ElevatedButton(onPressed: (){
                            generatePdf(context);
                          },child: Text("Click here Generate Pdf"),),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),

                    ],
                  ),

                ],
              ),
            ),
          ),



         
        ]),
      ),
    );
  }
}
