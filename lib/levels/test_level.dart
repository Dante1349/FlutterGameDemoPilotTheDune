import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pilot_the_dune/connection.dart';
import 'package:pilot_the_dune/levels/level.dart';

class TestLevel extends Level {
  TestLevel(screenInput) : super('testmap_ortho.tmx', screenInput);

  @override
  void spawn(RenderableTiledMap tileMap) {
    super.spawn(tileMap);
    final objectGroup = tileMap.getLayer<ObjectGroup>("layer_connections");
    items = [];
    for (TiledObject tile in objectGroup!.objects) {
      var position = Vector2(tile.x, tile.y);
      var size = Vector2(tile.width, tile.height);
      switch (tile.name) {
        case 'exit_north':
          items.add(Connection(position, size, 'alien_cave_1.tmx'));
          break;
          
        default:
          break;
      }
    }
    gameRef.world.addAll(items);
  }
}