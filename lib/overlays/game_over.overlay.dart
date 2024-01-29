import 'package:flutter/material.dart';
import 'package:tile_map/main.dart';

class GameOverOverlay extends StatelessWidget {
  late TiledGame _game;

  GameOverOverlay(TiledGame game) {
    _game = game;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(0, 0, 0, 1).withOpacity(0.5),
      child: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Game Over',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => {
              print('Restart'),
              _game.overlays.remove('GameOver'),
              _game.restartGame(),
            },
            child: Text('Restart'),
          ),
        ],
      )
      ),
    );
  }
}
