import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima/model/comment.dart';
import 'package:dima/model/user.dart';
import 'package:dima/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommentsList extends StatelessWidget {
  final List<Comment> comments;
  final Map<String, Color> commentColors;
  final String currentUserId;
  final List<User> users;

  CommentsList({
    required this.comments,
    required this.commentColors,
    required this.currentUserId,
    required this.users,
  });

  Color _generateRandomColor({required List<Color> excludeColors}) {
    Random random = Random();
    List<Color> pastelColors = [
      Color.fromRGBO(255, 204, 204, 0.8), // Pastel red
      Color.fromRGBO(255, 255, 204, 0.8), // Pastel yellow
      Color.fromRGBO(204, 255, 204, 0.8), // Pastel green
      Color.fromRGBO(204, 255, 255, 0.8), // Pastel cyan
      Color.fromRGBO(204, 204, 255, 0.8), // Pastel blue
      Color.fromRGBO(255, 204, 255, 0.8), // Pastel magenta
      Color.fromRGBO(255, 229, 204, 0.8), // Pastel peach
      Color.fromRGBO(204, 229, 255, 0.8), // Pastel sky blue
      Color.fromRGBO(229, 204, 255, 0.8), // Pastel lavender
      Color.fromRGBO(204, 255, 229, 0.8), // Pastel mint
    ];

    Color color;
    do {
      color = pastelColors[random.nextInt(pastelColors.length)];
    } while (excludeColors.contains(color));

    return color;
  }

  String timeAgo(Timestamp timestamp) {
    final DateTime dataMessaggio = timestamp.toDate();
    final DateTime adesso = DateTime.now();
    final Duration differenza = adesso.difference(dataMessaggio);

    if (differenza.inSeconds < 60) {
      return 'Appena adesso';
    } else if (differenza.inMinutes < 60) {
      return '${differenza.inMinutes} minut${differenza.inMinutes > 1 ? 'i' : 'o'} fa';
    } else if (differenza.inHours < 24) {
      return '${differenza.inHours} or${differenza.inHours > 1 ? 'e' : 'a'} fa';
    } else if (differenza.inDays < 7) {
      return '${differenza.inDays} giorn${differenza.inDays > 1 ? 'i' : 'o'} fa';
    } else if (differenza.inDays < 30) {
      final settimane = (differenza.inDays / 7).floor();
      return '$settimane settiman${settimane > 1 ? 'e' : 'a'} fa';
    } else if (differenza.inDays < 365) {
      final mesi = (differenza.inDays / 30).floor();
      return '$mesi mes${mesi > 1 ? 'i' : 'e'} fa';
    } else {
      final anni = (differenza.inDays / 365).floor();
      return '$anni ann${anni > 1 ? 'i' : 'o'} fa';
    }
  }

  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    String? lastUserId;
    List<Color> usedColors = [];

    if (comments.isEmpty) {
      return Center(child: Text('Scrivi il primo commento!'));
    }

    if (users.isEmpty) {
      return Container(
        color: Palette.offWhite,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
          ),
        ),
      );
    }

    return Column(
      children: comments.map((comment) {
        final isCurrentUser = comment.userId == currentUserId;
        final user = users.firstWhere((user) => user.id == comment.userId);

        // Assign color if not already assigned
        if (!commentColors.containsKey(comment.userId)) {
          // Ensure no consecutive same colors
          final color = _generateRandomColor(excludeColors: usedColors);
          commentColors[comment.userId] = color;
        }

        final color = commentColors[comment.userId]!;

        // Ensure no consecutive same colors
        if (comment.userId != lastUserId) {
          usedColors.add(color);
        }

        final showAvatar = lastUserId != comment.userId;
        lastUserId = comment.userId;

        return Container(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          margin: EdgeInsets.fromLTRB(10.sp, showAvatar ? 38.sp : 2.sp, 10.sp, 3.sp),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: isCurrentUser
                      ? MediaQuery.of(context).size.width * 0.35
                      : 0,
                  right: isCurrentUser
                      ? 0
                      : MediaQuery.of(context).size.width * 0.35,
                ),
                child: Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      bottomLeft: isCurrentUser
                          ? Radius.circular(20.0)
                          : Radius.circular(5.0),
                      bottomRight: isCurrentUser
                          ? Radius.circular(5.0)
                          : Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.content,
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 5.sp),
                      Row(
                        mainAxisAlignment: isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isCurrentUser) ...[
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.sp),
                            ),
                            SizedBox(width: 4.sp),
                          ],
                          Text(
                            timeAgo(comment.time),
                            style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (showAvatar)
                Positioned(
                  top: -35.sp,
                  left: isCurrentUser ? null : -7,
                  right: isCurrentUser ? -7 : null,
                  child: ClipOval(
                    child: SizedBox(
                      width: 50.sp,
                      height: 50.sp,
                      child: user.profileImagePath.startsWith('assets')
                        ? Image.asset(
                            user.profileImagePath,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            user.profileImagePath,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                    : null,
                                  valueColor: AlwaysStoppedAnimation<Color>(Palette.grey),
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Icon(Icons.error, size: 25.sp);
                            },
                          ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
