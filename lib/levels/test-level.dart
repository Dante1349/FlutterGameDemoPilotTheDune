import 'package:tile_map/levels/level.dart';
import 'package:tile_map/ui/screen_input.dart';

class TestLevel extends Level {
  TestLevel(screenInput) : super('testmap_ortho.tmx', screenInput);
}