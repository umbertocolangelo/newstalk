import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityHeader extends StatefulWidget {
  final String backgroundImageUrl;
  final String profileImageUrl;
  final String title;
  final double? height;
  final double? width;

  const CommunityHeader({
    Key? key,
    required this.backgroundImageUrl,
    required this.profileImageUrl,
    required this.title,
    this.height,
    this.width,
  }) : super(key: key);

  @override
  _CommunityHeaderState createState() => _CommunityHeaderState();
}

class _CommunityHeaderState extends State<CommunityHeader> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              widget.backgroundImageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              height: widget.height,
              width: widget.width, // Adjust width as needed
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child; // Image has loaded
                return Container(
                  color: Palette.offWhite,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                    ),
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return Container(
                  color: Palette.grey, // Gray background on error
                  child: Center(
                    child: Icon(Icons.error),
                  ),
                );
              },
            ),
          ),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Palette.grey.withOpacity(0.4),
                Colors.transparent,
              ],
              stops: [0.1, 0.9],
            ),
          ),
        ),
        Center(
          child: Column(
            children: [
              // Profile image
              CircleAvatar(
                radius: widget.height! * 0.26, // Adjust the size as needed
                backgroundColor: Palette.offWhite,
                child: CircleAvatar(
                  radius: widget.height! * 0.25, // Adjust the size as needed
                  backgroundImage: NetworkImage(widget.profileImageUrl),
                ),
              ),
              SizedBox(height: widget.height! * 0.05),
              Container(
                width: widget.width! * 0.8, // Adjust width as needed
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Palette.offWhite,
                    fontSize: 32.sp, // Adjust font size as needed
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(height: widget.height! * 0.15),
            ],
          ),
        ),
      ],
    );
  }
}
