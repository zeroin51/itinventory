import 'package:flutter/material.dart';
import 'package:itinventory/pages/home_asset_page.dart';
import 'package:itinventory/pages/home_datareferensi_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'download_page.dart'; // Import halaman DownloadPage
import 'login_page.dart'; // Import halaman LoginPage

class HomePage extends StatelessWidget {
  Future<bool> _checkIfAdmin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdminLoggedIn') ?? false;
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<bool>(
          future: _checkIfAdmin(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator()); // Loading indicator
            }
            final isAdmin = snapshot.data ?? false;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tombol ke Home Asset Page
                _buildSquareButton(
                  context,
                  icon: Icons.web_asset, // Ikon Asset
                  label: 'Asset',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeAssetPage()),
                    );
                  },
                ),

                SizedBox(height: 20.0), // Jarak antar tombol

                // Tombol ke Data Referensi (hanya untuk admin)
                if (isAdmin) 
                  _buildSquareButton(
                    context,
                    icon: Icons.data_array, // Ikon DataReferensi
                    label: 'Data Referensi',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeDatareferensiPage()),
                      );
                    },
                  ),

                SizedBox(height: 20.0), // Jarak antar tombol

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
            );
          },
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
        padding: EdgeInsets.symmetric(vertical: 55.0), // Jarak atas-bawah diperbesar
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60.0), // Ukuran ikon diperbesar
          SizedBox(height: 10.0), // Jarak antara ikon dan teks
          Text(label, style: TextStyle(fontSize: 20.0)), // Teks diperbesar
        ],
      ),
    );
  }
}
