import 'dart:async';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pilot_the_dune/levels/level.dart';
import 'package:pilot_the_dune/levels/test_level.dart';
import 'package:pilot_the_dune/overlays/game_over.overlay.dart';
import 'package:pilot_the_dune/overlays/inventory.overlay.dart';
import 'package:pilot_the_dune/overlays/pause.overlay.dart';
import 'package:pilot_the_dune/ui/user_interface.dart';

void main() {
  runApp(
    GameWidget(
      game: PilotTheDuneGame(),
      overlayBuilderMap: {
        'GameOver': (BuildContext context, PilotTheDuneGame game) =>
            GameOverOverlay(game),
        'Pause': (BuildContext context, PilotTheDuneGame game) => PauseOverlay(game),
        'Inventory': (BuildContext context, PilotTheDuneGame game) =>
            InventoryOverlay(game),
      },
    ),
  );
}

class PilotTheDuneGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
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

  loadLevel(String targetMap) async {
    level.destroy();
    level = Level(targetMap, userInterface);
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
