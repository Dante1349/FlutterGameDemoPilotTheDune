import 'package:flutter/material.dart';
import 'package:tile_map/main.dart';

class PauseOverlay extends StatelessWidget {
  late TiledGame _game;

  PauseOverlay(TiledGame game) {
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
            'Pause',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => {
              _game.overlays.remove('Pause'),
              _game.resume()
            },
            child: Text('Resume'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => {
              _game.overlays.remove('Pause'),
              _game.restartGame(),
              _game.resume()
            },
            child: Text('Restart'),
          ),
        ],
      )
      ),
    );
  }
}
