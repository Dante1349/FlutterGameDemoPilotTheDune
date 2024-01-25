 import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class Item extends SpriteComponent with HasGameRef {
  String spritePath;
  int amount;
  int maxAmount;
  Item(Vector2 position, this.spritePath, this.amount, this.maxAmount):super(size: Vector2(32, 32), position: position){
    add(RectangleHitbox(size: Vector2(32,32), position: Vector2(0,0)));
  }
}