import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:logging/logging.dart';
import 'package:pilot_the_dune/items/projectiles/bullet_basic.dart';
import 'package:pilot_the_dune/main.dart';
import 'package:pilot_the_dune/player.dart';
import 'package:pilot_the_dune/wall.dart';

class Ant extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final logger = Logger('ant.dart');
  final String spriteSheetPath = 'ant-spritesheet.png';

  late SpriteSheet _antSpriteSheet;
  late SpriteAnimation antAnimationIdle;
  late SpriteAnimation antAnimationUp;
  late SpriteAnimation antAnimationRight;
  late SpriteAnimation antAnimationDown;
  late SpriteAnimation antAnimationLeft;

  static const double speed = 100.0; // Adjust the speed as needed
  static const double followRadius =
      150.0; // Radius to start following the player
  static const double changeDirectionInterval =
      2.0; // Change direction every 2 seconds

  bool isFollowingPlayer = false;
  Vector2 randomDirection = Vector2(1.0, 0.0)
    ..rotate(Random().nextInt(8) * (pi / 4.0));
  double changeDirectionTimer = 0.0;

  Ant(Vector2 startPosition)
      : super(
            size: Vector2.all(32.0),
            anchor: Anchor.topLeft,
            position: startPosition);

  @override
  Future<void> onLoad() async {
    final image = await game.images.load(spriteSheetPath);
    _antSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 16,
      rows: 1,
    );

    antAnimationUp = _antSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 1,
      to: 4,
    );
    antAnimationRight = _antSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 5,
      to: 8,
    );
    antAnimationDown = _antSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 9,
      to: 12,
    );
    antAnimationLeft = _antSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 13,
      to: 16,
    );

    animation = antAnimationRight;

    add(RectangleHitbox(
        size: Vector2(16, 16),
        position: Vector2(16, 16),
        anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Check if player is still within follow radius
    double distanceToPlayer = (gameRef as PilotTheDuneGame)
        .level
        .player
        .position
        .distanceTo(position);
    if (distanceToPlayer > followRadius) {
      // Update the timer for changing direction
      changeDirectionTimer += dt;

      // Change direction after the specified interval
      if (changeDirectionTimer >= changeDirectionInterval) {
        // Change the direction to a multiple of 45 degrees
        int randomAngleIndex = Random().nextInt(8);
        randomDirection = Vector2(1.0, 0.0)
          ..rotate(randomAngleIndex * (pi / 4.0));

        // Reset the timer
        changeDirectionTimer = 0.0;
      }
      moveRandomly(dt);
    } else {
      moveTowardsPlayer(dt);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is BasicBullet) {
      gameRef.world.remove(this);
    } else if (other is Player) {
      return;
    } else if (other is Wall) {
      randomDirection = Vector2(1.0, 0.0)
        ..rotate(Random().nextInt(8) * (pi / 4.0));
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

  void moveRandomly(double dt) {
    // Move in the current random direction
    position += randomDirection * speed * dt;

    // Update the animation based on the direction of movement
    updateAnimation(randomDirection);
  }

  void moveTowardsPlayer(double dt) {
    // Implement player-following movement logic here
    // You can use Flame's Vector2 class for movement
    var playerPosition = (gameRef as PilotTheDuneGame).level.player.position;
    Vector2 direction = playerPosition - position;
    direction.normalize();
    position += direction * speed * dt;

    // Update the animation based on the direction of movement
    updateAnimation(direction);
  }

  void updateAnimation(Vector2 direction) {
    final bool isUp = direction.y < 0 && direction.x.abs() < direction.y.abs();
      final bool isDown = direction.y > 0 && direction.x.abs() < direction.y.abs();
      final bool isLeft = direction.x < 0 && direction.y.abs() < direction.x.abs();
      final bool isRight = direction.x > 0 && direction.y.abs() < direction.x.abs();

      final bool animateUp = isUp && animation != antAnimationUp;

      final bool animateDown = isDown && animation != antAnimationDown;

      final bool animateLeft = isLeft && animation != antAnimationLeft;

      final bool animateRight = isRight && animation != antAnimationRight;

      if (animateUp) {
        animation = antAnimationUp;
      } else if (animateDown) {
        animation = antAnimationDown;
      } else if (animateLeft) {
        animation = antAnimationLeft;
      } else if (animateRight) {
        animation = antAnimationRight;
      }
  }

  void startFollowingPlayer(Vector2 playerPosition) {
    isFollowingPlayer = true;
  }

  void stopFollowingPlayer() {
    isFollowingPlayer = false;
  }
}
