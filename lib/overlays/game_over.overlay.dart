import 'package:flutter/material.dart';
import 'package:pilot_the_dune/main.dart';

class GameOverOverlay extends StatelessWidget {
  late PilotTheDuneGame _game;

  GameOverOverlay(PilotTheDuneGame game) {
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => {
              print('Restart'),
              _game.overlays.remove('GameOver'),
              _game.restartGame(),
            },
            child: const Text('Restart'),
          ),
        ],
      )
      ),
    );
  }
}
