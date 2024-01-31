import 'package:flame/components.dart';
import 'package:pilot_the_dune/items/item.dart';

class MoonBerry extends Item {
  MoonBerry(Vector2 position) : super(position, 'moon-berry.png', 1, 0);

  @override
  Future<void> onLoad() async {
    final image = await game.images.load(spritePath);
    sprite =
        Sprite(image, srcPosition: Vector2.zero(), srcSize: Vector2(32, 32));
  }
}
