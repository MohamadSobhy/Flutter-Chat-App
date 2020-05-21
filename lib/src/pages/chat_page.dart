import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/features/login/domain/entities/user.dart';
import 'package:chat_app/src/widgets/custom_app_bar_action.dart';
import 'package:chat_app/src/widgets/user_image_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../injection_container.dart';
import '../../main.dart';
import '../models/message.dart';
import '../widgets/empty_chat_message.dart';
import 'image_message_view.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = '/chat-page';

  final String peerId;
  final String peerName;
  final String peerImageUrl;

  const ChatPage(
      {@required this.peerId,
      @required this.peerName,
      @required this.peerImageUrl});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _isStickerOptionClicked = false;
  bool _isImageOptionClicked = false;
  bool _isTyping = false;
  bool _isTypingInArabic = false;
  bool _isSendingImages = false;
  String chatGroupId;
  String userId;
  final _messageFieldController = TextEditingController();
  final _focusNode = FocusNode();
  ScrollController listScrollController = ScrollController();
  SharedPreferences prefs;

  @override
  void initState() {
    _readUserData();
    _focusNode.addListener(_onFocusChanged);

    super.initState();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() {
        _isStickerOptionClicked = false;
        _isImageOptionClicked = false;
      });
    }
  }

  _readUserData() {
    prefs = serviceLocator<SharedPreferences>();

    userId = json.decode(prefs.getString('user'))['id'];

    if (userId.hashCode <= widget.peerId.hashCode) {
      chatGroupId = '$userId-${widget.peerId}';
    } else {
      chatGroupId = '${widget.peerId}-$userId';
    }
  }

  Future<void> _openImageGallery() async {
    List<Asset> selectedImages = [];
    try {
      selectedImages = await MultiImagePicker.pickImages(
        maxImages: 12,
        enableCamera: true,
        selectedAssets: selectedImages,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Choose Images",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      ).catchError((error) {
        print(error);
      });
    } on Exception catch (e) {
      //_error = e.toString();
      print(e);
    }

    if (!mounted || selectedImages.isEmpty) {
      setState(() {
        _isImageOptionClicked = !_isImageOptionClicked;
      });
      return;
    }

    if (selectedImages.length == 1) {
      final byteData = await selectedImages.first.getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      await _sendImage(imageData);
    } else {
      _sendListOfImages(selectedImages);
    }
  }

  Future<void> _sendImage(List<int> imageData) async {
    setState(() {
      _isImageOptionClicked = !_isImageOptionClicked;
      _isSendingImages = true;
    });
    final result = await _uplaodImageToServer(imageData);

    final message = Message(
      idFrom: userId,
      idTo: widget.peerId,
      content: result['url'],
      type: MessageType.image,
      isRead: false,
      timestamp: result['fileName'],
    );

    await _sendMessage(message);

    _isSendingImages = false;
  }

  Future<void> _sendListOfImages(List<Asset> imageAssets) async {
    setState(() {
      _isImageOptionClicked = !_isImageOptionClicked;
      _isSendingImages = true;
    });

    List<String> contentList = [];

    for (Asset imageAsset in imageAssets) {
      final byteData = await imageAsset.getByteData();
      final imageData = byteData.buffer.asUint8List();
      final result = await _uplaodImageToServer(imageData);
      contentList.add(result['url']);
    }

    Message message = Message(
      idFrom: userId,
      idTo: widget.peerId,
      content: json.encode(contentList),
      type: MessageType.listOfImages,
      isRead: false,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    await _sendMessage(message);

    _isSendingImages = false;
  }

  Future<Map<String, String>> _uplaodImageToServer(List<int> imageData) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageUploadTask task = FirebaseStorage.instance
        .ref()
        .child(chatGroupId + '-' + fileName)
        .putData(imageData);

    final taskSnapshot = await task.onComplete;
    return {
      'url': await taskSnapshot.ref.getDownloadURL(),
      'fileName': fileName,
    };
  }

  Future<void> _sendMessage(Message message) async {
    final documentReference = Firestore.instance
        .collection('messages')
        .document(chatGroupId)
        .collection(chatGroupId)
        .document(message.timestamp);

    Firestore.instance.runTransaction((transaction) async {
      final documentSnaphshot = await transaction.get(documentReference);
      await transaction.set(documentSnaphshot.reference, message.toMap());
    });

    // if (message.type == MessageType.sticker) {
    //   _isStickerOptionClicked = !_isStickerOptionClicked;
    // }

    listScrollController.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: FittedBox(
          child: Column(
            children: [
              UserImageAvatar(
                imageUrl: widget.peerImageUrl,
                height: 30.0,
                width: 30.0,
                onTap: null,
              ),
              Text(
                widget.peerName,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Theme.of(context).primaryColor),
              ),
              SizedBox(
                height: 5,
              )
            ],
          ),
        ),
        leading: CustomAppBarAction(
          icon: Icons.arrow_back_ios,
          onActionPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _buildChatBody(),
    );
  }

  Widget _buildChatBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: _buildMessagesList(),
        ),
        //_isSendingImages ? _buildDummyMessage() : Container(),
        _buildMessageInput(),
        _isStickerOptionClicked ? _buildStickerList() : Container(),
        // _isImageOptionClicked
        //     ? ImagesGallery(
        //         onSendingSingleImage: _sendImage,
        //         onSendingMultipleImage: _sendListOfImages,
        //       )
        //     : Container(),
      ],
    );
  }

  Widget _buildDummyMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 5.0,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Icon(
              Icons.cached,
              color: Colors.grey[400],
              size: 20.0,
            ),
            SizedBox(
              width: 5.0,
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[300],
              ),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.grey[200]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('messages')
          .document(chatGroupId)
          .collection(chatGroupId)
          .orderBy('timestamp', descending: true)
          .limit(30)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data.documentChanges.isEmpty) {
          return EmptyChatMessage(
            peerName: widget.peerName,
          );
        }

        return ListView.builder(
          controller: listScrollController,
          reverse: true,
          itemCount: _isSendingImages
              ? snapshot.data.documents.length + 1
              : snapshot.data.documents.length,
          itemBuilder: (ctx, index) {
            if (index == 0 && _isSendingImages) {
              return _buildDummyMessage();
            }

            final lastMessage =
                Message.fromJson(snapshot.data.documents.first.data);

            _markPeerMessagesAsRead(lastMessage);

            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: _buildMessageItem(snapshot
                  .data.documents[_isSendingImages ? index - 1 : index]),
            );
          },
        );
      },
    );
  }

  void _markPeerMessagesAsRead(Message lastMessage) {
    if (lastMessage.idFrom == widget.peerId) {
      print('Entered');
      Firestore.instance
          .collection('messages')
          .document(chatGroupId)
          .collection(chatGroupId)
          .where('idFrom', isEqualTo: widget.peerId)
          .where('isRead', isEqualTo: false)
          .getDocuments()
          .then((documentSnapshot) {
        print(documentSnapshot.documents.length);
        if (documentSnapshot.documents.length > 0) {
          for (DocumentSnapshot doc in documentSnapshot.documents) {
            doc.reference.updateData({'isRead': true});
            print('updated');
          }
        }
      });
    }
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    final message = Message.fromJson(document.data);

    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage(message);
      case MessageType.image:
        return _buildImageMessage(message);
      case MessageType.sticker:
        return _buildStickerMessage(message);
      case MessageType.listOfImages:
        return _buildListOfImagesMessage(message);
    }
    return Center(
      child: Text('Chat is going to be here!'),
    );
  }

  Widget _buildListOfImagesMessage(Message message) {
    List<String> imagePaths = List<String>.from(json.decode(message.content));
    return _buildMessageCard(
      isImage: true,
      message: message,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GridView.builder(
          primary: false,
          shrinkWrap: true,
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: imagePaths.length < 3 ? imagePaths.length : 3,
            childAspectRatio: 1.0,
            crossAxisSpacing: 1.5,
            mainAxisSpacing: 1.5,
          ),
          itemCount: imagePaths.length,
          itemBuilder: (ctx, index) {
            return ClipRRect(
              child: _buildImageWithLoading(imagePaths[index]),
              borderRadius: BorderRadius.only(
                topRight:
                    index == 0 ? Radius.circular(7.0) : Radius.circular(0.0),
                topLeft: index == 2
                    ? const Radius.circular(7.0)
                    : imagePaths.length == 2 && index == imagePaths.length - 1
                        ? const Radius.circular(7.0)
                        : const Radius.circular(0.0),
                bottomRight: index == imagePaths.length - 3 && index % 3 == 0
                    ? const Radius.circular(7.0)
                    : imagePaths.length - 1 == index && index % 3 == 0
                        ? const Radius.circular(7.0)
                        : imagePaths.length == 2 && index == 0
                            ? const Radius.circular(7.0)
                            : const Radius.circular(0.0),
                bottomLeft: index == imagePaths.length - 1 &&
                        imagePaths.length % 3 == 0
                    ? const Radius.circular(7.0)
                    : imagePaths.length == 2 && index == imagePaths.length - 1
                        ? const Radius.circular(7.0)
                        : const Radius.circular(0.0),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStickerMessage(Message message) {
    return _buildMessageCard(
      isSticker: true,
      message: message,
      child: Image.asset(
        'assets/Stickers/${message.content}.gif',
        height: 100.0,
      ),
    );
  }

  Widget _buildImageMessage(Message message) {
    return _buildMessageCard(
      isImage: true,
      message: message,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: _buildImageWithLoading(message.content),
      ),
    );
  }

  Widget _buildImageWithLoading(String imageUrl) {
    return InkWell(
      onTap: () => _openImageView(imageUrl),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        progressIndicatorBuilder: (_, child, loadingProgress) {
          if (loadingProgress.totalSize == null) return _buildEmptyContainer();

          return Stack(
            children: <Widget>[
              _buildEmptyContainer(),
              Positioned.fill(
                child: FractionallySizedBox(
                  widthFactor:
                      loadingProgress.downloaded / loadingProgress.totalSize,
                  child: Container(
                    color: Colors.black12,
                  ),
                  alignment: Alignment.centerLeft,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openImageView(String url) {
    Routes.sailor.navigate(ImageMessageView.routeName, params: {
      'imageUrl': url,
    });
  }

  Widget _buildEmptyContainer() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      // child: Center(
      //   child: CircularProgressIndicator(
      //     valueColor: AlwaysStoppedAnimation(Colors.grey[200]),
      //   ),
      // ),
    );
  }

  Widget _buildTextMessage(Message message) {
    return _buildMessageCard(
      child: Text(
        message.content,
        textAlign: _checkForArabicLetter(message.content)
            ? TextAlign.right
            : TextAlign.left,
        textDirection: _checkForArabicLetter(message.content)
            ? TextDirection.rtl
            : TextDirection.ltr,
        style: TextStyle(
          color: message.idFrom == userId ? Colors.white : Colors.black,
          fontSize: 16.0,
        ),
      ),
      message: message,
    );
  }

  bool _checkForArabicLetter(String text) {
    final arabicRegex = RegExp(r'[ء-ي-_ \.]*$');
    final englishRegex = RegExp(r'[a-zA-Z ]');
    return text.contains(arabicRegex) && !text.startsWith(englishRegex);
  }

  Widget _buildMessageCard(
      {Widget child,
      Message message,
      bool isImage = false,
      bool isSticker = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 5.0,
      ),
      child: Align(
        alignment: message.idFrom == userId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: message.idFrom == userId
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: userId == message.idFrom
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                userId == message.idFrom
                    ? Icon(
                        Icons.done_all,
                        color: message.isRead
                            ? Colors.deepOrange
                            : Colors.grey[400],
                        size: 20.0,
                      )
                    : Container(),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: !isImage
                        ? Border.all(width: 0.0, color: Colors.transparent)
                        : Border.all(
                            width: 2.0,
                            color: message.idFrom == userId
                                ? Theme.of(context).primaryColor
                                : Colors.transparent),
                    color: isSticker
                        ? Colors.transparent
                        : message.idFrom == userId
                            ? isImage
                                ? Colors.grey[200]
                                : Theme.of(context).primaryColor
                            : Colors.grey[200],
                  ),
                  padding: isImage
                      ? const EdgeInsets.all(0.0)
                      : const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                  child: child,
                ),
              ],
            ),
            Text(
              intl.DateFormat('dd MMM KK:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(
                  int.parse(message.timestamp),
                ),
              ),
              style: TextStyle(
                fontSize: 13.0,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickerList() {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.all(0.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120.0,
            childAspectRatio: 1.0,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
          ),
          itemCount: 18,
          itemBuilder: (ctx, index) {
            int count;
            if (index <= 8) {
              count = 1;
            } else {
              count = -8;
            }
            return InkWell(
              child: Image.asset('assets/Stickers/mimi${index + count}.gif'),
              onTap: () {
                _sendSticker('mimi${index + count}');
              },
            );
          },
        ),
      ),
    );
  }

  void _sendSticker(String stickerName) {
    final message = Message(
      idFrom: userId,
      idTo: widget.peerId,
      content: stickerName,
      type: MessageType.sticker,
      isRead: false,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    setState(() {
      _isStickerOptionClicked = false;
    });

    _sendMessage(message);
  }

  Widget _buildMessageInput() {
    return Card(
      elevation: 0.0,
      margin: const EdgeInsets.all(0.0),
      child: Container(
        height: 45,
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: () {
                _focusNode.unfocus();
                setState(() {
                  _isImageOptionClicked = !_isImageOptionClicked;
                  _isStickerOptionClicked = false;
                });

                _openImageGallery();
              },
              // onTapDown: (_) {
              //   setState(() {
              //     _isImageOptionClicked = !_isImageOptionClicked;
              //   });
              // },
              // onTapCancel: () {
              //   setState(() {
              //     _isImageOptionClicked = !_isImageOptionClicked;
              //   });
              // },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.camera_alt,
                  color:
                      _isImageOptionClicked ? Colors.deepOrange : Colors.grey,
                ),
              ),
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.tag_faces,
                  color:
                      _isStickerOptionClicked ? Colors.deepOrange : Colors.grey,
                ),
              ),
              onTap: () {
                _focusNode.unfocus();

                setState(() {
                  _isStickerOptionClicked = !_isStickerOptionClicked;
                  _isImageOptionClicked = false;
                });
              },
            ),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                controller: _messageFieldController,
                textAlign: _isTypingInArabic ? TextAlign.right : TextAlign.left,
                textDirection:
                    _isTypingInArabic ? TextDirection.rtl : TextDirection.ltr,
                maxLines: 6,
                cursorColor: Colors.deepOrange,
                decoration: InputDecoration(
                  enabledBorder: InputBorder.none,
                  border: OutlineInputBorder(),
                  hintText: 'Type a message . . .',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                ),
                onChanged: (String value) {
                  if (value.trim().isNotEmpty) {
                    _isTyping = true;
                    if (_checkForArabicLetter(value)) {
                      _isTypingInArabic = true;
                    }
                  } else {
                    _isTyping = false;
                    _isTypingInArabic = false;
                  }
                  setState(() {});
                },
              ),
            ),
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Icon(
                  Icons.send,
                  color: _isTyping ? Colors.deepOrange : Colors.grey[400],
                ),
              ),
              onTap: _isTyping
                  ? () {
                      final message = Message(
                        idFrom: userId,
                        idTo: widget.peerId,
                        content: _messageFieldController.text.trim(),
                        type: MessageType.text,
                        isRead: false,
                        timestamp:
                            DateTime.now().millisecondsSinceEpoch.toString(),
                      );

                      _messageFieldController.clear();
                      setState(() {
                        _isTypingInArabic = false;
                        _isTyping = !_isTyping;
                      });
                      _sendMessage(message);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
