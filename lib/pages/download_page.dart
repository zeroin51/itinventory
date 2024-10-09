import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:itinventory/models/inventory_item_model.dart'; // Pastikan model ini benar

class DownloadPage extends StatefulWidget {
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  bool _isDownloading = false;

  Future<void> _downloadExcel() async {
    setState(() {
      _isDownloading = true;
    });

    // Meminta izin untuk akses penyimpanan (hanya jika perlu di platform Android/iOS)
    if (await Permission.storage.request().isGranted) {
      // Ambil data dari Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('inventory').get();

      // Buat instance Excel
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Inventory'];

      // Menambahkan header secara manual
      sheetObject.cell(CellIndex.indexByString("A1")).value = 'ID' as CellValue?;
      sheetObject.cell(CellIndex.indexByString("B1")).value = 'No Asset' as CellValue?;
      sheetObject.cell(CellIndex.indexByString("C1")).value = 'No Serial' as CellValue?;
      sheetObject.cell(CellIndex.indexByString("D1")).value = 'Type' as CellValue?;
      sheetObject.cell(CellIndex.indexByString("E1")).value = 'Details' as CellValue?;

      // Menambahkan data satu per satu secara manual
      int rowIndex = 2; // Mulai dari baris ke-2 karena baris pertama adalah header
      for (var doc in snapshot.docs) {
        InventoryItem item = InventoryItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);

        // Update setiap cell dalam baris
        sheetObject.cell(CellIndex.indexByString("A$rowIndex")).value = item.id as CellValue?;
        sheetObject.cell(CellIndex.indexByString("B$rowIndex")).value = item.noasset as CellValue?;
        sheetObject.cell(CellIndex.indexByString("C$rowIndex")).value = item.noserial as CellValue?;
        sheetObject.cell(CellIndex.indexByString("D$rowIndex")).value = item.type as CellValue?;
        sheetObject.cell(CellIndex.indexByString("E$rowIndex")).value = item.details as CellValue?;

        rowIndex++;
      }

      // Simpan file Excel ke penyimpanan perangkat
      Directory? directory = await getExternalStorageDirectory();
      String filePath = '${directory?.path}/inventory_data.xlsx';
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      // Tampilkan pesan jika berhasil
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File berhasil didownload ke $filePath')));
    } else {
      // Tampilkan pesan jika izin ditolak
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Izin penyimpanan tidak diberikan')));
    }

    setState(() {
      _isDownloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download Inventory Data'),
      ),
      body: Center(
        child: _isDownloading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _downloadExcel,
                child: Text('Download Excel'),
              ),
      ),
    );
  }
}
