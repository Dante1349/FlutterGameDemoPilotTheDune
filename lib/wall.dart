import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Wall  extends PositionComponent {

  Wall(Vector2 position, Vector2 size): super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    return super.onLoad();
  }

}