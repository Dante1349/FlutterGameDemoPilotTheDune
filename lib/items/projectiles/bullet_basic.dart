import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:tile_map/wall.dart';

class BasicBullet extends SpriteComponent with HasGameRef, CollisionCallbacks {
  final double maxSpeed = 300.0;

  late Vector2 _direction;

  BasicBullet(Vector2 position, Vector2 direction)
      : super(position: position, size: Vector2(5, 5), anchor: Anchor.topLeft) {
    add(RectangleHitbox(size: Vector2(5, 5), position: Vector2(0, 0)));
    _direction = direction;
  }

  @override
  void update(double dt) {
    position.add(_direction * maxSpeed * dt);

    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('bullet_basic.png');
    sprite = Sprite(image, srcPosition: Vector2(0, 0), srcSize: Vector2(5, 5));
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Wall) {
      gameRef.world.remove(this);
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
}
