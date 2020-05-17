import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:storage_path/storage_path.dart';

class ImagesGallery extends StatefulWidget {
  final Function(String) onSendingSingleImage;
  final Function(List<String>) onSendingMultipleImage;

  const ImagesGallery({
    @required this.onSendingSingleImage,
    @required this.onSendingMultipleImage,
  });
  @override
  _ImagesGalleryState createState() => _ImagesGalleryState();
}

class _ImagesGalleryState extends State<ImagesGallery> {
  List<String> _selectedImages = [];

  Future<List<String>> _chooseImageFromGallery() async {
    // final imageFile = await ImagePicker.pickImage(
    //   source: ImageSource.gallery,
    // );

    // if (imageFile != null) {
    //   print(imageFile.path);
    // }
    // return imageFile;
    final status = await Permission.storage.request().isGranted;
    if (status) {
      print('granted');
      try {
        List<String> imagesPathList = [];
        final imagesJsonList =
            json.decode(await StoragePath.imagesPath) as List;

        imagesJsonList.forEach((imagesFolderMap) {
          final imagesOnFolder =
              List<String>.from(imagesFolderMap['files'].map((path) => path));
          imagesPathList.addAll(imagesOnFolder);
        });

        print(imagesPathList);
        return imagesPathList;
      } catch (e) {
        print(e);
        return [];
      }
    } else {
      print('refused');
      return [null];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      margin: const EdgeInsets.all(0.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        child: FutureBuilder(
          future: _chooseImageFromGallery(),
          builder: (ctx, snapsot) {
            if (!snapsot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapsot.data[0] == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You must accept the permission to access images on your device',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    OutlineButton(
                      onPressed: () {
                        setState(() {});
                      },
                      child: Text(
                        'Try Again',
                      ),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: <Widget>[
                GridView.builder(
                  padding: const EdgeInsets.all(2.0),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120.0,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                  ),
                  itemCount: snapsot.data.length,
                  itemBuilder: (ctx, index) {
                    return InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3.0),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.grey[300]),
                                ),
                              ),
                            ),
                            Image.file(
                              File(snapsot.data[index]),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              cacheHeight: 120,
                              cacheWidth: 120,
                            ),
                            _selectedImages.contains(snapsot.data[index])
                                ? Center(
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.deepOrange.withOpacity(0.8),
                                      radius: 15.0,
                                      child: Icon(
                                        Icons.done,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      onTap: () {
                        //_sendImage(snapsot.data[index]);
                        if (!_selectedImages.contains(snapsot.data[index])) {
                          if (_selectedImages.length < 12) {
                            _selectedImages.add(snapsot.data[index]);
                          } else {
                            Fluttertoast.showToast(
                              msg: 'You can select max 12 images',
                            );
                          }
                        } else {
                          _selectedImages.remove(snapsot.data[index]);
                        }
                        setState(() {});
                      },
                      onLongPress: () {},
                    );
                  },
                ),
                _selectedImages.isNotEmpty
                    ? Positioned(
                        right: 15.0,
                        bottom: 15.0,
                        child: FloatingActionButton(
                          onPressed: _sendImages,
                          child: FittedBox(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  _selectedImages.length.toString(),
                                  style: TextStyle(
                                    fontSize: 15.0,
                                  ),
                                ),
                                Icon(
                                  Icons.send,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }

  void _sendImages() {
    // if (_selectedImages.length == 1) {
    //   widget.onSendingSingleImage(_selectedImages.first);
    // } else {
    //   widget.onSendingMultipleImage([..._selectedImages]);
    // }
    // setState(() {
    //   _selectedImages.clear();
    // });
  }
}
