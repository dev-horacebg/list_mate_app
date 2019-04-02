import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override build(ctx) => MaterialApp(home: Home());
}

class Home extends StatefulWidget {
  @override createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override build(ctx) => FutureBuilder(
      future: rootBundle.loadString('assets/d.json'),
      builder: (cx, snp) {
        if (snp.connectionState == ConnectionState.done) {
          var model = ListModel();
          model.init(Menu.from(json.decode(snp.data)));
          return ScopedModel<ListModel>(
            model: model,
            child: Scaffold(
              body: Builder(
                builder: (context) => SafeArea(
                    child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Row(
                            children: [
                              ItemColumn(Dir.L),
                              ItemColumn(Dir.R),
                            ]
                          ),
                          ScopedModelDescendant<ListModel>(builder: (_, c, m) {
                            var count = m.count();
                            return Draggable(
                                onDragEnd: (end) => m.reset(),
                                child: FloatingActionButton(
                                  child: count == 0 ? null : Text('$count', style: TextStyle(fontSize: 20)),
                                  onPressed: () => Navigator.push(cx, MaterialPageRoute(builder: (cx) => OrderW( m.itemsOrdered)))
                                ),
                                feedback:
                                    FloatingActionButton(onPressed: () {}),
                                childWhenDragging: Opacity(opacity: 0));
                          })])))));
        } else {
          return Container();
        }
      });
}

class ItemWgt extends StatelessWidget {
  final Item i;
  final Dir dir;

  ItemWgt(this.i, this.dir);

  @override build(ctx) => Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: ScopedModelDescendant<ListModel>(builder: (_, c, m) => DragTarget(builder: (ctx, ac, re) => Card(
                  child: Center(child: Text(i.name, style: Theme.of(ctx).textTheme.headline.copyWith(color: ac.isEmpty ? Colors.black : Colors.white))),
                  color: Color(i.colour)),
            onWillAccept: (d) {
              m.update(i, dir);
              HapticFeedback.mediumImpact();
              return true;
            },
            onAccept: (d) => m.accept()
          ))));
}

enum Dir { L, R }

class ItemColumn extends StatelessWidget {
  final Dir d;
  ItemColumn(this.d);

  @override build(ctx) => ScopedModelDescendant<ListModel>(builder: (_, c, m) {
        var items = m.get(d);
        return Expanded(flex: 1, child: Column(children: List.generate(items.length, (i) => ItemWgt(items[i], d))));
      });
}

class OrderW extends StatelessWidget {
  final List items;
  OrderW(this.items);

  @override build(context) => Scaffold(
            appBar: AppBar(title: Text('List')),
            body: ListView(shrinkWrap: true, children: List.generate(items.length, (x) => ListTile(leading: Image.asset('assets/coffee.png'),title: Text(items[x])))));
}

class ListModel extends Model {
  var defLeft, defRight, left, right, itemsOrdered = [];
  var currentOrder = LinkedHashMap();

  init(menu) {
    left = defLeft = [menu.items[0], menu.items[1]];
    right = defRight = [menu.items[2], menu.items[3]];
  }

  update(selected, dir) {
    currentOrder[selected.depth] = selected.name;
    var items = selected.items;
    if (items != null) {
      if (dir == Dir.L) {
        right = items;
        left = [selected];
      } else {
        left = items;
        right = [selected];
      }
    }
    notifyListeners();
  }

  get(dir) => dir == Dir.L ? left : right;

  reset() {
    left = defLeft;
    right = defRight;
    notifyListeners();
  }

  accept() {
    if (currentOrder.isNotEmpty && currentOrder.length > 1) {
      itemsOrdered.add(currentOrder.values.toList().sublist(1, currentOrder.length).join(", "));
      currentOrder = LinkedHashMap();
      notifyListeners();
    }
  }

  count() => itemsOrdered.length;
}

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