import 'package:flutter/material.dart';


class CardPageWidget extends StatefulWidget {
  @override
  _CardPageWidgetState createState() => _CardPageWidgetState();
}

class _CardPageWidgetState extends State<CardPageWidget> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Page'),
        backgroundColor: const Color(0xFFFFD700),
      ),
      body: Center(
        child: Image.asset(
          '../assets/passe.jpg', // Substitua pelo caminho da sua imagem
          width: 300,
          height: 200,
        ),
      ),
    );
    
  }
}



