import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:tile_map/alien.dart';
import 'package:tile_map/ant.dart';
import 'package:tile_map/game_over.overlay.dart';
import 'package:tile_map/laser_gun.dart';
import 'package:tile_map/pause.overlay.dart';
import 'package:tile_map/world_object.dart';

import 'item.dart';
import 'life_bar.dart';
import 'player.dart';

void main() {
  runApp(
    GameWidget(
      game: TiledGame(),
      overlayBuilderMap: {
        'GameOver': (BuildContext context, TiledGame game) =>
            GameOverOverlay(game),
        'Pause': (BuildContext context, TiledGame game) => PauseOverlay(game),
      },
    ),
  );
}

class TiledGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  late TiledComponent mapComponent;

  final double _startZoom = 0.5;

  final logger = Logger('main.dart');

  late JoystickComponent _joystick;
  late JoystickPlayer _player;
  late LifeBar _lifeBar;

  final List<Item> _items = [];

  @override
  Future<void> onLoad() async {
    Flame.device.fullScreen();
    Flame.device.setLandscape();

    //super.debugMode=true;

    camera.viewfinder
      ..zoom = _startZoom
      ..anchor = Anchor.topLeft;

    mapComponent = await TiledComponent.load(
      'testmap_ortho.tmx',
      Vector2(32, 32),
    );

    world.add(mapComponent);

    final image = await images.load('ui.png');
    final sheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 8,
      rows: 2,
    );

    final knob = SpriteComponent(
      sprite: sheet.getSpriteById(1),
      size: Vector2(32, 32),
    );
    final background = SpriteComponent(
      sprite: sheet.getSpriteById(0),
      size: Vector2(32, 32),
    );
    final xButton = SpriteButtonComponent(
        button: sheet.getSpriteById(5),
        buttonDown: sheet.getSpriteById(13),
        onPressed: () => print("button presssed"),
        position:
            Vector2(camera.viewport.size.x - 125, camera.viewport.size.y - 150),
        size: Vector2(32, 32));
    final yButton = SpriteButtonComponent(
        button: sheet.getSpriteById(6),
        buttonDown: sheet.getSpriteById(14),
        onPressed: () => _player.shoot(),
        position:
            Vector2(camera.viewport.size.x - 225, camera.viewport.size.y - 100),
        size: Vector2(32, 32));

    final pauseButton = SpriteButtonComponent(
        button: sheet.getSpriteById(7),
        buttonDown: sheet.getSpriteById(15),
        onPressed: () => {overlays.add('Pause'), pauseEngine()},
        position: Vector2(camera.viewport.size.x - 64 - 20, 20),
        size: Vector2(32, 32));

    knob.width = knob.width * 4;
    knob.height = knob.height * 4;
    background.width = background.width * 4;
    background.height = background.height * 4;
    xButton.width = xButton.width * 2;
    xButton.height = xButton.height * 2;
    yButton.width = yButton.width * 2;
    yButton.height = yButton.height * 2;
    pauseButton.width = pauseButton.width * 2;
    pauseButton.height = pauseButton.height * 2;

    _joystick = JoystickComponent(
      knob: knob,
      background: background,
      size: 500,
      margin: EdgeInsets.only(left: 80, bottom: 20),
    );

    spawnPlayer(mapComponent.tileMap);
    spawnObjects(mapComponent.tileMap);
    spawnItems(mapComponent.tileMap);
    spawnAliens(mapComponent.tileMap);
    spawnAnts(mapComponent.tileMap);

    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.zoom = 2;

    _lifeBar = LifeBar(_player.life);
    _lifeBar.position = Vector2(10, 10);

    camera.viewport
        .addAll([_joystick, xButton, yButton, pauseButton, _lifeBar]);
  }

  // @override
  // KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keys) {
  //   // Example: Move the player based on key events
  //   if (event is RawKeyDownEvent) {
  //     if (keys.contains(LogicalKeyboardKey.arrowLeft)) {
  //       player.animation = playerAnimationLeft;
  //       player.x -= 8;
  //     } else if (keys.contains(LogicalKeyboardKey.arrowRight)) {
  //       player.animation = playerAnimationRight;
  //       player.x += 8;
  //     } else if (keys.contains(LogicalKeyboardKey.arrowUp)) {
  //       player.animation = playerAnimationUp;
  //       player.y -= 8;
  //     } else if (keys.contains(LogicalKeyboardKey.arrowDown)) {
  //       player.animation = playerAnimationDown;
  //       player.y += 8;
  //     } else {
  //       player.animation = playerAnimationIdle;
  //     }
  //   }

  //   // Return KeyEventResult.handled to indicate that the event has been handled
  //   return KeyEventResult.handled;
  // }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeBar.percentage = _player.life;
    if (_player.life <= 0) {
      overlays.add('GameOver');
    }
  }

  void spawnPlayer(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_player");
    final startTile = objectGroup!.objects.first;
    final startPosition = Vector2(startTile.x, startTile.y);
    _player = JoystickPlayer(_joystick, startPosition);
    world.add(_player);
    camera.follow(_player);
  }

  void spawnItems(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_items");
    final startTile = objectGroup!.objects.first;
    final startPosition = Vector2(startTile.x, startTile.y);
    //_items.add(LaserGun(startPosition));
    world.add(LaserGun(startPosition));
  }

  void spawnAnts(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_ants");
    for (final tile in objectGroup!.objects) {
      world.add(Ant(Vector2(tile.x, tile.y)));
    }
  }

  void spawnAliens(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("spawn_aliens");
    print(objectGroup.toString());
    for (final tile in objectGroup!.objects) {
      world.add(Alien(Vector2(tile.x, tile.y)));
    }
  }

  void spawnObjects(RenderableTiledMap tileMap) {
    final objectGroup = tileMap.getLayer<ObjectGroup>("objects");
    for (final tile in objectGroup!.objects) {
      add(WorldObject(
          Vector2(tile.x, tile.y), Vector2(tile.width, tile.height)));
    }
  }

  restartGame() async {
    await onLoad();
  }

  resume() {
    resumeEngine();
  }
}
