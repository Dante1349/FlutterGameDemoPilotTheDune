import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pilot_the_dune/alien.dart';
import 'package:pilot_the_dune/enemies/ant.dart';
import 'package:pilot_the_dune/items/laser_gun.dart';
import 'package:pilot_the_dune/items/moon_berry.dart';
import 'package:pilot_the_dune/player.dart';
import 'package:pilot_the_dune/ui/user_interface.dart';
import 'package:pilot_the_dune/wall.dart';

class Level extends Component with HasGameRef {
  final String mapPath;
  final UserInterface userInterface;

  bool gameOver = false;
  List<Component> items = [];

  late TiledComponent mapComponent;
  late Player player;

  Level(this.mapPath, this.userInterface);

  load() async {
    print(mapPath);
    mapComponent = await TiledComponent.load(mapPath, Vector2(32, 32));

    gameRef.world.add(mapComponent);
    gameRef.add(userInterface);

    spawn(mapComponent.tileMap);
    spawnWalls(mapComponent.tileMap);

    gameRef.camera.viewfinder.anchor = Anchor.center;
    gameRef.camera.viewfinder.zoom = 2;
  }

  @override
  update(double dt) async {
    super.update(dt);
    await player.loaded;
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

  void spawnWalls(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("layer_walls");
    for (TiledObject tile in objectGroup!.objects) {
      var position = Vector2(tile.x, tile.y);
      var size = Vector2(tile.width, tile.height);
      gameRef.world.add(Wall(position, size));
    }
  }

  void spawn(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("layer_spawns");
    items = [];
    for (TiledObject tile in objectGroup!.objects) {
      var position = Vector2(tile.x, tile.y);
      switch (tile.name) {
        case 'player':
          player = Player(userInterface.screenInput.joystick, position);
          gameRef.world.add(player);
          gameRef.camera.follow(player);
          break;
        case 'alien':
          items.add(Alien(position));
          break;
        case 'ant': 
          items.add(Ant(position));
          break;
        case 'laser_gun':
          items.add(LaserGun(position));
          break;
        case 'moon_berry':
          items.add(MoonBerry(position));
          break;
        default:
          break;
      }
    }
    gameRef.world.addAll(items);
  }
}
