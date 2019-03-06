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
  String name;
  int colour;
  List<Item> items;
  Item.fromJson(json) {
    name = json['name'];
    var cl = json['colour'];
    if(cl != null) {
      colour = int.parse('0xFF${json['colour']}');
    } else {
      colour = 0x000000;
    }
    if (json['items'] != null) {
      items = new List<Item>();
      json['items'].forEach((v) {
        items.add(new Item.fromJson(v));
      });
    }
  }
}
