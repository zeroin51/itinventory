import 'package:flutter/material.dart';
import 'package:itinventory/models/companycode_item_model.dart';
import 'package:itinventory/services/companycode_service.dart';

class CompanyCodePage extends StatefulWidget {
  @override
  _CompanyCodePageState createState() => _CompanyCodePageState();
}

class _CompanyCodePageState extends State<CompanyCodePage> {
  final CompanyCodeService _service = CompanyCodeService();
  final _comcodeController = TextEditingController();
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Codes'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _comcodeController,
            decoration: InputDecoration(
              labelText: 'Company Code',
              errorText: _comcodeController.text.isEmpty ? 'Field tidak boleh kosong' : null,
            ),
            onChanged: (value) {
              setState(() {}); // Memperbarui tampilan ketika teks berubah
            },
          ),
          ElevatedButton(
            onPressed: _editingId == null ? _addCompanyCode : _updateCompanyCode,
            child: Text(_editingId == null ? 'Add' : 'Update'),
          ),
          Expanded(
            child: StreamBuilder<List<CompanyCode>>(
              stream: _service.getCompanyCodes(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final companyCodes = snapshot.data!;
                return ListView.builder(
                  itemCount: companyCodes.length,
                  itemBuilder: (context, index) {
                    final companyCode = companyCodes[index];
                    return ListTile(
                      title: Text(companyCode.comcode),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editCompanyCode(companyCode),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteCompanyCode(companyCode.id),
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

  void _addCompanyCode() {
    if (_comcodeController.text.isEmpty) {
      _showSnackbar('Company code tidak boleh kosong');
      return;
    }
    final companyCode = CompanyCode(
      id: '',
      comcode: _comcodeController.text,
    );
    _service.addCompanyCode(companyCode);
    _clearForm();
  }

  void _updateCompanyCode() {
    if (_comcodeController.text.isEmpty) {
      _showSnackbar('Comcode tidak boleh kosong');
      return;
    }
    if (_editingId != null) {
      final companyCode = CompanyCode(
        id: _editingId!,
        comcode: _comcodeController.text,
      );
      _service.updateCompanyCode(companyCode);
      _clearForm();
    }
  }

  void _editCompanyCode(CompanyCode companyCode) {
    setState(() {
      _editingId = companyCode.id;
      _comcodeController.text = companyCode.comcode;
    });
  }

  void _deleteCompanyCode(String id) {
    _service.deleteCompanyCode(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _comcodeController.clear();
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
