import 'package:dima/model/thread.dart';
import 'package:dima/widgets/thread/thread_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityThreadList extends StatelessWidget {
  final List<Thread> threads;

  const CommunityThreadList({
    Key? key,
    required this.threads,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _listViewThreads(
        threads,
        BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height,
          maxWidth: MediaQuery.of(context).size.width,
        ));
  }
}

Widget _listViewThreads(List<Thread> threads, BoxConstraints constraints) {
  return Container(
    height: constraints.maxHeight * 0.2,
    width: constraints.maxWidth,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: threads.length,
      itemBuilder: (context, index) {
        return Padding(
          padding:  EdgeInsets.symmetric(horizontal: 8.sp),
          child: WidgetThreadCard(
              thread: threads[index],
              height: constraints.maxHeight * 0.5,
              width: constraints.maxWidth * 0.35),
        );
      },
    ),
  );
}
