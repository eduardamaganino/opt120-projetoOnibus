import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Tipos de cartão:
// 1 = Normal
// 2 = Estudante
// 3 = Trabalho
class CreateCardWidget extends StatefulWidget {
  final int idUser; // ID do usuário logado
  CreateCardWidget({required this.idUser});

  @override
  _CreateCardWidgetState createState() => _CreateCardWidgetState();
}

class _CreateCardWidgetState extends State<CreateCardWidget> {
  DateTime dataCriacao = DateTime.now();
  DateTime dataVencimento = DateTime.now().add(Duration(days: 365));
  int tipo = 1; // Tipo por padrão será "Normal"
  double valor = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cadastro de Cartão',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: const Color(0xFFFFD700),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFD700),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.credit_card,
                size: 100.0,
                color: Colors.black,
              ),
              _buildCheckboxField(),
              ElevatedButton(
                onPressed: () async {
                  final response = await http.post(
                    Uri.parse('http://localhost:3000/createCartao'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'idUser': widget.idUser,
                      'dataCriacao': dataCriacao.toIso8601String(),
                      'dataVencimento': dataVencimento.toIso8601String(),
                      'valor': valor,
                      'tipo': tipo,
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
                            ? 'Cartão criado com sucesso!'
                            : 'Erro ao criar cartão.'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'Solicitar cartão',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildCheckboxOption('Normal', 1),
        _buildCheckboxOption('Estudante', 2),
        _buildCheckboxOption('Trabalho', 3),
      ],
    );
  }

  Widget _buildCheckboxOption(String title, int value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      leading: Radio<int>(
        value: value,
        groupValue: tipo,
        activeColor: Colors.black,
        onChanged: (int? selectedValue) {
          setState(() {
            tipo = selectedValue!;
          });
        },
      ),
    );
  }
}
