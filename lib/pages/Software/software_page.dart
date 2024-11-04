import 'package:itinventory/pages/Software/software_detail_page.dart';
import 'package:flutter/material.dart';
import '/services/software_service.dart'; // Import service CRUD
import '/models/software_item_model.dart'; // Import model InventoryItem
import 'add_software_page.dart'; // Halaman untuk tambah data

class SoftwarePage extends StatefulWidget {
  @override
  _SoftwarePageState createState() => _SoftwarePageState();
}

class _SoftwarePageState extends State<SoftwarePage> {
  TextEditingController _searchController = TextEditingController();
  List<SoftwareItem> _allItems = [];
  List<SoftwareItem> _filteredItems = [];
  late Stream<List<SoftwareItem>> _softwareStream;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
    _softwareStream = getSoftwareItems(); // Inisialisasi stream dari Firebase
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

  void _refreshData() {
    setState(() {
      _softwareStream = getSoftwareItems(); // Memuat ulang stream dari Firebase
      _filteredItems.clear(); // Reset hasil filter
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IT Software'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddSoftwarePage())
              );
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
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<SoftwareItem>>(
        stream: _softwareStream,
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
              SoftwareItem item = _filteredItems[index];
              return ListTile(
                title: Text(item.noasset),
                subtitle: Text(item.type),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SoftwareDetailPage(item: item))
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
