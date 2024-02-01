import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:pilot_the_dune/main.dart';
import 'package:pilot_the_dune/player.dart';
import 'package:pilot_the_dune/wall.dart';

class NPC extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final Vector2 _hitBoxSize;
  final String _spriteSheetPath;
  late SpriteSheet _spriteSheet;

  late SpriteAnimation animationUp;
  late SpriteAnimation animationRight;
  late SpriteAnimation animationDown;
  late SpriteAnimation animationLeft;

  static const double speed = 100.0; // Adjust the speed as needed
  static const double stopRadius = 50.0; // Radius to start following the player
  static const double changeDirectionInterval =
      2.0; // Change direction every 2 seconds

  bool isFollowingPlayer = false;
  Vector2 randomDirection = Vector2(1.0, 0.0)
    ..rotate(Random().nextInt(8) * (pi / 4.0));
  double changeDirectionTimer = 0.0;

  NPC(Vector2 startPosition, this._spriteSheetPath, size, this._hitBoxSize)
      : super(size: size, anchor: Anchor.topLeft, position: startPosition);

  @override
  Future<void> onLoad() async {
    final image = await game.images.load(_spriteSheetPath);
    _spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 4,
      rows: 4,
    );

    animationUp = _spriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 1,
      to: 4,
    );
    animationRight = _spriteSheet.createAnimation(
      stepTime: .1,
      row: 1,
      from: 1,
      to: 4,
    );
    animationDown = _spriteSheet.createAnimation(
      stepTime: .1,
      row: 2,
      from: 1,
      to: 4,
    );
    animationLeft = _spriteSheet.createAnimation(
      stepTime: .1,
      row: 3,
      from: 1,
      to: 4,
    );

    animation = animationRight;

    add(RectangleHitbox(
        size: _hitBoxSize,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    move(dt);
  }

  void move(double dt) {
    // Check if player is still within follow radius
    double distanceToPlayer = (gameRef as PilotTheDuneGame)
        .level
        .player
        .position
        .distanceTo(position);
    if (distanceToPlayer > stopRadius) {
      // Update the timer for changing direction
      changeDirectionTimer += dt;

      // Change direction after the specified interval
      if (changeDirectionTimer >= changeDirectionInterval) {
        // Change the direction to a multiple of 45 degrees
        int randomAngleIndex = Random().nextInt(8);
        randomDirection = Vector2(1.0, 0.0).normalized()
          ..rotate(randomAngleIndex * (pi / 4.0));

        // Reset the timer
        changeDirectionTimer = 0.0;
      }

      // Move in the current random direction
      position += randomDirection * speed * dt;

      // Update the animation based on the direction of movement
      updateAnimation(randomDirection);
    } else {
      facePlayer(dt);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Wall) {
      randomDirection = randomDirection.inverted();
    } else if (other is Player) {
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

  void facePlayer(double dt) {
    // Implement player-following movement logic here
    // You can use Flame's Vector2 class for movement
    var playerPosition = (gameRef as PilotTheDuneGame).level.player.position;
    Vector2 direction = playerPosition - position;
    direction.normalize();

    // Update the animation based on the direction of movement
    updateAnimation(direction);
  }

  void updateAnimation(Vector2 direction) {
    final bool isUp = direction.y < 0 && direction.x.abs() < direction.y.abs();
    final bool isDown =
        direction.y > 0 && direction.x.abs() < direction.y.abs();
    final bool isLeft =
        direction.x < 0 && direction.y.abs() < direction.x.abs();
    final bool isRight =
        direction.x > 0 && direction.y.abs() < direction.x.abs();

    final bool animateUp = isUp && animation != animationUp;
    final bool animateDown = isDown && animation != animationDown;
    final bool animateLeft = isLeft && animation != animationLeft;
    final bool animateRight = isRight && animation != animationRight;

    if (animateUp) {
      animation = animationUp;
    } else if (animateDown) {
      animation = animationDown;
    } else if (animateLeft) {
      animation = animationLeft;
    } else if (animateRight) {
      animation = animationRight;
    }
  }
}
