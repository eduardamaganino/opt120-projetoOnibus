import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user-login.dart';

class CreateUserWidget extends StatefulWidget {
  @override
  _CreateUserWidgetState createState() => _CreateUserWidgetState();
}

class _CreateUserWidgetState extends State<CreateUserWidget> {
  String nome = '';
  String cpf = '';
  String email = '';
  String senha = '';
  String telefone = '';

  @override
  Widget build(BuildContext context) {
    double textFieldWidth = 600.0; // Define a largura dos campos de texto

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Usuário',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20.0),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.person_add_alt_1,
                size: 100.0,
                color: Colors.black,
              ),
              const SizedBox(height: 20),
              _buildTextField('Nome', (value) {
                setState(() {
                  nome = value;
                });
              }, textFieldWidth: textFieldWidth),
              const SizedBox(height: 10),
              _buildTextField('CPF', (value) {
                setState(() {
                  cpf = value;
                });
              }, textFieldWidth: textFieldWidth),
              const SizedBox(height: 10),
              _buildTextField('Email', (value) {
                setState(() {
                  email = value;
                });
              }, textFieldWidth: textFieldWidth),
              const SizedBox(height: 10),
              _buildTextField('Senha', (value) {
                setState(() {
                  senha = value;
                });
              }, obscureText: true, textFieldWidth: textFieldWidth),
              const SizedBox(height: 10),
              _buildTextField('Telefone', (value) {
                setState(() {
                  telefone = value;
                });
              }, textFieldWidth: textFieldWidth),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/newUser'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'nome': nome,
                      'cpf': cpf,
                      'email': email,
                      'senha': senha,
                      'telefone': telefone,
                    }),
                  );

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                            response.statusCode == 200 ? 'Parabéns!' : 'Erro'),
                        content: Text(response.statusCode == 200
                            ? 'Usuário criado com sucesso!'
                            : 'Erro ao criar usuário.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (response.statusCode == 200) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()),
                                  (route) => false,
                                );
                              }
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 5.0,
                ),
                child: const Text(
                  'Cadastrar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, Function(String) onChanged,
      {bool obscureText = false, double textFieldWidth = 300.0}) {
    return SizedBox(
      width: textFieldWidth, // Ajusta a largura do campo de texto
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: hintText,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(100),
            ),
          ),
          filled: true,
          fillColor: Colors.transparent,
          hintStyle: const TextStyle(color: Colors.black45),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
