import 'package:flame/components.dart';
import 'package:pilot_the_dune/items/item.dart';

class LaserGun extends Item {
  LaserGun(Vector2 position) : super(position, 'laser-gun.png', 1, 1);

  @override
  Future<void> onLoad() async {
    final image = await game.images.load(spritePath);
    sprite =
        Sprite(image, srcPosition: Vector2.zero(), srcSize: Vector2(32, 32));
  }
}
