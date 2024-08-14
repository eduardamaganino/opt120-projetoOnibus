import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/user/user-create.dart';
import 'package:flutter_application_1/user/user-list.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(LoginPage());

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController senhaController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<void> fazerLogin() async {
    const String url = 'http://localhost:3000/login';
    final String email = emailController.text;
    final String senha = senhaController.text;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData['token'];
        final int userId = responseData['id'];

        print("Login bem-sucedido");
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setInt('userId', userId);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else if (response.statusCode == 401) {
        _showAlertDialog('Credenciais Inválidas',
            'Por favor, verifique suas credenciais e tente novamente.');
      } else {
        _showAlertDialog('Erro',
            'Ocorreu um erro ao tentar realizar o login. Tente novamente.');
      }
    } catch (e) {
      _showAlertDialog('Erro',
          'Não foi possível conectar-se ao servidor. Por favor, verifique sua conexão com a internet e tente novamente.');
      print(e);
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
          ' ',
          style: TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFD700),
        leading: const Icon(
          Icons.login,
          color: Color.fromARGB(138, 0, 0, 0),
        ),
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
                Icons.directions_bus,
                size: 100.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
              const SizedBox(height: 20),
              const Text(
                'Email',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Senha',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: senhaController,
                style: const TextStyle(color: Colors.black),
                obscureText: _obscureText,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                  contentPadding: EdgeInsets.all(12),
                  suffixIcon: GestureDetector(
                    onTap: _togglePasswordVisibility,
                    child: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: fazerLogin,
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: buttonWidth,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CreateUserWidget()),
                        );
                      },
                      child: const Text(
                        'Criar Conta',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700)),
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