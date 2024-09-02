import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SolicitacoesPage extends StatefulWidget {
  @override
  _SolicitacoesPageState createState() => _SolicitacoesPageState();
}

class _SolicitacoesPageState extends State<SolicitacoesPage> {
  List<dynamic> solicitacoes = []; // Lista para armazenar as solicitações pendentes

  @override
  void initState() {
    super.initState();
    _fetchSolicitacoesPendentes(); // Buscar solicitações ao iniciar
  }

  Future<void> _fetchSolicitacoesPendentes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/solicitacoesPendentes'),
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

  Future<void> _aprovarSolicitacao(int id, String status, [double? valor]) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/processarSolicitacao/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'status': status,
          'valor': valor ?? 0, // Adiciona o valor se fornecido, caso contrário, 0
        }),
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

  void _showValorDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double? valor;
        return AlertDialog(
          title: Text('Adicionar Saldo ao Cartão'),
          content: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: "Digite o valor"),
            onChanged: (text) {
              valor = double.tryParse(text);
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceitar'),
              onPressed: () {
                if (valor != null) {
                  _aprovarSolicitacao(id, 'aprovado', valor);
                  Navigator.of(context).pop();
                } else {
                  // Handle the case where valor is not provided
                  print('Valor inválido');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitações de Cartões'),
        backgroundColor: Color(0xFFFFD700), // Amarelo Ouro
      ),
      body: _buildSolicitacoesView(),
    );
  }

  Widget _buildSolicitacoesView() {
    if (solicitacoes.isEmpty) {
      return Center(child: Text('Nenhuma solicitação pendente.'));
    }
    return ListView.builder(
      itemCount: solicitacoes.length,
      itemBuilder: (context, index) {
        final solicitacao = solicitacoes[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: ListTile(
            title: Text('Solicitação ID: ${solicitacao['id']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Usuário ID: ${solicitacao['idUser']}'),
                Text('Valor: R\$ ${solicitacao['valor']}'), // Exibe o valor
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () => _showValorDialog(solicitacao['id']),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () => _aprovarSolicitacao(solicitacao['id'], 'rejeitado'),
                ),
                IconButton(
                  icon: Icon(Icons.file_download, color: Colors.blue),
                  onPressed: () {
                    // Lógica para download do PDF
                    final pdfPath = solicitacao['pdfPath'];
                    // Você precisará de um plugin como url_launcher para abrir ou baixar o PDF
                    print('Baixar PDF: $pdfPath');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
