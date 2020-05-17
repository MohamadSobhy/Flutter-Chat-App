import 'package:meta/meta.dart';

enum MessageType {
  text,
  image,
  listOfImages,
  sticker,
}

class Message {
  final String idFrom;
  final String idTo;
  final String content;
  final MessageType type;
  final bool isRead;
  final String timestamp;

  Message({
    @required this.idFrom,
    @required this.idTo,
    @required this.content,
    @required this.type,
    @required this.isRead,
    @required this.timestamp,
  });

  Message.fromJson(Map<String, dynamic> parsedJson)
      : idFrom = parsedJson['idFrom'] as String,
        idTo = parsedJson['idTo'] as String,
        content = parsedJson['content'] as String,
        type = MessageType.values[parsedJson['type'] as int],
        isRead = parsedJson['isRead'] ?? true,
        timestamp = parsedJson['timestamp'] as String;

  Map<String, dynamic> toMap() {
    return {
      'idFrom': idFrom,
      'idTo': idTo,
      'content': content,
      'type': type.index,
      'isRead': isRead,
      'timestamp': timestamp,
    };
  }
}
