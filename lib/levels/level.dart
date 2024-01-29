import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tile_map/alien.dart';
import 'package:tile_map/enemies/ant.dart';
import 'package:tile_map/items/laser_gun.dart';
import 'package:tile_map/items/moon_berry.dart';
import 'package:tile_map/player.dart';
import 'package:tile_map/ui/screen_input.dart';
import 'package:tile_map/world_object.dart';

class Level extends Component with HasGameRef {
  final String mapPath;
  final ScreenInput screenInput;
  late TiledComponent mapComponent;
  late Player player;

  List<Component> items = List.empty();

  Level(this.mapPath, this.screenInput);

  @override
  Future<FutureOr<void>> onLoad() async {
    mapComponent = await TiledComponent.load(mapPath, Vector2(32, 32));

    gameRef.world.add(mapComponent);

    gameRef.camera.viewfinder.anchor = Anchor.center;
    gameRef.camera.viewfinder.zoom = 2;
  }

  destroy() {
    gameRef.world.remove(mapComponent);
    gameRef.world.remove(player);
  }

  void spawnPlayer(RenderableTiledMap tileMap) async {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_player");
    final startTile = objectGroup!.objects.first;
    final startPosition = Vector2(startTile.x, startTile.y);

    player = Player(screenInput.joystick, startPosition);
    gameRef.world.add(player);
    gameRef.camera.follow(player);
  }

  void spawnObjects(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("objects");
    for (final tile in objectGroup!.objects) {
      gameRef.world.add(WorldObject(
          Vector2(tile.x, tile.y), Vector2(tile.width, tile.height)));
    }
  }

  void spawnNPCs(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_aliens");
    for (final tile in objectGroup!.objects) {
      gameRef.world.add(Alien(Vector2(tile.x, tile.y)));
    }
  }

  void spawnEnemies(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_ants");
    for (final tile in objectGroup!.objects) {
      gameRef.world.add(Ant(Vector2(tile.x, tile.y)));
    }
  }

  void spawnItems(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_items");
    items = List.empty();
    for (TiledObject tile in objectGroup!.objects) {
      switch (tile.name) {
        case 'laser_gun_spawn':
          items.add(LaserGun(Vector2(tile.x, tile.y)));
          break;
        case 'moon_berry_spawn':
          items.add(MoonBerry(Vector2(tile.x, tile.y)));
          break;
        default:
          break;
      }
    }
    gameRef.world.addAll(items);
  }
}
