import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:tile_map/levels/level.dart';
import 'package:tile_map/levels/test-level.dart';
import 'package:tile_map/overlays/game_over.overlay.dart';
import 'package:tile_map/overlays/inventory.overlay.dart';
import 'package:tile_map/overlays/pause.overlay.dart';
import 'package:tile_map/ui/screen_input.dart';
import 'package:tile_map/ui/user_interface.dart';

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
  late UserInterface userInterface;
  late Level level;

  @override
  Future<void> onLoad() async {
    Flame.device.fullScreen();
    Flame.device.setLandscape();

    // super.debugMode=true;

    userInterface = UserInterface();
    add(userInterface);
    await userInterface.load();

    level = TestLevel(userInterface);
    add(level);
    await level.load();
  }

  restartGame() async {
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
