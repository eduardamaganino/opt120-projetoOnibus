import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/user/user-edit.dart';
import 'package:flutter_application_1/user/user-editsenha.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/card/card-create.dart';
import 'package:flutter_application_1/notify/notify-create.dart';

class UserPageWidget extends StatefulWidget {
  @override
  _UserPageWidgetState createState() => _UserPageWidgetState();
}

class _UserPageWidgetState extends State<UserPageWidget> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _getUserIDFromLocalStorage();
  }

  Future<void> _getUserIDFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      await _fetchUser(userId);
    } else {
      print('ID do usuário não encontrado!');
    }
  }

  Future<void> _fetchUser(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/showUserId/${userId}'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        setState(() {
          _user = jsonData;
        });
      } else {
        throw Exception('Falha ao buscar usuário!');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ícone de ônibus com opacidade
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Opacity(
                opacity: 0.3, // Ajuste a opacidade conforme necessário
                child: Icon(
                  Icons.directions_bus,
                  size: MediaQuery.of(context).size.width *
                      0.47, // Tamanho do ícone
                  color: Colors.grey, // Cor do ícone
                ),
              ),
            ),
          ),
          // Conteúdo da página
          Center(
            child: _user != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Nome: ${_user!['nome']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: ${_user!['email']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),
                      _buildStyledButton(
                        label: 'Editar Usuário',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditUserWidget(
                                userId: _user!['id'],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                      _buildStyledButton(
                        label: 'Editar Senha',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditSenhaUserWidget(
                                userId: _user!['id'],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      if (_user!['is_adm'] ==
                          1) // Exibe o botão apenas para administradores
                        _buildStyledButton(
                          label: 'Enviar Aviso',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateNotificationWidget(
                                  idUser: _user!['id'],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton(
      {required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFD700), // Cor do fundo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), // Borda arredondada
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shadowColor: Color(0xFFD7B600), // Cor da sombra
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.black, fontSize: 18),
      ),
    );
  }
}
