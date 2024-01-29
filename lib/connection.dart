import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Connection extends PositionComponent {
  String targetMap;
  Connection(Vector2 position, Vector2 size, this.targetMap)
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox()..collisionType = CollisionType.passive);
    return super.onLoad();
  }
}
