import 'package:flutter/material.dart';
import 'package:itinventory/models/locationcode_item_model.dart';
import 'package:itinventory/services/locationcode_service.dart';

class LocationCodePage extends StatefulWidget {
  @override
  _LocationCodePageState createState() => _LocationCodePageState();
}

class _LocationCodePageState extends State<LocationCodePage> {
  final LocationCodeService _service = LocationCodeService();
  final _loccodeController = TextEditingController();
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Codes'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _loccodeController,
            decoration: InputDecoration(
              labelText: 'Location Code',
              errorText: _loccodeController.text.isEmpty ? 'Field tidak boleh kosong' : null,
            ),
            onChanged: (value) {
              setState(() {}); // Memperbarui tampilan saat teks berubah
            },
          ),
          ElevatedButton(
            onPressed: _editingId == null ? _addLocationCode : _updateLocationCode,
            child: Text(_editingId == null ? 'Add' : 'Update'),
          ),
          Expanded(
            child: StreamBuilder<List<LocationCode>>(
              stream: _service.getLocationCodes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final locationCodes = snapshot.data!;
                return ListView.builder(
                  itemCount: locationCodes.length,
                  itemBuilder: (context, index) {
                    final locationCode = locationCodes[index];
                    return ListTile(
                      title: Text(locationCode.loccode),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editLocationCode(locationCode),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteLocationCode(locationCode.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addLocationCode() {
    if (_loccodeController.text.isEmpty) {
      _showSnackbar('Loccode tidak boleh kosong');
      return;
    }
    final locationCode = LocationCode(
      id: '',
      loccode: _loccodeController.text,
    );
    _service.addLocationCode(locationCode);
    _clearForm();
  }

  void _updateLocationCode() {
    if (_loccodeController.text.isEmpty) {
      _showSnackbar('Loccode tidak boleh kosong');
      return;
    }
    if (_editingId != null) {
      final locationCode = LocationCode(
        id: _editingId!,
        loccode: _loccodeController.text,
      );
      _service.updateLocationCode(locationCode);
      _clearForm();
    }
  }

  void _editLocationCode(LocationCode locationCode) {
    setState(() {
      _editingId = locationCode.id;
      _loccodeController.text = locationCode.loccode;
    });
  }

  void _deleteLocationCode(String id) {
    _service.deleteLocationCode(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _loccodeController.clear();
    });
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
