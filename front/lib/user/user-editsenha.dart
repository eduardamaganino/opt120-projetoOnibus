import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'user-login.dart';

class EditSenhaUserWidget extends StatefulWidget {
  final int userId;

  EditSenhaUserWidget({required this.userId});

  @override
  _EditSenhaUserWidgetState createState() => _EditSenhaUserWidgetState();
}

class _EditSenhaUserWidgetState extends State<EditSenhaUserWidget> {
  String senhaAntiga = '';
  String senhaNova1 = '';
  String senhaNova2 = '';
  bool isLoading = false;
  double textFieldWidth = 600.0; // Define a largura dos campos de texto

  // Variáveis para controlar a visibilidade das senhas
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;

  void _showMessage(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (title == 'Sucesso') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPassword() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.put(
      Uri.parse('http://localhost:3000/updateSenha/${widget.userId}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'senhaAntiga': senhaAntiga,
        'senhaNova1': senhaNova1,
        'senhaNova2': senhaNova2,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      _showMessage('Sucesso', 'Senha alterada com sucesso!');
    } else if (response.statusCode == 401) {
      _showMessage('Erro', 'Senha antiga está incorreta!');
    } else if (response.statusCode == 400) {
      _showMessage('Erro', 'As novas senhas não se coincidem!');
    } else {
      _showMessage('Erro', 'Falha ao alterar a senha');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alterar Senha',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                height: MediaQuery.of(context).size.height,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Icon(
                      Icons.lock,
                      size: 100.0,
                      color: Colors.black,
                    ),
                    const SizedBox(height: 15),
                    _buildPasswordField(
                        'Senha Antiga',
                        (value) {
                          setState(() {
                            senhaAntiga = value;
                          });
                        },
                        obscureText:
                            !_isOldPasswordVisible, // Controla a visibilidade
                        onVisibilityToggle: () {
                          setState(() {
                            _isOldPasswordVisible = !_isOldPasswordVisible;
                          });
                        },
                        isVisible: _isOldPasswordVisible),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                        'Senha Nova',
                        (value) {
                          setState(() {
                            senhaNova1 = value;
                          });
                        },
                        obscureText:
                            !_isNewPasswordVisible, // Controla a visibilidade
                        onVisibilityToggle: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                        isVisible: _isNewPasswordVisible),
                    const SizedBox(height: 8),
                    _buildPasswordField(
                        'Digite a Nova Senha Novamente',
                        (value) {
                          setState(() {
                            senhaNova2 = value;
                          });
                        },
                        obscureText:
                            !_isNewPasswordVisible, // Controla a visibilidade
                        onVisibilityToggle: () {
                          setState(() {
                            _isNewPasswordVisible = !_isNewPasswordVisible;
                          });
                        },
                        isVisible: _isNewPasswordVisible),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await _editPassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 5.0,
                        ),
                        child: const Text(
                          'Salvar Alterações',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPasswordField(String hintText, Function(String) onChanged,
      {required bool obscureText,
      required VoidCallback onVisibilityToggle,
      required bool isVisible}) {
    return SizedBox(
      width: textFieldWidth,
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
          suffixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: onVisibilityToggle,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}