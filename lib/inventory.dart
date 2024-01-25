import 'package:tile_map/item.dart';

class Inventory {


  Inventory(){}

  List<Item> items = [];

  void addItem(Item item) {
    items.add(item);
  }

  void removeItem(Item item) {
    items.remove(item);
  }

  List<Item> getItems() {
    return items;
  }

  bool hasItem<T>() {
    return items.any((item) => item is T);
  }
}