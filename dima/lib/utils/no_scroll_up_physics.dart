import 'package:flutter/material.dart';

class NoScrollUpPhysics extends ScrollPhysics {
  const NoScrollUpPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  NoScrollUpPhysics applyTo(ScrollPhysics? ancestor) {
    return NoScrollUpPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (offset < 0) {
      return 0.0;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }
}