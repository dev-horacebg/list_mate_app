class Menu {
  var items;
  Menu.from(json) {
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) => items.add(Item.from(v)));
    }
  }
}
class Item {
  var name, items; int colour, depth;
  Item.from(json) {
    name = json['name'];
    colour = int.parse('${json['colour']}');
    depth = json['depth'];
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) => items.add(Item.from(v)));
    }
  }
}
