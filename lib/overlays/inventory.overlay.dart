import 'package:flutter/material.dart';
import 'package:tile_map/main.dart';

class InventoryOverlay extends StatelessWidget {
  late TiledGame _game;

  InventoryOverlay(TiledGame game) {
    _game = game;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Center(
          child: Column(
            children: [
              const Text(
                'Inventory Overlay',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Table(
                children: [
                  TableRow(
                    children: 
                        _game.level.player.getInventory().items.map((item) {
                      return Image.asset("images/${item.spritePath}", width: 32, height: 32);
                    }).toList(),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => {
                  _game.overlays.remove('Inventory'),
                },
                child: const Text('Resume'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
