import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/software_item_model.dart'; // Import model SoftwareItem
import '../models/device_item_model.dart'; // Import model DeviceItem

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  Duration? executionTime;

  Future<List<DeviceItem>> fetchDeviceItems() async {
    List<DeviceItem> items = [];
    try {
      final snapshot = await FirebaseFirestore.instance.collection('device').get();
      for (var doc in snapshot.docs) {
        items.add(DeviceItem.fromMap(doc.data(), doc.id));
      }
    } catch (e) {
      print('Error fetching device items: $e');
    }
    return items;
  }

  Future<List<SoftwareItem>> fetchSoftwareItems() async {
    List<SoftwareItem> items = [];
    try {
      final snapshot = await FirebaseFirestore.instance.collection('software').get();
      for (var doc in snapshot.docs) {
        items.add(SoftwareItem.fromMap(doc.data(), doc.id));
      }
    } catch (e) {
      print('Error fetching software items: $e');
    }
    return items;
  }

  Future<String> getDownloadPath() async {
    Directory? directory = await getExternalStorageDirectory();
    if (directory != null) {
      // Construct a path to the public "Download" folder.
      String newPath = directory.path.split('Android')[0] + 'Download';
      return newPath;
    } else {
      throw Exception('Could not find the download directory');
    }
  }

  Future<void> exportToExcel(List items, String fileName, List<String> headers, Function itemMapper) async {
    final stopwatch = Stopwatch()..start();
    final excel = Excel.createExcel();
    final Sheet sheet = excel[excel.getDefaultSheet()!];

    // Define headers
    for (int i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = headers[i];
    }

    // Fill in data using the provided mapper function.
    for (var row = 0; row < items.length; row++) {
      itemMapper(sheet, items[row], row);
    }

    // Save the Excel file to the main Downloads folder
    try {
      final downloadPath = await getDownloadPath();
      final path = "$downloadPath/$fileName";
      final excelBytes = excel.encode();
      final file = File(path)..createSync(recursive: true);
      file.writeAsBytesSync(excelBytes!);

      setState(() {
        executionTime = stopwatch.elapsed;
      });

      // Display success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Excel file saved to $path'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving file: $e'),
      ));
    }
  }

  void exportDeviceData() async {
    final deviceItems = await fetchDeviceItems();
    final headers = ['ID', 'No Asset', 'No Serial', 'Type', 'Details', 'Image URL'];
    await exportToExcel(
      deviceItems,
      'DeviceData.xlsx',
      headers,
      (Sheet sheet, DeviceItem item, int row) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1)).value = item.id;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1)).value = item.noasset;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row + 1)).value = item.noserial;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row + 1)).value = item.type;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row + 1)).value = item.details;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row + 1)).value = item.imageUrl;
      },
    );
  }

  void exportSoftwareData() async {
    final softwareItems = await fetchSoftwareItems();
    final headers = ['ID', 'No Asset', 'No Serial', 'Type', 'Exp Date', 'Details', 'Image URL'];
    await exportToExcel(
      softwareItems,
      'SoftwareData.xlsx',
      headers,
      (Sheet sheet, SoftwareItem item, int row) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1)).value = item.id;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1)).value = item.noasset;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row + 1)).value = item.noserial;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row + 1)).value = item.type;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row + 1)).value = item.expdate;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: row + 1)).value = item.details;
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row + 1)).value = item.imageUrl;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Export')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              'Export Data to Excel',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('Export Device Data to Excel'),
              onPressed: exportDeviceData,
            ),
          ),
          Center(
            child: ElevatedButton(
              child: Text('Export Software Data to Excel'),
              onPressed: exportSoftwareData,
            ),
          ),
          if (executionTime != null)
            Center(
              child: Text('Execution Time: ${executionTime.toString()}'),
            ),
        ],
      ),
    );
  }
}
