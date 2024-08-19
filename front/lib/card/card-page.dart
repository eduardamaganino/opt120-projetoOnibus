import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CardPageWidget extends StatefulWidget {
  final int idUser; // Id do usuário

  CardPageWidget({required this.idUser});

  @override
  _CardPageWidgetState createState() => _CardPageWidgetState();
}

class _CardPageWidgetState extends State<CardPageWidget> {
  Map<String, dynamic>? cardData;

  @override
  void initState() {
    super.initState();
    _fetchCardData(); // Buscar os dados do cartão ao iniciar
  }

  Future<void> _fetchCardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getByIdUserCartao/${widget.idUser}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          cardData = json.decode(response.body);
        });
      } else {
        print('Erro ao buscar dados do cartão: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar dados do cartão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: cardData == null
            ? CircularProgressIndicator()
            : Container(
                width: 350, // Largura fixa do cartão
                height: 200, // Altura fixa do cartão
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: CardPainter(),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Número: ${cardData!['id']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Valor: R\$ ${cardData!['valor']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tipo: ${cardData!['tipo']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Vencimento: ${cardData!['dataVencimento']}',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 15,
                      child: Icon(
                        Icons.directions_bus,
                        size: 40,
                        color: Colors.black,
                        // Removendo a sombra do ícone
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class CardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromARGB(231, 255, 226, 34)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(15)),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
