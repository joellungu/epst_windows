class Conversation {
  final int? id;
  final String clientName;
  final String clientId;
  final String? agentMatricule;
  final ConversationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Conversation({
    this.id,
    required this.clientName,
    required this.clientId,
    this.agentMatricule,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      clientName: json['clientName'],
      clientId: json['clientId'],
      agentMatricule: json['agentMatricule'],
      status: ConversationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}

enum ConversationStatus { PENDING, ACTIVE, CLOSED }
