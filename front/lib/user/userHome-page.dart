import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notification_model.dart' as model;
import 'package:http/http.dart' as http;

class UserHomePageWidget extends StatefulWidget {
  final int userId;
  final bool isAdm;

  UserHomePageWidget({required this.userId, required this.isAdm});

  @override
  _UserHomePageWidgetState createState() => _UserHomePageWidgetState();
}

class _UserHomePageWidgetState extends State<UserHomePageWidget> {
  @override
  void initState() {
    super.initState();
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(userId: widget.userId, isAdm: widget.isAdm),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Opacity(
                opacity: 0.3,
                child: Icon(
                  Icons.directions_bus,
                  size: MediaQuery.of(context).size.width * 0.47,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Text(
                  'Bem-vindo ao CARDBUSS',
                  style: TextStyle(
                    fontSize: 37,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'Aplicativo para melhorar a sua experiência no serviço de transporte público',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 80),
                ElevatedButton(
                  onPressed: _openNotifications,
                  child: Text('Abrir Notificações'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  final int userId;
  final bool isAdm;

  NotificationsPage({required this.userId, required this.isAdm});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<model.Notification>> _notificationsFuture;
  List<model.Notification>? _notifications;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = _fetchNotifications(widget.userId);
  }

  Future<List<model.Notification>> _fetchNotifications(int userId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/getNotificacaoByUserId/$userId'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as List<dynamic>;
        _notifications = jsonData.map((item) => model.Notification.fromJson(item)).toList();

        // Ordena as notificações para que as não lidas venham antes das lidas
        _notifications!.sort((a, b) {
          return a.isRead == b.isRead ? 0 : (a.isRead ? 1 : -1);
        });

        return _notifications!;
      } else {
        // Se não há notificações, retorna uma lista vazia
        return [];
      }
    } catch (e) {
      print(e);
      throw Exception('Falha ao carregar notificações');
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/notificacoes/status/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'notificationId': notificationId, 'isRead': 1}),
      );

      if (response.statusCode == 200) {
        setState(() {
          final notification = _notifications!.firstWhere((n) => n.id == notificationId);
          notification.isRead = true;

          _notifications!.sort((a, b) {
            return a.isRead == b.isRead ? 0 : (a.isRead ? 1 : -1);
          });
        });
      } else {
        throw Exception('Falha ao atualizar o status da notificação');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3000/deleteNotificacao/$notificationId'),
      );
      if (response.statusCode == 200) {
        setState(() {
          _notifications!.removeWhere((notification) => notification.id == notificationId);
        });
      } else {
        throw Exception('Falha ao excluir notificação');
      }
    } catch (e) {
      print('Exceção ao excluir notificação: $e');
      throw e;
    }
  }

  Future<void> _updateDebitValue(double newValue) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/atualizarValorDebito'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'novoValor': newValue}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Valor de débito atualizado com sucesso')));
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorData['error'])));
      }
    } catch (e) {
      print('Erro ao atualizar valor de débito: $e');
      throw e;
    }
  }

  void _showUpdateValueDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alterar Valor de Débito'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: 'Novo valor'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Salvar'),
              onPressed: () {
                final newValue = double.tryParse(_controller.text) ?? 0.0;
                if (newValue > 0) {
                  _updateDebitValue(newValue);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, insira um valor válido')),
                  );
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
        title: Text('Notificações'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.isAdm) // Exibe o botão apenas para administradores
              ElevatedButton(
                onPressed: _showUpdateValueDialog,
                child: Text('Alterar Valor de Débito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<model.Notification>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erro ao carregar notificações'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Nenhuma notificação disponível'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final notification = snapshot.data![index];

                        // Cor da notificação marcada como lida: cinza apenas para usuários normais
                        final cardColor = widget.isAdm
                            ? Colors.white
                            : (notification.isRead ? Colors.grey[200] : Colors.white);

                        return Card(
                          color: cardColor,
                          elevation: 5,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16.0),
                            title: Text(
                              notification.text,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            // Remover o campo "Status" para admins
                            subtitle: widget.isAdm
                                ? Text('Data: ${notification.date}', style: TextStyle(fontSize: 16))
                                : Text(
                                    'Data: ${notification.date}\nStatus: ${notification.isRead ? 'Lida' : 'Não Lida'}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                            trailing: widget.isAdm
                                ? IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deleteNotification(notification.id);
                                    },
                                  )
                                : null,
                            // Remover a opção de marcar como lida para admins
                            leading: !widget.isAdm
                                ? Checkbox(
                                    value: notification.isRead,
                                    onChanged: notification.isRead
                                        ? null
                                        : (bool? value) {
                                            if (value == true) {
                                              _markAsRead(notification.id);
                                              setState(() {
                                                notification.isRead = true;
                                              });
                                            }
                                          },
                                  )
                                : null,
                            onTap: () {
                              if (!widget.isAdm && !notification.isRead) {
                                _markAsRead(notification.id);
                                setState(() {
                                  notification.isRead = true;
                                });
                              }
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
