import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

class JoystickPlayer extends SpriteAnimationComponent
    with HasGameRef, CollisionCallbacks {
  /// Pixels/s
  double maxSpeed = 150.0;
  late final Vector2 _lastSize = size.clone();
  late final Transform2D _lastTransform = transform.clone();
  late final Vector2 _lastPosition = position.clone();
  late final SpriteSheet _playerSpriteSheet;

  late SpriteAnimation playerAnimationIdle;
  late SpriteAnimation playerAnimationUp;
  late SpriteAnimation playerAnimationLeft;
  late SpriteAnimation playerAnimationRight;
  late SpriteAnimation playerAnimationDown;

  final JoystickComponent joystick;

  JoystickPlayer(this.joystick)
      : super(size: Vector2.all(32.0), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {

    final image = await game.images.load('pilot-Sheet.png');
    _playerSpriteSheet = SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 16,
      rows: 1,
    );

    playerAnimationIdle = _playerSpriteSheet.createAnimation(
      stepTime: 0.1,
      row: 0,
      from: 0,
      to: 1,
    );
    playerAnimationUp = _playerSpriteSheet.createAnimation(
      stepTime: 0.1,
      row: 0,
      from: 1,
      to: 4,
    );
    playerAnimationLeft = _playerSpriteSheet.createAnimation(
      stepTime: 0.1,
      row: 0,
      from: 9,
      to: 12,
    );
    playerAnimationRight = _playerSpriteSheet.createAnimation(
      stepTime: 0.1,
      row: 0,
      from: 5,
      to: 8,
    );
    playerAnimationDown = _playerSpriteSheet.createAnimation(
      stepTime: 0.1,
      row: 0,
      from: 13,
      to: 16,
    );

    animation = playerAnimationIdle;

    add(RectangleHitbox(size: Vector2(16,16), position: Vector2(16,16), anchor: Anchor.center));
    position = Vector2(game.camera.visibleWorldRect.width/2, game.camera.visibleWorldRect.height/2+400);
  }

  @override
  void update(double dt) {
    if (!joystick.delta.isZero() && activeCollisions.isEmpty) {
      _lastSize.setFrom(size);
      _lastTransform.setFrom(transform);
      _lastPosition.setFrom(position);
      position.add(joystick.relativeDelta * maxSpeed * dt);

      if(joystick.isDragged && joystick.direction == JoystickDirection.up) {
        animation = playerAnimationUp;
      } else if (joystick.isDragged && joystick.direction == JoystickDirection.upLeft) {
        animation = playerAnimationLeft;
      } else if (joystick.isDragged && joystick.direction == JoystickDirection.upRight) {
        animation = playerAnimationRight;
      } else if (joystick.isDragged && joystick.direction == JoystickDirection.right) {
        animation = playerAnimationRight;
      } else if (joystick.isDragged && joystick.direction == JoystickDirection.down) {
        animation = playerAnimationDown;
      } else if (joystick.isDragged && joystick.direction == JoystickDirection.downLeft) {
        animation = playerAnimationLeft;
      } else if (joystick.isDragged && joystick.direction == JoystickDirection.downRight) {
        animation = playerAnimationRight;
      } else if (joystick.isDragged && joystick.direction == JoystickDirection.left) {
        animation = playerAnimationLeft;
      } else {
        animation = playerAnimationIdle;
      }
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    position.setFrom(_lastPosition);
  }
}