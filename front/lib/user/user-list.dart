import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario.model.dart';
import 'package:flutter_application_1/user/user-create.dart';
import 'package:flutter_application_1/user/user-edit.dart';
import 'package:http/http.dart' as http;

class UserList extends StatefulWidget {
  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  List<dynamic> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/showUser'));

    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body);
        print(users);
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final nome = user['nome'].toString();
          final email = user['email'].toString();

          return ListTile(
            title: Text(nome),
            subtitle: Text(email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.pink,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditUserWidget(userId: user['id']),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.pink),
                  onPressed: () async {
                    final response = await http.delete(Uri.parse(
                        'http://localhost:3000/deleteUser/${user['id']}'));
                    if (response.statusCode == 200) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Success'),
                            content: Text('User deleted successfully'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Failed to delete user'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink.shade200,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateUserWidget()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.pink,
        ),
      ),
    );
  }
}
