import 'package:flutter/material.dart';
import 'package:itinventory/models/costcenter_item_model.dart';
import 'package:itinventory/services/costcenter_service.dart';

class CostCenterPage extends StatefulWidget {
  @override
  _CostCenterPageState createState() => _CostCenterPageState();
}

class _CostCenterPageState extends State<CostCenterPage> {
  final CostCenterService _service = CostCenterService();
  final _kodeCCController = TextEditingController();
  final _detailController = TextEditingController();
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cost Centers'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _kodeCCController,
            decoration: InputDecoration(
              labelText: 'Cost Center',
              errorText: _kodeCCController.text.isEmpty ? 'Field tidak boleh kosong' : null,
            ),
            onChanged: (value) {
              setState(() {}); // Memperbarui tampilan ketika teks berubah
            },
          ),
          TextField(
            controller: _detailController,
            decoration: InputDecoration(
              labelText: 'Detail',
              errorText: _detailController.text.isEmpty ? 'Field tidak boleh kosong' : null,
            ),
            onChanged: (value) {
              setState(() {}); // Memperbarui tampilan ketika teks berubah
            },
          ),
          ElevatedButton(
            onPressed: _editingId == null ? _addCostCenter : _updateCostCenter,
            child: Text(_editingId == null ? 'Add' : 'Update'),
          ),
          Expanded(
            child: StreamBuilder<List<CostCenter>>(
              stream: _service.getCostCenters(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final costCenters = snapshot.data!;
                return ListView.builder(
                  itemCount: costCenters.length,
                  itemBuilder: (context, index) {
                    final costCenter = costCenters[index];
                    return ListTile(
                      title: Text(costCenter.kodeCC),
                      subtitle: Text(costCenter.detail),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editCostCenter(costCenter),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteCostCenter(costCenter.id),
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

  void _addCostCenter() {
    if (_kodeCCController.text.isEmpty || _detailController.text.isEmpty) {
      _showSnackbar('Semua field harus diisi');
      return;
    }
    final costCenter = CostCenter(
      id: '',
      kodeCC: _kodeCCController.text,
      detail: _detailController.text,
    );
    _service.addCostCenter(costCenter);
    _clearForm();
  }

  void _updateCostCenter() {
    if (_kodeCCController.text.isEmpty || _detailController.text.isEmpty) {
      _showSnackbar('Semua field harus diisi');
      return;
    }
    if (_editingId != null) {
      final costCenter = CostCenter(
        id: _editingId!,
        kodeCC: _kodeCCController.text,
        detail: _detailController.text,
      );
      _service.updateCostCenter(costCenter);
      _clearForm();
    }
  }

  void _editCostCenter(CostCenter costCenter) {
    setState(() {
      _editingId = costCenter.id;
      _kodeCCController.text = costCenter.kodeCC;
      _detailController.text = costCenter.detail;
    });
  }

  void _deleteCostCenter(String id) {
    _service.deleteCostCenter(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _kodeCCController.clear();
      _detailController.clear();
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
