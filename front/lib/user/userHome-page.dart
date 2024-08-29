import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/notification_model.dart' as model;
import 'package:http/http.dart' as http;

class UserHomePageWidget extends StatefulWidget {
  final int userId;

  UserHomePageWidget({required this.userId});

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
        builder: (context) => NotificationsPage(userId: widget.userId),
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
                opacity: 0.3, // Ajuste a opacidade para não sobrecarregar o conteúdo
                child: Icon(
                  Icons.directions_bus,
                  size: MediaQuery.of(context).size.width * 0.47, // Tamanho do ícone
                  color: Colors.grey, // Cor do ícone
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

  NotificationsPage({required this.userId});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<model.Notification>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = _fetchNotifications(widget.userId);
  }

  Future<List<model.Notification>> _fetchNotifications(int userId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/getAllNotifi'));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as List<dynamic>;
        return jsonData.map((item) => model.Notification.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/updateNotificacaoStatus/$notificationId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'isRead': 1}),
      );
      if (response.statusCode == 200) {
        setState(() {
          _notifications = _fetchNotifications(widget.userId);
        });
      } else {
        throw Exception('Failed to update notification status');
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
          _notifications = _fetchNotifications(widget.userId);
        });
      } else {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print(e);
      throw e;
    }
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
        child: FutureBuilder<List<model.Notification>>(
          future: _notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar notificações'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Nenhuma notificação disponível'));
            } else {
              final notifications = snapshot.data!;
              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        notification.text,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Data: ${notification.date}\nStatus: ${notification.isRead ? 'Lida' : 'Não Lida'}',
                        style: TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteNotification(notification.id);
                        },
                      ),
                      leading: Checkbox(
                        value: notification.isRead,
                        onChanged: (bool? value) {
                          if (value != null) {
                            _markAsRead(notification.id);
                          }
                        },
                      ),
                      onTap: () {
                        if (!notification.isRead) {
                          _markAsRead(notification.id);
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
    );
  }
}
