// models/notification_model.dart
class Notification {
  final int id;
  final int idUser;
  final String text;
  final String date;
  bool isRead; // Mude de int para bool

  Notification({
    required this.id,
    required this.idUser,
    required this.text,
    required this.date,
    this.isRead = false, // Inicialize como false
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      idUser: json['idUser'],
      text: json['texto'],
      date: json['dataHora'],
      isRead: json['isRead'] == 1, // Converta int para bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idUser': idUser,
      'texto': text,
      'dataHora': date,
      'isRead': isRead ? 1 : 0, // Converta bool para int
    };
  }
}
