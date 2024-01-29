import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:tile_map/alien.dart';
import 'package:tile_map/enemies/ant.dart';
import 'package:tile_map/items/item.dart';
import 'package:tile_map/items/laser_gun.dart';
import 'package:tile_map/items/moon_berry.dart';
import 'package:tile_map/player.dart';
import 'package:tile_map/ui/screen_input.dart';
import 'package:tile_map/ui/user_interface.dart';
import 'package:tile_map/world_object.dart';

class Level extends Component with HasGameRef {
  final String mapPath;
  final UserInterface userInterface;

  bool gameOver = false;
  List<Item> items = [];

  late TiledComponent mapComponent;
  late Player player;

  Level(this.mapPath, this.userInterface);

  load() async {
    print(mapPath);
    mapComponent = await TiledComponent.load(mapPath, Vector2(32, 32));

    gameRef.world.add(mapComponent);
    gameRef.add(userInterface);

    spawnObjects(mapComponent.tileMap);
    spawnPlayer(mapComponent.tileMap);
    spawnNPCs(mapComponent.tileMap);
    spawnItems(mapComponent.tileMap);
    spawnEnemies(mapComponent.tileMap);

    gameRef.camera.viewfinder.anchor = Anchor.center;
    gameRef.camera.viewfinder.zoom = 2;
  }

  @override
  update(double dt) {
    super.update(dt);
    userInterface.lifeBar.percentage = player.life;
    if (player.life <= 0 && !gameOver) {
      gameOver = true;
      gameRef.overlays.add('GameOver');
    }
  }

  destroy() {
    for (var element in gameRef.world.children) {
      gameRef.world.remove(element);
    }
  }

  void spawnPlayer(RenderableTiledMap tileMap) async {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_player");
    final startTile = objectGroup!.objects.first;
    final startPosition = Vector2(startTile.x, startTile.y);

    player = Player(userInterface.screenInput.joystick, startPosition);
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
    items = [];
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
