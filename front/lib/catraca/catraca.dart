import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CatracaWidget extends StatefulWidget {
  @override
  _CatracaWidgetState createState() => _CatracaWidgetState();
}

class _CatracaWidgetState extends State<CatracaWidget> {
  final TextEditingController _amountController = TextEditingController();
  final double textFieldWidth = 600.0; // Define a largura dos campos de texto
  double? _currentBalance;

  @override
  void initState() {
    super.initState();
    // Não inicialize a busca de saldo no initState, pois o saldo depende do ID inserido
  }

  Future<void> _fetchCurrentBalance() async {
    final String idUser = _amountController.text;

    if (idUser.isEmpty) {
      return; // Não faz nada se o ID estiver vazio
    }

    final String url = 'http://localhost:3000/saldo/$idUser'; // URL ajustada

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _currentBalance = data['saldo']; // Ajuste conforme o retorno da API
        });
      } else {
        print('Erro ao buscar saldo: ${response.statusCode}');
        _showAlertDialog('Erro', 'Erro ao buscar saldo.');
      }
    } catch (e) {
      print('Erro ao conectar-se ao servidor: $e');
      _showAlertDialog('Erro', 'Erro ao conectar-se ao servidor.');
    }
  }

  Future<void> _debitar() async {
    final String idUser = _amountController.text;

    if (idUser.isEmpty) {
      _showAlertDialog('Erro', 'Por favor, insira um ID válido.');
      return;
    }

    if (_currentBalance == null) {
      _showAlertDialog('Erro', 'Não foi possível obter o saldo.');
      return;
    }

    double amountToDebit = double.tryParse(idUser) ?? 0.0;

    if (_currentBalance! < amountToDebit) {
      _showAlertDialog('Saldo Insuficiente', 'Você não tem saldo suficiente.');
      return;
    }

    final String url = 'http://localhost:3000/debitar/$idUser';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        _showAlertDialog('Sucesso', 'Débito realizado com sucesso!');
      } else {
        _showAlertDialog('Erro', 'Não foi possível realizar o débito.');
      }
    } catch (e) {
      _showAlertDialog('Erro', 'Erro ao conectar-se ao servidor.');
      print(e);
    } finally {
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
    double buttonWidth = 150.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catraca',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
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
                Icons.attach_money,
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
              SizedBox(
                width: textFieldWidth,
                child: TextField(
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
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        _fetchCurrentBalance();
                      },
                      child: const Text(
                        'Consultar Saldo',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
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
              if (_currentBalance != null) 
                Text(
                  'Saldo atual: R\$${_currentBalance!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
