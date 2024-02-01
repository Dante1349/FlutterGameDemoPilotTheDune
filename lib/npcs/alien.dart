import 'package:flame/components.dart';
import 'package:logging/logging.dart';
import 'package:pilot_the_dune/npcs/npc.dart';

class Alien extends NPC {
  final logger = Logger('alien.dart');

  Alien(Vector2 startPosition)
      : super(
          startPosition,
          'alien-spritesheet.png',
          Vector2.all(32.0),
          Vector2.all(16.0),
        );
}
