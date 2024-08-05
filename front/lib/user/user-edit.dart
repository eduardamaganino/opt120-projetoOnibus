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
  String nome = '';
  String email = '';
  String senha = ''; // Inicializando a senha como string vazia
  String telefone = '';
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
          nome = data['nome'];
          email = data['email'];
          telefone = data['telefone'];
          isLoading = false;
        });
      } else {
        // Tratar erro de resposta
        print('Failed to load user details');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      // Tratar erro de conexão
      print('Error fetching user details: $error');
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              padding: const EdgeInsets.all(120.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFD700),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.edit_note,
                      size: 100.0,
                      color: Colors.black,
                    ),
                    const Text(
                      'Editar Usuário\n',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                      controller: TextEditingController(text: nome),
                      onChanged: (value) {
                        setState(() {
                          nome = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                      controller: TextEditingController(text: email),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                      obscureText: true,
                      controller: TextEditingController(text: senha),
                      onChanged: (value) {
                        setState(() {
                          senha = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(color: Colors.black),
                      controller: TextEditingController(text: telefone),
                      onChanged: (value) {
                        setState(() {
                          telefone = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        print(
                            'Nome: $nome, Email: $email, Senha: $senha, Telefone: $telefone');

                        final response = await http.put(
                          Uri.parse(
                              'http://localhost:3000/updateUser/${widget.userId}'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(<String, String>{
                            'nome': nome,
                            'email': email,
                            'senha': senha,
                            'telefone': telefone,
                          }),
                        );

                        print('Response status: ${response.statusCode}');
                        print('Response body: ${response.body}');

                        if (response.statusCode == 200) {
                          _showMessage(
                              'Sucesso', 'Usuário editado com sucesso!');
                        } else {
                          _showMessage('Erro', 'Falha ao editar usuário');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFD700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: Text(
                        'Editar',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
