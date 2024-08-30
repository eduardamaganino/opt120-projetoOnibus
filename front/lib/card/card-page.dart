import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_application_1/card/SolicitacoesPage.dart';

class CardPageWidget extends StatefulWidget {
  final int idUser;
  final bool isAdm; // Novo parâmetro para identificar se é administrador

  CardPageWidget({required this.idUser, required this.isAdm});

  @override
  _CardPageWidgetState createState() => _CardPageWidgetState();
}

class _CardPageWidgetState extends State<CardPageWidget> {
  Map<String, dynamic>? cardData;
  List<dynamic> solicitacoes = []; // Lista para armazenar as solicitações pendentes

  @override
  void initState() {
    super.initState();
    if (widget.isAdm) {
      // Não buscar solicitações aqui, apenas exibir o botão
    } else {
      _fetchCardData(); // Buscar dados do cartão se não for administrador
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

  Future<void> _aprovarSolicitacao(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/processarSolicitacao/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{'status': status}),
      );

      if (response.statusCode == 200) {
        _fetchSolicitacoesPendentes(); // Atualizar lista após aprovação/rejeição
        print('Solicitação $status com sucesso.');
      } else {
        print('Erro ao processar solicitação: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
      }
    } catch (e) {
      print('Erro ao processar solicitação: $e');
    }
  }

  String _formatDate(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAdm) {
      // Se for administrador, exiba apenas o botão de gerenciar solicitações
      return Scaffold(
        appBar: AppBar(
          title: Text('Gerenciar Solicitações'),
          backgroundColor: Color(0xFFFFD700),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Ação do botão para gerenciar solicitações
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SolicitacoesPage(), // Substitua por sua tela de gerenciamento
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
      // Se não for administrador, exiba os detalhes do cartão
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
    return Container(
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
