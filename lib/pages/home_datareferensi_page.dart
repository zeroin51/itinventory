import 'package:flutter/material.dart';
import 'package:itinventory/pages/Referensi/devicetype_page.dart';
import 'package:itinventory/pages/Referensi/softwaretype_page.dart';
import 'package:itinventory/pages/Referensi/user_page.dart';
import 'Referensi/companycode_page.dart'; // Import halaman CompanyCodePage
import 'Referensi/locationcode_page.dart'; // Import halaman LocationCodePage
import 'Referensi/costcenter_page.dart'; // Import halaman CostCenterPage

class HomeDatareferensiPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Referensi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Jumlah item per baris
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            // Tombol ke CompanyCodePage
            _buildSquareButton(
              context,
              icon: Icons.business, // Ikon CompanyCode
              label: 'Company Code',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CompanyCodePage()),
                );
              },
            ),

            // Tombol ke LocationCodePage
            _buildSquareButton(
              context,
              icon: Icons.location_city, // Ikon LocationCode
              label: 'Location Code',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationCodePage()),
                );
              },
            ),

            // Tombol ke CostCenterPage
            _buildSquareButton(
              context,
              icon: Icons.account_balance, // Ikon CostCenter
              label: 'Cost Center',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CostCenterPage()),
                );
              },
            ),

            // Tombol ke UserPage
            _buildSquareButton(
              context,
              icon: Icons.verified_user, // Ikon UserPage
              label: 'User',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserPage()),
                );
              },
            ),

            // Tombol ke DeviceType
            _buildSquareButton(
              context,
              icon: Icons.computer_rounded, // Ikon CostCenter
              label: 'Device Type',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeviceTypePage()),
                );
              },
            ),

            // Tombol ke SoftwareType
            _buildSquareButton(
              context,
              icon: Icons.android_rounded, // Ikon CostCenter
              label: 'Software Type',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SoftwareTypePage()),
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
