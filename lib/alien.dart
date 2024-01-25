import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:logging/logging.dart';
import 'package:tile_map/bullet.dart';

class Alien extends SpriteAnimationComponent with HasGameRef, CollisionCallbacks {
  final logger = Logger('alien.dart');
  final String spriteSheetPath = 'alien-spritesheet.png';

  late SpriteSheet _alienSpriteSheet;
  late SpriteAnimation alienAnimationIdle;
  late SpriteAnimation alienAnimationUp;
  late SpriteAnimation alienAnimationRight;
  late SpriteAnimation alienAnimationDown;
  late SpriteAnimation alienAnimationLeft;

  bool movingToX = true;
  bool movingToY = true;

  Alien(Vector2 startPosition)
      : super(
            size: Vector2.all(32.0),
            anchor: Anchor.topLeft,
            position: startPosition);

  @override
  Future<void> onLoad() async {
    final image = await game.images.load(spriteSheetPath);
    _alienSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 4,
      rows: 4,
    );

    alienAnimationUp = _alienSpriteSheet.createAnimation(
      stepTime: .1,
      row: 0,
      from: 1,
      to: 4,
    );
    alienAnimationRight = _alienSpriteSheet.createAnimation(
      stepTime: .1,
      row: 1,
      from: 1,
      to: 4,
    );
    alienAnimationDown = _alienSpriteSheet.createAnimation(
      stepTime: .1,
      row: 2,
      from: 1,
      to: 4,
    );
    alienAnimationLeft = _alienSpriteSheet.createAnimation(
      stepTime: .1,
      row: 3,
      from: 1,
      to: 4,
    );

    animation = alienAnimationDown;

    add(RectangleHitbox(
        size: Vector2(16, 16),
        position: Vector2(16, 16),
        anchor: Anchor.center));
  }

  @override
  void update(double dt) {
    if (false) {
      if (movingToX) {
        x += 1;
        animation = alienAnimationRight;
      } else {
        x -= 1;
        animation = alienAnimationLeft;
      }
    } else {
      if (movingToY) {
        y += 1;
        animation = alienAnimationDown;
      } else {
        y -= 1;
        animation = alienAnimationUp;
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
