import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageMessageView extends StatelessWidget {
  static const String routeName = '/image-viewer';
  final String imageUrl;

  const ImageMessageView({@required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PhotoView(
        imageProvider: imageUrl == null || imageUrl.isEmpty
            ? AssetImage('assets/images/icon_user.png')
            : NetworkImage(imageUrl),
        loadingBuilder: (ctx, loadingProgress) {
          if (loadingProgress == null) return Container();

          return FractionallySizedBox(
            widthFactor: loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes,
            child: Container(
              color: Colors.grey[400].withOpacity(0.3),
            ),
            alignment: Alignment.centerLeft,
          );
        },
      ),
    );
  }
}
