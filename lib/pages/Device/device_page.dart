import 'package:itinventory/pages/device/device_detail_page.dart';
import 'package:flutter/material.dart';
import '/services/device_service.dart'; // Import service CRUD
import '/models/device_item_model.dart'; // Import model DeviceItem
import 'add_device_page.dart'; // Halaman untuk tambah data


class DevicePage extends StatefulWidget {
  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  TextEditingController _searchController = TextEditingController();
  List<DeviceItem> _allItems = [];
  List<DeviceItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredItems = _allItems.where((item) {
        return item.noasset.toLowerCase().contains(query) ||
               item.type.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Inventory'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Aksi untuk menambahkan item baru
              Navigator.push(context, MaterialPageRoute(builder: (context) => AddDevicePage()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                filled: true, // Mengaktifkan warna background
                fillColor: Colors.white, // Warna background putih
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<DeviceItem>>(
        stream: getDeviceItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          _allItems = snapshot.data!;
          _filteredItems = _filteredItems.isEmpty && _searchController.text.isEmpty
              ? _allItems
              : _filteredItems;

          return ListView.builder(
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              DeviceItem item = _filteredItems[index];
              return ListTile(
                title: Text(item.noasset),
                subtitle: Text(item.type),
                onTap: () {
                  // Aksi untuk edit item
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DeviceDetailPage(item: item))
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
