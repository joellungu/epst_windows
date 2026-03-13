class Message {
  final int? id;
  final int conversationId;
  final String sender;
  final String content;
  final DateTime timestamp;
  final MessageType type;

  Message({
    this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      sender: json['sender'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
    );
  }
}

enum MessageType { TEXT, SYSTEM }
