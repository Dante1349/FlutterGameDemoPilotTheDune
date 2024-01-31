import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

class KeyboardInput extends Component with KeyboardHandler {
  Vector2 keyboardDirection = Vector2.zero();
  late final Stream<void> xButton;
  late final Stream<void> yButton;
  late final Stream<void> pauseButton;
  late final Stream<void> inventoryButton;
  final StreamController<void> xButtonStreamController =
      StreamController<void>();
  final StreamController<void> yButtonStreamController =
      StreamController<void>();
  final StreamController<void> pauseButtonStreamController =
      StreamController<void>();
  final StreamController<void> inventoryButtonStreamController =
      StreamController<void>();

  
  Future<void> load () async {
    xButton = xButtonStreamController.stream;
    yButton = yButtonStreamController.stream;
    pauseButton = pauseButtonStreamController.stream;
    inventoryButton = inventoryButtonStreamController.stream;
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.containsAll(
        [LogicalKeyboardKey.keyA, LogicalKeyboardKey.keyW])) {
      keyboardDirection = Vector2(-0.75, -0.75);
    } else if (keysPressed.containsAll(
        [LogicalKeyboardKey.keyA, LogicalKeyboardKey.keyS])) {
      keyboardDirection = Vector2(-0.75, 0.75);
    } else if (keysPressed.containsAll(
        [LogicalKeyboardKey.keyD, LogicalKeyboardKey.keyW])) {
      keyboardDirection = Vector2(0.75, -0.75);
    } else if (keysPressed.containsAll(
        [LogicalKeyboardKey.keyD, LogicalKeyboardKey.keyS])) {
      keyboardDirection = Vector2(0.75, 0.75);
    } else if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      keyboardDirection = Vector2(-1, 0);
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      keyboardDirection = Vector2(1, 0);
    } else if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      keyboardDirection = Vector2(0, -1);
    } else if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      keyboardDirection = Vector2(0, 1);
    } else {
      keyboardDirection = Vector2.zero();
    }

    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      xButtonStreamController.add(null);
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      yButtonStreamController.add(null);
    } else if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      pauseButtonStreamController.add(null);
    } else if (keysPressed.contains(LogicalKeyboardKey.keyI)) {
      inventoryButtonStreamController.add(null);
    }

    super.onKeyEvent(event, keysPressed);
    return true;
  }
}
