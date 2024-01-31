import 'dart:async';
import 'dart:html';

import 'package:flame/components.dart';
import 'package:pilot_the_dune/main.dart';
import 'package:pilot_the_dune/ui/keyboard_input.dart';
import 'package:pilot_the_dune/ui/life_bar.dart';
import 'package:pilot_the_dune/ui/screen_input.dart';

class UserInterface extends Component with HasGameRef {
  final ScreenInput screenInput;
  final KeyboardInput keyboardInput;
  final LifeBar lifeBar;
  
  late StreamSubscription<void> yButtonSubscription;
  late StreamSubscription<void> xButtonSubscription;
  late StreamSubscription<void> pauseButtonSubscription;
  late StreamSubscription<void> inventoryButtonSubscription;
  
  late StreamSubscription<void> yButtonKeyboardSubscription;
  late StreamSubscription<void> xButtonKeyboardSubscription;
  late StreamSubscription<void> pauseButtonKeyboardSubscription;
  late StreamSubscription<void> inventoryButtonKeyboardSubscription;

  UserInterface() : screenInput = ScreenInput(), keyboardInput = KeyboardInput(), lifeBar = LifeBar(100);

  load() async {
    gameRef.add(screenInput);
    await screenInput.load();
    gameRef.add(keyboardInput);
    await keyboardInput.load();
    gameRef.camera.viewport.add(lifeBar);

    PilotTheDuneGame ref = gameRef as PilotTheDuneGame;

    // screen input
    
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

    // Keyboard

    yButtonKeyboardSubscription = keyboardInput.yButton.listen((event) {
      print("yButton pressed");
      ref.level.player.shoot();
    });

    xButtonKeyboardSubscription = keyboardInput.xButton.listen((event) {
      print("xButton pressed");
    });

    pauseButtonKeyboardSubscription = keyboardInput.pauseButton.listen((event) {
      print("pauseButton pressed");
      ref.overlays.add('Pause');
    });

    inventoryButtonKeyboardSubscription = keyboardInput.inventoryButton.listen((event) {
      print("inventoryButton pressed");
      ref.overlays.add('Inventory');
    });
  }

  destroy() {
    yButtonSubscription.cancel();
    xButtonSubscription.cancel();
    pauseButtonSubscription.cancel();
    inventoryButtonSubscription.cancel();
    yButtonKeyboardSubscription.cancel();
    xButtonKeyboardSubscription.cancel();
    pauseButtonKeyboardSubscription.cancel();
    inventoryButtonKeyboardSubscription.cancel();
    gameRef.remove(screenInput);
    gameRef.remove(lifeBar);
  }
}