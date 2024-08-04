import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/usuario.model.dart';
import 'package:http/http.dart' as http;

class CreateUserWidget extends StatefulWidget {
  String? get userId => null;

  @override
  _CreateUserWidgetState createState() => _CreateUserWidgetState();
}

class _CreateUserWidgetState extends State<CreateUserWidget> {
  String nome = '';
  String email = '';
  String senha = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de usuario'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nome',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 40,
                  child: TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                      ),
                      contentPadding: EdgeInsets.all(10),
                    ),
                    onChanged: (value) {
                      setState(() {
                        nome = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              'Senha',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 40,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged: (value) {
                  setState(() {
                    senha = value;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(double.infinity, 40),
                alignment: Alignment.center,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                backgroundColor: Colors.pink.shade400,
              ),
              onPressed: () async {
                final user = User(nome, email, senha, "telefone", false);

                final response = await http.post(
                  Uri.parse('http://localhost:3000/newUser'),
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Parabens!'),
                        content: Text('Usuario criada com sucesso'),
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
                        content: Text('Erro ao criar tarefa'),
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
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }
}
