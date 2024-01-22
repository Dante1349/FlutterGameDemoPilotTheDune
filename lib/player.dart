import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:logging/logging.dart';
import 'package:tile_map/ant.dart';
import 'package:tile_map/bullet.dart';
import 'package:tile_map/laser_gun.dart';

class JoystickPlayer extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  final logger = Logger('player.dart');

  /// Pixels/s
  double maxSpeed = 150.0;
  Vector2 _lastDirection = Vector2(1, 0);
  late SpriteSheet _playerSpriteSheet;

  late SpriteAnimation playerAnimationIdle;
  late SpriteAnimation playerAnimationUp;
  late SpriteAnimation playerAnimationLeft;
  late SpriteAnimation playerAnimationRight;
  late SpriteAnimation playerAnimationDown;

  final JoystickComponent joystick;

  bool _hasGun = false;

  JoystickPlayer(this.joystick, Vector2 startPosition)
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
    var image;
    if (_hasGun) {
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
    if (other is Bullet) {
      return;
    } else if (other is LaserGun) {
      _hasGun = true;
      loadAnimation();
      game.world.remove(other);
      return;
    } else if (other is Ant) {
      game.world.remove(this);
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
    if (_hasGun) {
      final bullet = Bullet(absoluteCenter, _lastDirection);
      gameRef.world.add(bullet);
    }
  }
}
