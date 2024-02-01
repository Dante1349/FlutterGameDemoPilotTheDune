
import 'package:flame/components.dart';
import 'package:logging/logging.dart';
import 'package:pilot_the_dune/enemies/enemy.dart';
import 'package:pilot_the_dune/items/projectiles/bullet_basic.dart';
import 'package:pilot_the_dune/player.dart';

class Ant extends Enemy {
  final logger = Logger('ant.dart');

  Ant(Vector2 startPosition)
      : super(
          startPosition,
          'ant-spritesheet.png',
          Vector2.all(32.0),
          Vector2.all(16.0),
        );

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is BasicBullet) {
      gameRef.world.remove(this);
    } else if (other is Player) {
      return;
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
