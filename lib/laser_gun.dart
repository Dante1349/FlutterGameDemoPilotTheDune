import 'package:flame/components.dart';
import 'package:tile_map/item.dart';

class LaserGun extends Item {
  LaserGun(Vector2 position) : super(position);

  Future<void> onLoad() async {
    final image = await game.images.load('laser-gun.png');
    sprite =
        Sprite(image, srcPosition: Vector2.zero(), srcSize: Vector2(32, 32));
  }
}
