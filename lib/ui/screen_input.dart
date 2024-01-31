import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';

class ScreenInput extends Component with HasGameRef {
  final StreamController<void> xButtonStreamController =
      StreamController<void>();
  final StreamController<void> yButtonStreamController =
      StreamController<void>();
  final StreamController<void> pauseButtonStreamController =
      StreamController<void>();
  final StreamController<void> inventoryButtonStreamController =
      StreamController<void>();
  late final Stream<void> xButton;
  late final Stream<void> yButton;
  late final Stream<void> pauseButton;
  late final Stream<void> inventoryButton;

  late SpriteComponent knob;
  late SpriteComponent background;
  late JoystickComponent joystick;
  late SpriteButtonComponent xButtonSpriteComponent;
  late SpriteButtonComponent yButtonSpriteComponent;
  late SpriteButtonComponent pauseButtonSpriteComponent;
  late SpriteButtonComponent inventoryButtonSpriteComponent;

  load() async {
    xButton = xButtonStreamController.stream;
    yButton = yButtonStreamController.stream;
    pauseButton = pauseButtonStreamController.stream;
    inventoryButton = inventoryButtonStreamController.stream;

    final image = await gameRef.images.load('ui.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 9,
      rows: 2,
    );

    background = SpriteComponent(
        sprite: sheet.getSpriteById(0),
        size: Vector2(32, 32));

    knob = SpriteComponent(
        sprite: sheet.getSpriteById(1),
        size: Vector2(32, 32));

    joystick = JoystickComponent(
      knob: knob,
      background: background,
      position: Vector2(100, gameRef.camera.viewport.size.y - 100),
    );
    joystick.scale=Vector2(4,4);
    xButtonSpriteComponent = SpriteButtonComponent(
        button: sheet.getSpriteById(5),
        buttonDown: sheet.getSpriteById(14),
        onPressed: () => xButtonStreamController.add(null),
        position: Vector2(gameRef.camera.viewport.size.x - 125,
            gameRef.camera.viewport.size.y - 150),
        size: Vector2(32, 32));
    yButtonSpriteComponent = SpriteButtonComponent(
        button: sheet.getSpriteById(6),
        buttonDown: sheet.getSpriteById(15),
        onPressed: () => yButtonStreamController.add(null),
        position: Vector2(gameRef.camera.viewport.size.x - 225,
            gameRef.camera.viewport.size.y - 100),
        size: Vector2(32, 32));

    pauseButtonSpriteComponent = SpriteButtonComponent(
        button: sheet.getSpriteById(7),
        buttonDown: sheet.getSpriteById(16),
        onPressed: () => pauseButtonStreamController.add(null),
        position: Vector2(gameRef.camera.viewport.size.x - 64 - 10, 10),
        size: Vector2(32, 32));

    inventoryButtonSpriteComponent = SpriteButtonComponent(
        button: sheet.getSpriteById(8),
        buttonDown: sheet.getSpriteById(17),
        onPressed: () => inventoryButtonStreamController.add(null),
        position: Vector2(gameRef.camera.viewport.size.x - 2 * 64 - 2 * 10, 10),
        size: Vector2(32, 32));

    xButtonSpriteComponent.width = xButtonSpriteComponent.width * 2;
    xButtonSpriteComponent.height = xButtonSpriteComponent.height * 2;
    yButtonSpriteComponent.width = yButtonSpriteComponent.width * 2;
    yButtonSpriteComponent.height = yButtonSpriteComponent.height * 2;
    pauseButtonSpriteComponent.width = pauseButtonSpriteComponent.width * 2;
    pauseButtonSpriteComponent.height = pauseButtonSpriteComponent.height * 2;
    inventoryButtonSpriteComponent.width =
        inventoryButtonSpriteComponent.width * 2;
    inventoryButtonSpriteComponent.height =
        inventoryButtonSpriteComponent.height * 2;

    gameRef.camera.viewport.addAll([
      joystick,
      xButtonSpriteComponent,
      yButtonSpriteComponent,
      pauseButtonSpriteComponent,
      inventoryButtonSpriteComponent
    ]);
  }

  void destroy() {
    xButtonStreamController.close();
    yButtonStreamController.close();
    pauseButtonStreamController.close();
    inventoryButtonStreamController.close();
    gameRef.camera.viewport.removeAll([
      joystick,
      xButtonSpriteComponent,
      yButtonSpriteComponent,
      pauseButtonSpriteComponent,
      inventoryButtonSpriteComponent
    ]);
  }
}
