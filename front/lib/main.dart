import 'package:flutter/material.dart';
import 'package:flutter_application_1/card/card-page.dart';
import 'package:flutter_application_1/user/user-page.dart'; // Página de Usuário
import 'package:flutter_application_1/user/userHome-page.dart'; // Página Home
import 'package:flutter_application_1/user/user-login.dart'; // Página de Login
import 'package:flutter_application_1/user/user-create.dart'; // Página de Criação de Usuário
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        textTheme: TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFD700)), // Amarelo Ouro
          bodyLarge: TextStyle(
              fontSize: 16.0, color: Color(0xFFFFD700)), // Amarelo Ouro
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
  int? _userId; // Adicionado para armazenar o userId

  @override
  void initState() {
    super.initState();
    _getUserIDFromLocalStorage(); // Recupera o userId ao iniciar
  }

  Future<void> _getUserIDFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');

    if (userId != null) {
      setState(() {
        _userId = userId; // Armazena o userId no estado
      });
    } else {
      print('User ID not found in Local Storage');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Atualiza _widgetOptions para usar _userId
    final List<Widget> _widgetOptions = <Widget>[
      UserPageWidget(), // Página do Usuário
      UserHomePageWidget(
          userId: _userId ?? 0), // Passa o userId para UserHomePageWidget
      CardPageWidget(idUser: _userId ?? 0) // Passa o userId para CardPageWidget
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Página de Usuário'
              : _selectedIndex == 1
                  ? 'Página Inicial'
                  : 'Cartão',
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
