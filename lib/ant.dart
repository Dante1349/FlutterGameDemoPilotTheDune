import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:logging/logging.dart';
import 'package:tile_map/bullet.dart';
import 'package:tile_map/player.dart';

class Ant extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final logger = Logger('ant.dart');
  final String spriteSheetPath = 'ant-spritesheet.png';

  late SpriteSheet _antSpriteSheet;
  late SpriteAnimation antAnimationIdle;
  late SpriteAnimation antAnimationUp;
  late SpriteAnimation antAnimationRight;
  late SpriteAnimation antAnimationDown;
  late SpriteAnimation antAnimationLeft;

  bool movingToX = true;
  bool movingToY = true;

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
    if (true) {
      if (movingToX) {
        x += 1;
        animation = antAnimationRight;
      } else {
        x -= 1;
        animation = antAnimationLeft;
      }
    } else {
      if (movingToY) {
        y += 1;
        animation = antAnimationDown;
      } else {
        y -= 1;
        animation = antAnimationUp;
      }
    }

    super.update(dt);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Bullet) {
      gameRef.world.remove(this);
    } else if (other is JoystickPlayer) {
      return;
    }

    movingToX = !movingToX;
    movingToY = !movingToY;
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
}
