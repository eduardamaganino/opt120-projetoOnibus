import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CreateCardWidget extends StatefulWidget {
  final int idUser;
  CreateCardWidget({required this.idUser});

  @override
  _CreateCardWidgetState createState() => _CreateCardWidgetState();
}

class _CreateCardWidgetState extends State<CreateCardWidget> {
  String tipo = 'Normal';
  PlatformFile? _selectedFile;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  
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
              if (tipo == 'Estudante')
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Enviar Carteirinha de Estudante \nEnviar arquivo com Foto (RG ou CNH) .pdf',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (tipo == 'Normal' || tipo == 'Idoso')
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Enviar arquivo .pdf com Documento com Foto (RN ou CNH)',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              _buildFilePicker(),
              ElevatedButton(
                onPressed: () async {
                  if (_selectedFile != null) {
                    bool wantsToAddBalance = await _showAddBalanceDialog();
                    if (wantsToAddBalance) {
                      double? amount = await _showSaldoDialog();
                      if (amount != null) {
                        _sendRequest(amount);
                      }
                    } else {
                      _sendRequest(0.0);
                    }
                  } else {
                    _showDialog('Aviso', 'Por favor, selecione um arquivo PDF.');
                  }
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
        _buildCheckboxOption('Normal'),
        _buildCheckboxOption('Estudante'),
        _buildCheckboxOption('Idoso'),
      ],
    );
  }

  Widget _buildCheckboxOption(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 20, color: Colors.black),
      ),
      leading: Radio<String>(
        value: title,
        groupValue: tipo,
        activeColor: Colors.black,
        onChanged: (String? selectedValue) {
          setState(() {
            tipo = selectedValue!;
          });
        },
      ),
    );
  }

  Widget _buildFilePicker() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _selectFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          child: Text(
            _selectedFile != null ? _selectedFile!.name : 'Selecionar PDF',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        if (_selectedFile != null)
          Text('Arquivo selecionado: ${_selectedFile!.name}'),
      ],
    );
  }

  Future<void> _selectFile() async {
    if (html.window.document != null) {
      final input = html.FileUploadInputElement()..accept = 'application/pdf';
      input.click();
      input.onChange.listen((e) {
        final files = input.files;
        if (files == null || files.isEmpty) return;

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]!);
        reader.onLoadEnd.listen((e) {
          setState(() {
            _selectedFile = PlatformFile(
              name: files[0].name,
              size: files[0].size,
              bytes: reader.result as Uint8List,
            );
          });
        });
      });
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    }
  }

  Future<bool> _showAddBalanceDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Saldo'),
          content: const Text('Deseja adicionar saldo ao cartão?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<double?> _showSaldoDialog() async {
    return showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Valor do Saldo'),
          content: TextField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: "Digite o valor a ser adicionado"),
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('Enviar'),
              onPressed: () {
                double? valor = double.tryParse(_amountController.text);
                if (valor != null) {
                  Navigator.of(context).pop(valor);
                } else {
                  _showDialog('Erro', 'Por favor, insira um valor válido.');
                }
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _showQRCodeDialog(double valor) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('QR Code para Adicionar Saldo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/QRCode.png',
              height: 200,
              width: 200,
            ),
            const SizedBox(height: 10),
            const Text('Este QR Code será válido por 1 minuto.'),
            const SizedBox(height: 10),
            Text('Valor: R\$ ${valor.toStringAsFixed(2)}'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  Future<void> _sendRequest(double valor) async {
  final uri = Uri.parse('http://localhost:3000/solicitarCartao/${widget.idUser}');
  final request = http.MultipartRequest('POST', uri)
    ..fields['tipo'] = tipo
    ..fields['valor'] = valor.toString()
    ..files.add(
      http.MultipartFile.fromBytes(
        'file',
        _selectedFile!.bytes!,
        filename: _selectedFile!.name,
      ),
    );

  try {
    final response = await request.send();
    if (response.statusCode == 201) {
      await _showQRCodeDialog(valor);

      _showDialog('Solicitação Aceita', 'Aguarde pela revisão de seus documentos.');
      Future.delayed(Duration(seconds: 4), () {
        Navigator.pop(context);
      });
    } else {
      _showDialog('Erro', 'Erro ao enviar arquivo. Status code: ${response.statusCode}');
    }
  } catch (e) {
    _showDialog('Erro', 'Erro ao enviar arquivo: $e');
  }
}

  void _showDialog(String title, String message) {
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
}