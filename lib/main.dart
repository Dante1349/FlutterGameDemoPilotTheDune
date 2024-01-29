import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:tile_map/levels/level.dart';
import 'package:tile_map/overlays/game_over.overlay.dart';
import 'package:tile_map/overlays/inventory.overlay.dart';
import 'package:tile_map/overlays/pause.overlay.dart';
import 'package:tile_map/ui/screen_input.dart';

void main() {
  runApp(
    GameWidget(
      game: TiledGame(),
      overlayBuilderMap: {
        'GameOver': (BuildContext context, TiledGame game) =>
            GameOverOverlay(game),
        'Pause': (BuildContext context, TiledGame game) => PauseOverlay(game),
        'Inventory': (BuildContext context, TiledGame game) =>
            InventoryOverlay(game),
      },
    ),
  );
}

class TiledGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  late TiledComponent mapComponent;

  late ScreenInput screenInput;

  late StreamSubscription<void> yButtonSubscription;

  late StreamSubscription<void> xButtonSubscription;

  late Level level;

  @override
  Future<void> onLoad() async {
    Flame.device.fullScreen();
    Flame.device.setLandscape();

    // super.debugMode=true;

    screenInput = ScreenInput();
    add(screenInput);
    await screenInput.load();

    level = Level('testmap_ortho.tmx', screenInput);
    add(level);
    await level.load();

    yButtonSubscription = screenInput.yButton.listen((event) {
      print("yButton pressed");
      level.player.shoot();
    });

    xButtonSubscription = screenInput.xButton.listen((event) {
      print("xButton pressed");
    });
  }

  restartGame() async {
    yButtonSubscription.cancel();
    xButtonSubscription.cancel();
    level.destroy();
    
    super.onDetach();
    await onLoad();
  }

  resume() {
    resumeEngine();
  }

  getLevel() {
    return level;
  }
}
