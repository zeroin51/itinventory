import 'package:flutter/material.dart';
import 'package:itinventory/models/devicetype_item_model.dart';
import 'package:itinventory/services/devicetype_service.dart';

class DeviceTypePage extends StatefulWidget {
  @override
  _DeviceTypePageState createState() => _DeviceTypePageState();
}

class _DeviceTypePageState extends State<DeviceTypePage> {
  final DevicetypeService _service = DevicetypeService();
  final _deviceTypeController = TextEditingController();
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Types'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _deviceTypeController,
            decoration: InputDecoration(
              labelText: 'Device Type',
              errorText: _deviceTypeController.text.isEmpty ? 'Field tidak boleh kosong' : null,
            ),
            onChanged: (value) {
              setState(() {}); // Memperbarui tampilan ketika teks berubah
            },
          ),
          ElevatedButton(
            onPressed: _editingId == null ? _addDeviceType : _updateDeviceType,
            child: Text(_editingId == null ? 'Add' : 'Update'),
          ),
          Expanded(
            child: StreamBuilder<List<DeviceType>>(
              stream: _service.getDeviceType(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final deviceTypes = snapshot.data!;
                return ListView.builder(
                  itemCount: deviceTypes.length,
                  itemBuilder: (context, index) {
                    final deviceType = deviceTypes[index];
                    return ListTile(
                      title: Text(deviceType.devicetype),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editDeviceType(deviceType),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteDeviceType(deviceType.id),
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

  void _addDeviceType() {
    if (_deviceTypeController.text.isEmpty) {
      _showSnackbar('Device Type tidak boleh kosong');
      return;
    }
    final deviceType = DeviceType(
      id: '',
      devicetype: _deviceTypeController.text,
    );
    _service.addDeviceType(deviceType);
    _clearForm();
  }

  void _updateDeviceType() {
    if (_deviceTypeController.text.isEmpty) {
      _showSnackbar('Device Type tidak boleh kosong');
      return;
    }
    if (_editingId != null) {
      final deviceType = DeviceType(
        id: _editingId!,
        devicetype: _deviceTypeController.text,
      );
      _service.updateDeviceType(deviceType);
      _clearForm();
    }
  }

  void _editDeviceType(DeviceType deviceType) {
    setState(() {
      _editingId = deviceType.id;
      _deviceTypeController.text = deviceType.devicetype;
    });
  }

  void _deleteDeviceType(String id) {
    _service.deleteDeviceType(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _deviceTypeController.clear();
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
