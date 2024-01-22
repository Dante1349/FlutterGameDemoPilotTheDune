import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:logging/logging.dart';
import 'package:tile_map/ant.dart';
import 'package:tile_map/bullet.dart';

class JoystickPlayer extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final logger = Logger('player.dart');

  /// Pixels/s
  double maxSpeed = 150.0;
  late Vector2 _lastDirection;
  late final SpriteSheet _playerSpriteSheet;

  late SpriteAnimation playerAnimationIdle;
  late SpriteAnimation playerAnimationUp;
  late SpriteAnimation playerAnimationLeft;
  late SpriteAnimation playerAnimationRight;
  late SpriteAnimation playerAnimationDown;

  final JoystickComponent joystick;

  JoystickPlayer(this.joystick, Vector2 startPosition)
      : super(
            size: Vector2.all(32.0),
            anchor: Anchor.topLeft,
            position: startPosition);

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('pilot-Sheet.png');
    _playerSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 16,
      rows: 1,
    );

    playerAnimationIdle = _playerSpriteSheet.createAnimation(
      stepTime: 0.5,
      row: 0,
      from: 0,
      to: 1,
    );
    playerAnimationUp = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 1,
      to: 4,
    );
    playerAnimationLeft = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 9,
      to: 12,
    );
    playerAnimationRight = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 5,
      to: 8,
    );
    playerAnimationDown = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 13,
      to: 16,
    );

    animation = playerAnimationDown;

    add(RectangleHitbox(
        size: Vector2(16, 16),
        position: Vector2(16, 16),
        anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero() && activeCollisions.isEmpty) {
      _lastDirection=joystick.relativeDelta;

      final bool isUp = (joystick.direction == JoystickDirection.up ||
          joystick.direction == JoystickDirection.upLeft ||
          joystick.direction == JoystickDirection.upRight);

      final bool isDown = (joystick.direction == JoystickDirection.down ||
          joystick.direction == JoystickDirection.downLeft ||
          joystick.direction == JoystickDirection.downRight);
      final bool isLeft = joystick.direction == JoystickDirection.left;
      final bool isRight = joystick.direction == JoystickDirection.right;

      final bool animateUp = isUp && animation != playerAnimationUp;

      final bool animateDown = isDown && animation != playerAnimationDown;

      final bool animateLeft = isLeft && animation != playerAnimationLeft;

      final bool animateRight = isRight && animation != playerAnimationRight;

      super.update(dt);
      if (animateUp) {
        animation = playerAnimationUp;
      } else if (animateDown) {
        animation = playerAnimationDown;
      } else if (animateLeft) {
        animation = playerAnimationLeft;
      } else if (animateRight) {
        animation = playerAnimationRight;
      }

      position.add(joystick.relativeDelta * maxSpeed * dt);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Ant) {
      x = 0;
      y = 0;
    }

    if (intersectionPoints.length == 2) {
      final mid =
          (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) /
              2;

      final collisionVector = absoluteCenter - mid;
      double penetrationDepth = (size.x / 2) - collisionVector.length;

      collisionVector.normalize();
      position += collisionVector.scaled(penetrationDepth);
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void shoot() {
    print(x.toString() + ","+ y.toString());
    final bullet = Bullet(absoluteCenter, _lastDirection);
    log("bullet");
    gameRef.world.add(bullet);
  }
}
