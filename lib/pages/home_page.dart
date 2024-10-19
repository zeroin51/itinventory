import 'package:flutter/material.dart';
import 'Device/device_page.dart';
import 'Software/software_page.dart';
import 'download_page.dart'; // Import halaman DownloadPage

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Jumlah item per baris
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // Tombol ke InventoryPage
            _buildSquareButton(
              context,
              icon: Icons.computer, // Ikon Device
              label: 'Device',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DevicePage()),
                );
              },
            ),

            // Tombol ke SoftwarePage
            _buildSquareButton(
              context,
              icon: Icons.adobe, // Ikon Software
              label: 'Software',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SoftwarePage()),
                );
              },
            ),

            // Tombol ke DownloadPage
            _buildSquareButton(
              context,
              icon: Icons.download, // Ikon Download
              label: 'Download',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DownloadPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membuat tombol persegi dengan ikon dan label
  Widget _buildSquareButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Persegi dengan sudut melengkung
        ),
        padding: EdgeInsets.all(16.0), // Jarak dari tepi tombol
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48.0), // Ukuran ikon
          SizedBox(height: 10.0), // Jarak antara ikon dan teks
          Text(label, style: TextStyle(fontSize: 18.0)), // Teks di bawah ikon
        ],
      ),
    );
  }
}
