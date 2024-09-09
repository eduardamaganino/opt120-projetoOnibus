import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SolicitacoesPagamentoPage extends StatefulWidget {
  @override
  _SolicitacoesPagamentoPageState createState() => _SolicitacoesPagamentoPageState();
}

class _SolicitacoesPagamentoPageState extends State<SolicitacoesPagamentoPage> {
  List<dynamic> solicitacoes = []; // Lista para armazenar as solicitações pendentes

  @override
  void initState() {
    super.initState();
    _fetchSolicitacoesPendentes(); // Buscar solicitações ao iniciar
  }

  Future<void> _fetchSolicitacoesPendentes() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/solicitacoesSaldoPendentes'),
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

  Future<void> _processarSolicitacao(int id, String status) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/processarSolicitacaoSaldo/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        _fetchSolicitacoesPendentes();
      } else {
        print('Erro ao processar solicitação: ${response.statusCode}');
        print('Resposta do servidor: ${response.body}');
      }
    } catch (e) {
      print('Erro ao processar solicitação: $e');
    }
  }

  Widget _buildSolicitacaoItem(Map<String, dynamic> solicitacao) {
    return ListTile(
      title: Text('Solicitação de Saldo'),
      subtitle: Text('Usuário: ${solicitacao['idUser']}, Valor: R\$ ${solicitacao['valor']}, Criada em: ${solicitacao['createdAt']}'),
      trailing: ElevatedButton(
        onPressed: () {
          // Processar a solicitação (aprovar ou rejeitar)
          _processarSolicitacao(solicitacao['id'], 'aprovado');
        },
        child: Text('Processar'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciar Solicitações de Pagamento'),
        backgroundColor: Color(0xFFFFD700), // Amarelo Ouro
      ),
      body: _buildSolicitacoesView(),
    );
  }

  Widget _buildSolicitacoesView() {
    if (solicitacoes.isEmpty) {
      return Center(child: Text('Nenhuma solicitação de pagamento pendente.'));
    }
    return ListView.builder(
      itemCount: solicitacoes.length,
      itemBuilder: (context, index) {
        final solicitacao = solicitacoes[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: _buildSolicitacaoItem(solicitacao),
        );
      },
    );
  }
}
