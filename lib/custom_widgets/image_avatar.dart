import 'package:facemark/custom_widgets/hex_color.dart';
import 'package:flutter/material.dart';



class CircularAvatarWithLoading extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const CircularAvatarWithLoading({super.key, 
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  _CircularAvatarWithLoadingState createState() => _CircularAvatarWithLoadingState();
}

class _CircularAvatarWithLoadingState extends State<CircularAvatarWithLoading> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ClipOval(
      child: Image.network(
        "${Uri.parse(widget.imageUrl)}",
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Handle the error here, you can show an error image or message
          return Image.asset(
            widget.imageUrl,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
          );
        },
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              color: HexColor("#FE5A01"),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }
}
