import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateNotificationWidget extends StatefulWidget {
  final int idUser; // ID do usuário logado
  CreateNotificationWidget({required this.idUser});

  @override
  _CreateNotificationWidgetState createState() => _CreateNotificationWidgetState();
}

class _CreateNotificationWidgetState extends State<CreateNotificationWidget> {
  String texto = '';
  DateTime dataHora = DateTime.now();
  bool isRead = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Envio de avisos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
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
                Icons.notifications,
                size: 100.0,
                color: Colors.black,
              ),
              const SizedBox(height: 20),

              // Campo de Texto da Notificação
              Center(
                child: _buildTextField(
                  'Texto da Notificação',
                  (value) {
                    setState(() {
                      texto = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/createNotificacao'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'idUser': widget.idUser,
                      'texto': texto,
                      'dataHora': dataHora.toIso8601String(),
                      'isRead': isRead,
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
                            ? 'Notificação criada com sucesso!'
                            : 'Erro ao criar notificação.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (response.statusCode == 200) {
                                Navigator.pop(context);
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
                  'Notificar',
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.8, // Aumenta o tamanho do campo para 80% da largura da tela
      child: TextField(
        obscureText: obscureText,
        style: const TextStyle(color: Colors.black),
        maxLines: 5, // Define o campo de texto para ser maior
        decoration: InputDecoration(
          labelText: hintText,
          alignLabelWithHint: true, // Alinha o texto com o topo do campo
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20), // Caixas de texto com bordas arredondadas
            ),
          ),
          filled: true,
          fillColor: Colors.white, // Cor de fundo das caixas
        ),
        onChanged: onChanged,
      ),
    );
  }
}
