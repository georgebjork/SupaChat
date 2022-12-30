class Message {
  Message({
    required this.id,
    required this.roomId,
    required this.profileId,
    required this.content,
    required this.createdAt,
    required this.isMine,
    required this.isRead
  });

  /// ID of the message
  final String id;

  //Id of the room it belongs in
  final String roomId;

  /// ID of the user who posted the message
  final String profileId;

  /// Text content of the message
  final String content;

  /// Date and time when the message was created
  final DateTime createdAt;

  /// Whether the message is sent by the user or not.
  final bool isMine;

  /// Has the message been read
  final bool isRead;

   Map<String, dynamic> toMap() {
    return {
      'profile_id': profileId,
      'room_id': roomId,
      'content': content,
    };
  }

  Message.fromMap({
    required Map<String, dynamic> map,
    required String myUserId,
  })  : id = map['id'],
        roomId = map['room_id'],
        profileId = map['profile_id'],
        content = map['content'],
        createdAt = DateTime.parse(map['created_at']),
        isMine = myUserId == map['profile_id'],
        isRead = map['is_read'];
}