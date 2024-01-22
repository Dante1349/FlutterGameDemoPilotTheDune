import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Bullet extends SpriteComponent with HasGameRef {
  final double maxSpeed = 10.0;
  
  late Vector2 _direction;


  Bullet(Vector2 position, Vector2 direction): super(position: position, size: Vector2(8,8), anchor: Anchor.topLeft){
    add(RectangleHitbox(size: Vector2(8,8), position: Vector2(0,0)));
    _direction = direction;
    angle = direction.angleTo(position);
  }
  // @override
  // void render(Canvas canvas) {
  //   canvas.drawRect(toRect(), paint);
  // }

  @override
  void update(double dt) {
    // TODO: implement update

    position.add(_direction * maxSpeed * dt);
    
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    //paint.color = Colors.red;
    final image = await game.images.load('bullet_basic.png');
    sprite = Sprite(image, srcPosition: Vector2(0,0), srcSize: Vector2(8,8));

    print("xxxx:"+position.x.toString());
    print("yyyy:"+position.y.toString());
  }
}