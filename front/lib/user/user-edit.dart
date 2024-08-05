import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditUserWidget extends StatefulWidget {
  final int userId;

  EditUserWidget({required this.userId});

  @override
  _EditUserWidgetState createState() => _EditUserWidgetState();
}

class _EditUserWidgetState extends State<EditUserWidget> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _senhaController;

  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser(widget.userId);

    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _senhaController = TextEditingController();
  }

  Future<void> _fetchUser(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/showUserId/$userId'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _user = jsonData;
          _nomeController.text = _user!['nome'];
          _emailController.text = _user!['email'];
          _senhaController.text = _user!['senha'];
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        backgroundColor: Color(0xFFFFD700),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Centraliza os filhos
            children: [
              Text(
                'Edit User Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
                style: TextStyle(color: Colors.black), // Texto da caixa preto
                textAlign: TextAlign.center, // Texto centralizado
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
                style: TextStyle(color: Colors.black), // Texto da caixa preto
                textAlign: TextAlign.center, // Texto centralizado
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _senhaController,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(10),
                ),
                obscureText: true, // Oculta a senha enquanto o usuário digita
                style: TextStyle(color: Colors.black), // Texto da caixa preto
                textAlign: TextAlign.center, // Texto centralizado
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Color(0xFFFFD700), // Cor do botão
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  final nome = _nomeController.text;
                  final email = _emailController.text;
                  final senha = _senhaController.text;

                  final response = await http.put(
                    Uri.parse('http://localhost:3000/updateUser/${widget.userId}'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'nome': nome,
                      'email': email,
                      'senha': senha,
                    }),
                  );

                  if (response.statusCode == 200) {
                    print('User edited successfully');
                    // Aqui você pode adicionar uma mensagem de sucesso ou redirecionar o usuário
                  } else {
                    throw Exception('Failed to edit user');
                  }
                },
                child: const Text('Edit', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }
}
