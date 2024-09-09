import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CatracaWidget extends StatefulWidget {
  @override
  _CatracaWidgetState createState() => _CatracaWidgetState();
}

class _CatracaWidgetState extends State<CatracaWidget> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _debitar() async {
    final String id = _amountController.text;

    // Verifica se o campo está vazio
    if (id.isEmpty) {
      _showAlertDialog('Erro', 'Por favor, insira um ID válido.');
      return;
    }

    final String url = 'http://localhost:3000/debitar/$id';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // A operação de débito foi bem-sucedida
        _showAlertDialog('Sucesso', 'Débito realizado com sucesso!');
      } else {
        // Ocorreu um erro ao realizar o débito
        _showAlertDialog('Erro', 'Não foi possível realizar o débito.');
      }
    } catch (e) {
      _showAlertDialog('Erro', 'Erro ao conectar-se ao servidor.');
      print(e);
    } finally {
      // Limpa o campo após a tentativa de débito
      _amountController.clear();
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double buttonWidth = 150.0; // Para manter o mesmo tamanho dos botões
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catraca',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD700), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.attach_money, // Ícone para representar o débito
                size: 100.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
              const SizedBox(height: 20),
              const Text(
                'Insira o cartão para ser passado',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  hintText: 'Ex: 1',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: _debitar,
                      child: const Text(
                        'Debitar',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
