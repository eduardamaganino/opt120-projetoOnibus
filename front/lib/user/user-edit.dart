import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user-login.dart';

class EditUserWidget extends StatefulWidget {
  final int userId;

  EditUserWidget({required this.userId});

  @override
  _EditUserWidgetState createState() => _EditUserWidgetState();
}

class _EditUserWidgetState extends State<EditUserWidget> {
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/showUserId/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Garantir que não haja valores nulos
          nomeController.text = data['nome'] ?? '';
          emailController.text = data['email'] ?? '';
          telefoneController.text = data['telefone'] ?? '';
          isLoading = false;
        });
      } else {
        print('Falha ao carregar detalhes do usuário');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Erro ao buscar detalhes do usuário: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Sucesso') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Usuário',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFD700),
                      Color.fromARGB(255, 241, 235, 209),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Icon(
                      Icons.edit_note,
                      size: 100.0,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 15),
                    _buildTextField('Nome', nomeController),
                    const SizedBox(height: 8),
                    _buildTextField('Email', emailController),
                    const SizedBox(height: 8),
                    _buildTextField('Telefone', telefoneController),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity, // Makes the button full-width
                      child: ElevatedButton(
                        onPressed: () async {
                          final response = await http.put(
                            Uri.parse(
                                'http://localhost:3000/updateUser/${widget.userId}'),
                            headers: <String, String>{
                              'Content-Type': 'application/json; charset=UTF-8',
                            },
                            body: jsonEncode(<String, String>{
                              'nome': nomeController.text,
                              'email': emailController.text,
                              'telefone': telefoneController.text,
                            }),
                          );

                          if (response.statusCode == 200) {
                            _showMessage(
                                'Sucesso', 'Usuário editado com sucesso!');
                          } else {
                            _showMessage('Erro', 'Falha ao editar usuário');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 5.0,
                        ),
                        child: const Text(
                          'Editar',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        filled: true,
        fillColor: Colors.transparent,
      ),
    );
  }
}
