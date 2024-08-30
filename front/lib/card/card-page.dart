import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/card/SolicitacoesPage.dart';

class CardPageWidget extends StatefulWidget {
  final int idUser;
  final bool isAdm;

  CardPageWidget({required this.idUser, required this.isAdm});

  @override
  _CardPageWidgetState createState() => _CardPageWidgetState();
}

class _CardPageWidgetState extends State<CardPageWidget> {
  Map<String, dynamic>? cardData;
  List<dynamic> solicitacoes = [];
  final TextEditingController _valorController = TextEditingController(); // Controller para capturar o valor inserido

  @override
  void initState() {
    super.initState();
    if (widget.isAdm) {
      // Não buscar solicitações aqui, apenas exibir o botão
    } else {
      _fetchCardData();
    }
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

  void _showSaldoInputDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Saldo'),
          content: TextField(
            controller: _valorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Digite o valor a ser adicionado',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showQRCodeDialog(); // Mostrar o QR Code depois de inserir o valor
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  void _showQRCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('QR Code para Adicionar Saldo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Placeholder(fallbackHeight: 200, fallbackWidth: 200),
              SizedBox(height: 10),
              Text('Este QR Code será válido por 1 minuto.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                double valor = double.tryParse(_valorController.text) ?? 0.0;
                _adicionarSaldo(valor);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    Future.delayed(Duration(minutes: 1), () {
      Navigator.of(context).pop();
    });
  }

  Future<void> _adicionarSaldo(double valor) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/adicionarSaldo/${widget.idUser}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, double>{'valorAdicionado': valor}),
      );

      if (response.statusCode == 200) {
        print('Saldo adicionado com sucesso.');
        _fetchCardData();
      } else {
        print('Erro ao adicionar saldo: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
      }
    } catch (e) {
      print('Erro ao adicionar saldo: $e');
    }
  }

  Future<void> _fetchSolicitacoesPendentes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/getSolicitacoesPendentes'),
      );

      if (response.statusCode == 200) {
        setState(() {
          solicitacoes = json.decode(response.body);
        });
      } else {
        print('Erro ao buscar solicitações: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
      }
    } catch (e) {
      print('Erro ao buscar solicitações: $e');
    }
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAdm) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Gerenciar Solicitações'),
          backgroundColor: Color(0xFFFFD700),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SolicitacoesPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
            ),
            child: Text(
              'Gerenciar Solicitações',
              style: TextStyle(color: Colors.black, fontSize: 18),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalhes do Cartão'),
          backgroundColor: Color(0xFFFFD700),
        ),
        body: _buildCardView(),
      );
    }
  }

  Widget _buildCardView() {
    if (cardData == null) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 350,
          height: 200,
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
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showSaldoInputDialog, // Chama a função para mostrar o diálogo de input
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFD700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          ),
          child: Text(
            'Adicionar Saldo',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ],
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
