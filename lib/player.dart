import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:logging/logging.dart';
import 'package:pilot_the_dune/items/projectiles/bullet_basic.dart';
import 'package:pilot_the_dune/connection.dart';
import 'package:pilot_the_dune/enemies/ant.dart';
import 'package:pilot_the_dune/inventory.dart';
import 'package:pilot_the_dune/items/laser_gun.dart';
import 'package:pilot_the_dune/items/moon_berry.dart';
import 'package:pilot_the_dune/main.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final logger = Logger('player.dart');

  final Inventory _inventory = Inventory();

  /// Pixels/s
  double maxSpeed = 150.0;
  double life = 100.0;
  Vector2 _lastDirection = Vector2(1, 0);
  late SpriteSheet _playerSpriteSheet;

  late SpriteAnimation playerAnimationIdle;
  late SpriteAnimation playerAnimationUp;
  late SpriteAnimation playerAnimationLeft;
  late SpriteAnimation playerAnimationRight;
  late SpriteAnimation playerAnimationDown;

  final JoystickComponent joystick;

  Player(this.joystick, Vector2 startPosition)
      : super(
            size: Vector2.all(32.0),
            anchor: Anchor.topLeft,
            position: startPosition);

  @override
  Future<void> onLoad() async {
    await loadAnimation();

    add(RectangleHitbox(
        size: Vector2(16, 16),
        position: Vector2(16, 16),
        anchor: Anchor.center));
  }

  Future<void> loadAnimation() async {
    Image image;
    if (_inventory.hasItem<LaserGun>()) {
      image = await game.images.load('pilot-gun-spritesheet.png');
    } else {
      image = await game.images.load('pilot-spritesheet.png');
    }
    _playerSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 4,
      rows: 4,
    );

    playerAnimationUp = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 1,
      to: 4,
    );
    playerAnimationRight = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 1,
      from: 1,
      to: 4,
    );
    playerAnimationDown = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 2,
      from: 1,
      to: 4,
    );
    playerAnimationLeft = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 3,
      from: 1,
      to: 4,
    );

    animation = playerAnimationRight;
  }

  @override
  void update(double dt) {
    if (life <= 0) {
      gameRef.world.remove(this);
    }
    if (!joystick.delta.isZero() && activeCollisions.isEmpty) {
      _lastDirection = joystick.relativeDelta;

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
    if (other is BasicBullet) {
      return;
    } else if(other is Connection) {
      (gameRef as PilotTheDuneGame).loadLevel(other.targetMap);
      return;

    } else if (other is LaserGun) {
      _inventory.addItem(other);
      loadAnimation();
      game.world.remove(other);
      return;
    } else if (other is Ant) {
      life -= 25.0;
    } else if (other is MoonBerry) {
      life += 10.0;
      if (life > 100.0) {
        life = 100.0;
      }
      game.world.remove(other);
      return;
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
    if (_inventory.hasItem<LaserGun>() && life > 0) {
      final bullet = BasicBullet(absoluteCenter, _lastDirection);
      gameRef.world.add(bullet);
    }
  }

  Inventory getInventory() {
    return _inventory;
  }
}
