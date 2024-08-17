import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario.model.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Usuário',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0), // Ajuste o padding conforme necessário
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
              // Nome
              _buildTextField('Nome', (value) {
                setState(() {
                  nome = value;
                });
              }),
              const SizedBox(height: 10),
              // CPF
              _buildTextField('Cpf', (value) {
                setState(() {
                  cpf = value;
                });
              }),
              const SizedBox(height: 10),
              // Email
              _buildTextField('Email', (value) {
                setState(() {
                  email = value;
                });
              }),
              const SizedBox(height: 10),
              // Senha
              _buildTextField('Senha', (value) {
                setState(() {
                  senha = value;
                });
              }, obscureText: true),
              const SizedBox(height: 10),
              // Telefone
              _buildTextField('Telefone', (value) {
                setState(() {
                  telefone = value;
                });
              }),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final user = User(nome, cpf, email, senha, telefone, false);

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

                  // Dialog de sucesso ou erro
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
                                // Direciona para a página de login se a criação do usuário for bem-sucedida
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          LoginPage()), // Substitua por sua tela de login
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
      {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(100)), // Caixas de texto arredondadas
        ),
        filled: true,
        fillColor: Colors.white, // Cor de fundo das caixas
      ),
      onChanged: onChanged,
    );
  }
}
