import 'dart:async';

import 'package:flame/components.dart';
import 'package:tile_map/main.dart';
import 'package:tile_map/ui/life_bar.dart';
import 'package:tile_map/ui/screen_input.dart';

class UserInterface extends Component with HasGameRef {
  final ScreenInput screenInput;
  final LifeBar lifeBar;
  
  late StreamSubscription<void> yButtonSubscription;
  late StreamSubscription<void> xButtonSubscription;
  late StreamSubscription<void> pauseButtonSubscription;
  late StreamSubscription<void> inventoryButtonSubscription;

  UserInterface() : screenInput = ScreenInput(), lifeBar = LifeBar(100);

  load() async {
    gameRef.add(screenInput);
    await screenInput.load();
    gameRef.camera.viewport.add(lifeBar);

    TiledGame ref = gameRef as TiledGame;
    
    yButtonSubscription = screenInput.yButton.listen((event) {
      print("yButton pressed");
      ref.level.player.shoot();
    });

    xButtonSubscription = screenInput.xButton.listen((event) {
      print("xButton pressed");
    });

    pauseButtonSubscription = screenInput.pauseButton.listen((event) {
      print("pauseButton pressed");
      ref.overlays.add('Pause');
    });

    inventoryButtonSubscription = screenInput.inventoryButton.listen((event) {
      print("inventoryButton pressed");
      ref.overlays.add('Inventory');
    });
  }

  destroy() {
    yButtonSubscription.cancel();
    xButtonSubscription.cancel();
    pauseButtonSubscription.cancel();
    inventoryButtonSubscription.cancel();
    gameRef.remove(screenInput);
    gameRef.remove(lifeBar);
  }
}