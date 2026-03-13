class SendMessageRequest {
  final int conversationId;
  final String sender;
  final String content;

  SendMessageRequest({
    required this.conversationId,
    required this.sender,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'sender': sender,
    'content': content,
  };
}

enum MessageType { TEXT, SYSTEM }
