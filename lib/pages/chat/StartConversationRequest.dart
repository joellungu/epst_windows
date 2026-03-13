class StartConversationRequest {
  final String clientName;

  StartConversationRequest({required this.clientName});

  Map<String, dynamic> toJson() => {'clientName': clientName};
}
