import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CreateCardWidget extends StatefulWidget {
  final int idUser; // ID do usuário logado
  CreateCardWidget({required this.idUser});

  @override
  _CreateCardWidgetState createState() => _CreateCardWidgetState();
}

class _CreateCardWidgetState extends State<CreateCardWidget> {
  int tipo = 1; // Tipo por padrão será "Normal"
  PlatformFile? _selectedFile;

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
              if (tipo == 2) // Mostrar instrução apenas se o tipo for Estudante
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    'Enviar Carteirinha de Estudante \nEnviar arquivo com Foto (RG ou CNH) .pdf',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (tipo == 1 || tipo == 3) // Mostrar instrução para Normal e Idoso
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
                    bool success = await _uploadFile(_selectedFile!);
                    if (success) {
                      _showDialog('Solicitação Aceita', 'Aguarde pela revisão de seus documentos.');
                      Future.delayed(Duration(seconds: 4), () {
                        Navigator.pop(context);
                      });
                    } else {
                      _showDialog('Erro', 'Erro ao enviar arquivo.');
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
        _buildCheckboxOption('Normal', 1),
        _buildCheckboxOption('Estudante', 2),
        _buildCheckboxOption('Idoso', 3),
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
              name: files[0]!.name,
              size: files[0]!.size,
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

  Future<bool> _uploadFile(PlatformFile file) async {
    final uri = Uri.parse('http://localhost:3000/uploadPdf');
    final request = http.MultipartRequest('POST', uri)
      ..fields['idUser'] = widget.idUser.toString()
      ..fields['tipo'] = tipo.toString()
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
        ),
      );

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro ao enviar arquivo: $e');
      return false;
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
