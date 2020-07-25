import 'package:chat_app/src/widgets/custom_app_bar_action.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageMessageView extends StatelessWidget {
  static const String routeName = '/image-viewer';
  final String imageUrl;

  const ImageMessageView({@required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          PhotoView(
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
          Positioned(
            top: 30,
            left: 0,
            child: CustomAppBarAction(
              height: 45,
              icon: Icons.arrow_back_ios,
              onActionPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    );
  }
}
