import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:logging/logging.dart';
import 'package:pilot_the_dune/enemies/enemy.dart';
import 'package:pilot_the_dune/items/projectiles/bullet_basic.dart';
import 'package:pilot_the_dune/connection.dart';
import 'package:pilot_the_dune/enemies/ant.dart';
import 'package:pilot_the_dune/inventory.dart';
import 'package:pilot_the_dune/items/laser_gun.dart';
import 'package:pilot_the_dune/items/moon_berry.dart';
import 'package:pilot_the_dune/main.dart';
import 'package:pilot_the_dune/wall.dart';

class Player extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final logger = Logger('player.dart');

  final Inventory _inventory = Inventory();
  final bool godModeActive = false;

  /// Pixels/s
  double maxSpeed = 150.0;
  double life = 100.0;
  Vector2 _lastDirection = Vector2(1, 0);
  Vector2 direction = Vector2(0, 0);
  late SpriteSheet _playerSpriteSheet;

  late SpriteAnimation playerAnimationIdle;
  late SpriteAnimation playerAnimationUp;
  late SpriteAnimation playerAnimationLeft;
  late SpriteAnimation playerAnimationRight;
  late SpriteAnimation playerAnimationDown;
  
  late SpriteAnimation playerAnimationUpRight;
  late SpriteAnimation playerAnimationDownRight;
  late SpriteAnimation playerAnimationDownLeft;
  late SpriteAnimation playerAnimationUpLeft;


  Player(Vector2 startPosition)
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
      image = await game.images.load('test8x4.png');
    } else {
      image = await game.images.load('character_animation_default.png');
    }
    _playerSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 4,
      rows: 8,
    );

    playerAnimationUp = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 1,
      to: 4,
    );
    playerAnimationUpRight = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 1,
      from: 1,
      to: 4,
    );
    playerAnimationRight = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 2,
      from: 1,
      to: 4,
    );
    playerAnimationDownRight = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 3,
      from: 1,
      to: 4,
    );
    playerAnimationDown = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 4,
      from: 1,
      to: 4,
    );
    playerAnimationDownLeft = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 5,
      from: 1,
      to: 4,
    );
    playerAnimationLeft = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 6,
      from: 1,
      to: 4,
    );
    playerAnimationUpLeft = _playerSpriteSheet.createAnimation(
      stepTime: .1,
      row: 7,
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
    if (!direction.isZero() && activeCollisions.isEmpty) {
      _lastDirection = direction;


      final bool isUpRight = direction.y < 0 && direction.x > 0;
      final bool isDownRight = direction.y > 0 && direction.x > 0;
      final bool isDownLeft = direction.y > 0 && direction.x < 0;
      final bool isUpLeft = direction.y < 0 && direction.x < 0;
      final bool isUp = direction.y < 0 && direction.x.abs() < direction.y.abs();
      final bool isDown = direction.y > 0 && direction.x.abs() < direction.y.abs();
      final bool isLeft = direction.x < 0 && direction.y.abs() < direction.x.abs();
      final bool isRight = direction.x > 0 && direction.y.abs() < direction.x.abs();

      final bool animateUp = isUp && animation != playerAnimationUp;
      final bool animateUpRight = isUpRight && animation != playerAnimationUpRight;
      final bool animateDown = isDown && animation != playerAnimationDown;
      final bool animateDownRight = isDownRight && animation != playerAnimationDownRight;
      final bool animateLeft = isLeft && animation != playerAnimationLeft;
      final bool animateDownLeft = isDownLeft && animation != playerAnimationDownLeft;
      final bool animateRight = isRight && animation != playerAnimationRight;
      final bool animateUpLeft = isUpLeft && animation != playerAnimationUpLeft;

      super.update(dt);
      if (animateUp) {
        animation = playerAnimationUp;
      } else if (animateUpRight) {
        animation = playerAnimationUpRight;
      }else if (animateRight ) {
        animation = playerAnimationRight;
      } else if (animateDownRight) {
        animation = playerAnimationDownRight;
      } else if (animateDown) {
        animation = playerAnimationDown;
      }else if (animateDownLeft) {
        animation = playerAnimationDownLeft;
      }else if (animateLeft) {
        animation = playerAnimationLeft;
      }else if (animateUpLeft) {
        animation = playerAnimationUpLeft;
      }

      position.add(direction * maxSpeed * dt);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if ((other is Enemy || other is Wall) && godModeActive) {
      return;
    } 

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
