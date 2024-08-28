import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/card/card-create.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CardPageWidget extends StatefulWidget {
  final int idUser;

  CardPageWidget({required this.idUser});

  @override
  _CardPageWidgetState createState() => _CardPageWidgetState();
}

class _CardPageWidgetState extends State<CardPageWidget> {
  Map<String, dynamic>? cardData;

  @override
  void initState() {
    super.initState();
    _fetchCardData();
  }

  Future<void> _fetchCardData() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getByIdUserCartao/${widget.idUser}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cardData = data.isNotEmpty ? data : null;
        });
      } else {
        print('Erro ao buscar dados do cartão: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar dados do cartão: $e');
    }
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: cardData == null
            ? ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateCardWidget(
                        idUser: widget.idUser,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Solicitar Cartão',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  //backgroundColor: Color.fromARGB(0, 255, 255, 255),
                  shadowColor: Color.fromARGB(255, 237, 227, 137),
                ),
              )
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
                      child: Container(
                        width: 350,
                        height: 200,
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
                              'Vencimento: ${_formatDate(cardData!['dataVencimento'])}',
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
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: Colors.black26,
                            offset: Offset(2, 2),
                          ),
                        ],
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
