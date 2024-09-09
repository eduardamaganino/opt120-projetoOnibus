import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notification_model.dart' as model;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

        _notifications!.sort((a, b) {
          if (a.isRead != b.isRead) {
          return a.isRead ? 1 : -1; 
        }
        return b.date.compareTo(a.date);
        });

        return _notifications!;
      } else {
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
          if (a.isRead != b.isRead) {
            return a.isRead ? 1 : -1;
          }
          return b.date.compareTo(a.date);
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

  String _formatDate(String dateString) {
  final DateTime dateTime = DateTime.parse(dateString);
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm:ss');
  final String formattedDate = dateFormat.format(dateTime);
  final String formattedTime = timeFormat.format(dateTime);
  return 'Data: $formattedDate\nHorário: $formattedTime';
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
                            subtitle: widget.isAdm
                                ? Text(_formatDate(notification.date), style: TextStyle(fontSize: 16))
                                : Text(
                                    '${_formatDate(notification.date)}\nStatus: ${notification.isRead ? 'Lida' : 'Não Lida'}',
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
