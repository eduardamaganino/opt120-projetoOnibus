// models/notification_model.dart
class Notification {
  final int id;
  final String text;
  final String date;
  bool isRead; // Mude de int para bool

  Notification({
    required this.id,
    required this.text,
    required this.date,
    this.isRead = false, // Inicialize como false
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      text: json['texto'],
      date: json['dataHora'],
      isRead: json['isRead'] == 1, // Converta int para bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'texto': text,
      'dataHora': date,
      'isRead': isRead ? 1 : 0, // Converta bool para int
    };
  }
}
