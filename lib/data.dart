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
  var name; int colour; var items;
  Item.from(json) {
    name = json['name'];
    colour = json['colour'] != null ? int.parse('0xFF${json['colour']}') : 0x000000;
    if (json['items'] != null) {
      items = [];
      json['items'].forEach((v) => items.add(Item.from(v)));
    }
  }
}
