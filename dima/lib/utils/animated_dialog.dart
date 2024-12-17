import 'package:flutter/material.dart';

class AnimatedDialog extends StatelessWidget {
  final Widget child;

  AnimatedDialog({required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.7, end: 1.0).animate(
          CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOut,
          ),
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: ModalRoute.of(context)!.animation!,
            curve: Curves.easeOut,
          ),
          child: child,
        ),
      ),
    );
  }
}