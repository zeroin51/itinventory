import 'package:flutter/material.dart';
import 'package:itinventory/models/user_item_model.dart';
import 'package:itinventory/services/user_service.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserService _service = UserService();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _editingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildTextField(_usernameController, 'Username'),
            _buildTextField(_nameController, 'Name'),
            _buildTextField(_departmentController, 'Department'),
            _buildTextField(_passwordController, 'Password', obscureText: true),
            ElevatedButton(
              onPressed: _editingId == null ? _addUser : _updateUser,
              child: Text(_editingId == null ? 'Add User' : 'Update User'),
            ),
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: _service.getUsers(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(user.username),
                        subtitle: Text('${user.name} - ${user.department}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editUser(user),
                            ),
                            if (user.username != 'admin') // Kondisi untuk menghilangkan tombol delete
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteUser(user.id),
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
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      obscureText: obscureText,
    );
  }

  void _addUser() {
    if (_usernameController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackbar('All fields must be filled');
      return;
    }
    final user = UserModel(
      id: DateTime.now().toString(),
      username: _usernameController.text,
      name: _nameController.text,
      department: _departmentController.text,
      password: _passwordController.text,
    );
    _service.addUser(user);
    _clearForm();
  }

  void _updateUser() {
    if (_usernameController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackbar('All fields must be filled');
      return;
    }
    if (_editingId != null) {
      final user = UserModel(
        id: _editingId!,
        username: _usernameController.text,
        name: _nameController.text,
        department: _departmentController.text,
        password: _passwordController.text,
      );
      _service.updateUser(user);
      _clearForm();
    }
  }

  void _editUser(UserModel user) {
    setState(() {
      _editingId = user.id;
      _usernameController.text = user.username;
      _nameController.text = user.name;
      _departmentController.text = user.department;
      _passwordController.text = user.password;
    });
  }

  void _deleteUser(String id) {
    _service.deleteUser(id);
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _usernameController.clear();
      _nameController.clear();
      _departmentController.clear();
      _passwordController.clear();
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
