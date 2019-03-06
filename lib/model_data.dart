class Menu {
  List<Item> items;

  Menu({this.items});

  Menu.fromJson(Map<String, dynamic> json) {
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

  Item({this.name, this.colour, this.items});

  Item.fromJson(Map<String, dynamic> json) {
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
