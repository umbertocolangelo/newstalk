import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AlertLoginDialog extends StatefulWidget {
  AlertLoginDialog({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  State<AlertLoginDialog> createState() => _AlertLoginDialogState();
}

class _AlertLoginDialogState extends State<AlertLoginDialog> {
  @override
  Widget build(BuildContext context) {
      ScreenUtil.init(context, designSize: Size(360, 690), minTextAdapt: true);
    final data = widget.text;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.black,
            size: 50.0,
          ),
           SizedBox(height: 10.sp),
          Text(
            data,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
