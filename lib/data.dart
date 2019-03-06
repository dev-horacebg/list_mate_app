class Menu {
  List<Item> items;
  Menu.fromJson(json) {
    if (json['items'] != null) {
      items = new List<Item>();
      json['items'].forEach((v) {
        items.add(new Item.fromJson(v));
      });
    }
  }
}
class Item {
  String name; int colour; List<Item> items;

  Item.fromJson(json) {
    name = json['name'];
    colour = json['colour'] != null ? int.parse('0xFF${json['colour']}') : 0x000000;
    if (json['items'] != null) {
      items = List<Item>();
      json['items'].forEach((v) {
        items.add(Item.fromJson(v));
      });
    }
  }
}
