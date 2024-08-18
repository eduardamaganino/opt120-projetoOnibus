import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/card/card-page.dart';
import 'package:flutter_application_1/user/user-page.dart'; // Página de Usuário
import 'package:flutter_application_1/user/userHome-page.dart'; // Página Home
import 'package:flutter_application_1/user/user-login.dart'; // Página de Login
import 'package:flutter_application_1/user/user-create.dart'; // Página de Criação de Usuário
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Color(0xFFFFD700)), // Amarelo Ouro
          bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFFFFD700)), // Amarelo Ouro
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFFFFC107), // Amarelo Mostarda
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: LoginPage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    UserPageWidget(), // Página do Usuário
    UserHomePageWidget(userId: 1), // Forneça o userId aqui
    CardPageWidget()  // Página de Cartão
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Página de Usuário' : _selectedIndex == 1 ? 'Página Inicial' : 'Cartão',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFFFD700), // Amarelo Ouro
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Color(0xFFFFFACD), // Amarelo Claro
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Usuário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Cartão',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFFC107), // Amarelo Mostarda
        unselectedItemColor: Color(0xFFFFD700), // Amarelo Ouro
        onTap: _onItemTapped,
        backgroundColor: Color(0xFFFFFACD), // Amarelo Claro
      ),
    );
  }
}