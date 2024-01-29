import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class LifeBar extends PositionComponent {
  double percentage;

  LifeBar(this.percentage) : super(size: Vector2(200, 20), position: Vector2(10, 10));

  @override
  void render(Canvas canvas) {
    final width = size.x;
    final height = size.y;

    final redRect = Rect.fromLTWH(0, 0, width * (percentage / 100), height);
    final outlineRect = Rect.fromLTWH(0, 0, width, height);
    final blackOutline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final redFill = Paint()..color = Colors.red;

    canvas.drawRect(redRect, redFill);
    canvas.drawRect(outlineRect, blackOutline);
  }
}
