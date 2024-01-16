import 'package:flutter/material.dart';
import 'package:kewasco/user/models/dbHelper.dart';

class StoredDataScreen extends StatefulWidget {
  @override
  _StoredDataScreenState createState() => _StoredDataScreenState();
}

class _StoredDataScreenState extends State<StoredDataScreen> {
  final dbHelper = DatabaseHelper();

  List<Map<String, dynamic>> storedTaskData = [];

  @override
  void initState() {
    super.initState();
    fetchStoredTaskFromDatabase();
  }

  Future<void> fetchStoredTaskFromDatabase() async {
    final List<Map<String, dynamic>> storedTask =
    await dbHelper.queryAllWorkers();

    print('Stored Task Data: $storedTask');

    setState(() {
      storedTaskData = storedTask;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stored Task Names'),
      ),
      body: storedTaskData.isNotEmpty
          ? ListView.builder(
        itemCount: storedTaskData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(storedTaskData[index]['workerName']),
          );
        },
      )
          : Center(
        child: Text('No stored task names.'),
      ),
    );
  }
}
