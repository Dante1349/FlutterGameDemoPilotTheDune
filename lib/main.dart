import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

void main() {
   runApp(
    GameWidget(game: TiledGame()),
  );
}

class TiledGame extends FlameGame with ScaleDetector, TapDetector, KeyboardEvents {
  late TiledComponent mapComponent;

  static const double _minZoom = 0.5;
  static const double _maxZoom = 2.0;
  double _startZoom = _minZoom;

  late SpriteAnimationComponent player;
  final log = Logger('MyClassName');

  @override
  Future<void> onLoad() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    camera.viewfinder
      ..zoom = _startZoom
      ..anchor = Anchor.topLeft;

    mapComponent = await TiledComponent.load(
      'testmap_ortho.tmx',
      Vector2(32, 32),
    );
    world.add(mapComponent);

    // Load player sprite sheet
    final playerSpriteSheet = await Flame.images.load('player_sprite.png');
    final playerSpriteSheetData = SpriteSheet.fromColumnsAndRows(
      image: playerSpriteSheet,
      columns: 9, // Number of columns in the sprite sheet
      rows: 5,    // Number of rows in the sprite sheet
    );


    final playerAnimation = playerSpriteSheetData.createAnimation(
      stepTime: 0.1, // Adjust animation speed
      row: 0,
      from: 0,
      to: 2,         // Number of frames minus 1
    );

    // Create and add the player animation to the game
    player = SpriteAnimationComponent(
      animation: playerAnimation,
      size: Vector2(32,32),
    );
    player.x = 100;
    player.y = 100;
    world.add(player);

  }

  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keys) {
    // Example: Move the player based on key events
    if (event is RawKeyDownEvent) {
      if (keys.contains(LogicalKeyboardKey.arrowLeft)) {
        player.x -= player.width;
      } else if (keys.contains(LogicalKeyboardKey.arrowRight)) {
        player.x += player.width;
      } else if (keys.contains(LogicalKeyboardKey.arrowUp)) {
        player.y -= player.height;
      } else if (keys.contains(LogicalKeyboardKey.arrowDown)) {
        player.y += player.height;
      }
    }

    // Return KeyEventResult.handled to indicate that the event has been handled
    return KeyEventResult.handled;
  }

  @override
  void update(double dt) {
    super.update(dt);

    log.info("udpate");

    // Update logic, collision detection, etc
  }

  @override
  void onScaleStart(ScaleStartInfo info) {
    _startZoom = camera.viewfinder.zoom;
  }

  void _processDrag(ScaleUpdateInfo info) {
    final delta = info.delta.global;
    final zoomDragFactor = 1.0 / _startZoom;
    final currentPosition = camera.viewfinder.position;

    camera.viewfinder.position = currentPosition.translated(
      -delta.x * zoomDragFactor,
      -delta.y * zoomDragFactor,
    );
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;

    if (currentScale.isIdentity()) {
      _processDrag(info);
    } else {
      _processScale(info, currentScale);
    }
  }

  void _processScale(ScaleUpdateInfo info, Vector2 currentScale) {
    final newZoom = _startZoom * ((currentScale.y + currentScale.x) / 2.0);
    camera.viewfinder.zoom = newZoom.clamp(_minZoom, _maxZoom);
  }

  @override
  void onScaleEnd(ScaleEndInfo info) {
    _checkScaleBorders();
    _checkDragBorders();
  }

  void _checkScaleBorders() {
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(_minZoom, _maxZoom);
  }

  void _checkDragBorders() {
    final worldRect = camera.visibleWorldRect;

    final currentPosition = camera.viewfinder.position;

    final mapSize = Offset(mapComponent.width, mapComponent.height);

    var xTranslate = 0.0;
    var yTranslate = 0.0;

    if (worldRect.topLeft.dx < 0.0) {
      xTranslate = -worldRect.topLeft.dx;
    } else if (worldRect.bottomRight.dx > mapSize.dx) {
      xTranslate = mapSize.dx - worldRect.bottomRight.dx;
    }

    if (worldRect.topLeft.dy < 0.0) {
      yTranslate = -worldRect.topLeft.dy;
    } else if (worldRect.bottomRight.dy > mapSize.dy) {
      yTranslate = mapSize.dy - worldRect.bottomRight.dy;
    }

    camera.viewfinder.position = currentPosition.translated(xTranslate, yTranslate);
  }
}