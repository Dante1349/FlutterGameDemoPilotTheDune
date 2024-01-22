import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Bullet extends SpriteComponent with HasGameRef {
  final double maxSpeed = 300.0;

  late Vector2 _direction;

  Bullet(Vector2 position, Vector2 direction)
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
}
