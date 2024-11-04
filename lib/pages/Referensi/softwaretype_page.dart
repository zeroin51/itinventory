import 'package:flutter/material.dart';
import 'package:itinventory/models/softwaretype_item_model.dart';
import 'package:itinventory/services/softwaretype_service.dart';

class SoftwareTypePage extends StatefulWidget {
  @override
  _SoftwareTypePageState createState() => _SoftwareTypePageState();
}

class _SoftwareTypePageState extends State<SoftwareTypePage> {
  final SoftwaretypeService _service = SoftwaretypeService();
  final _softwareTypeController = TextEditingController();
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Software Types'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _softwareTypeController,
            decoration: InputDecoration(
              labelText: 'Software Type',
              errorText: _softwareTypeController.text.isEmpty ? 'Field tidak boleh kosong' : null,
            ),
            onChanged: (value) {
              setState(() {}); // Memperbarui tampilan saat teks berubah
            },
          ),
          ElevatedButton(
            onPressed: _editingId == null ? _addSoftwareType : _updateSoftwareType,
            child: Text(_editingId == null ? 'Add' : 'Update'),
          ),
          Expanded(
            child: StreamBuilder<List<SoftwareType>>(
              stream: _service.getSoftwareType(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final softwareTypes = snapshot.data!;
                return ListView.builder(
                  itemCount: softwareTypes.length,
                  itemBuilder: (context, index) {
                    final softwareType = softwareTypes[index];
                    return ListTile(
                      title: Text(softwareType.softwaretype),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editSoftwareType(softwareType),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteSoftwareType(softwareType.id),
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

  void _addSoftwareType() {
    if (_softwareTypeController.text.isEmpty) {
      _showSnackbar('Software Type tidak boleh kosong');
      return;
    }
    final softwareType = SoftwareType(
      id: '',
      softwaretype: _softwareTypeController.text,
    );
    _service.addSoftwareType(softwareType);
    _clearForm();
  }

  void _updateSoftwareType() {
    if (_softwareTypeController.text.isEmpty) {
      _showSnackbar('Software Type tidak boleh kosong');
      return;
    }
    if (_editingId != null) {
      final softwareType = SoftwareType(
        id: _editingId!,
        softwaretype: _softwareTypeController.text,
      );
      _service.updateSoftwareType(softwareType);
      _clearForm();
    }
  }

  void _editSoftwareType(SoftwareType softwareType) {
    setState(() {
      _editingId = softwareType.id;
      _softwareTypeController.text = softwareType.softwaretype;
    });
  }

  void _deleteSoftwareType(String id) {
    _service.deleteSoftwareType(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _softwareTypeController.clear();
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
