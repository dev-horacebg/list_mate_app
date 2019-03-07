import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_mate/data.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  build(ctx) => MaterialApp(home: Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  build(ctx) => FutureBuilder(
      future: rootBundle.loadString('assets/data.json'),
      builder: (context, snp) {
        if (snp.connectionState == ConnectionState.done) {
          var model = ListModel();
          model.init(Menu.fromJson(json.decode(snp.data)));
          return ScopedModel<ListModel>(
              model: model,
              child: Scaffold(
                  body:
                      Stack(alignment: AlignmentDirectional.center, children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ItemColumn(Dir.left),
                    ),
                    Expanded(
                      flex: 1,
                      child: ItemColumn(Dir.right),
                    ),
                  ],
                ),
                ScopedModelDescendant<ListModel>(builder: (_, c, m) {
                  var count = m.count();
                  return Draggable(
                      onDragEnd: (end) {
                        m.resetLists();
                      },
                      child: FloatingActionButton(
                          child: count == 0 ? null : Text('$count'),
                          onPressed: () {},
                          backgroundColor: Colors.deepOrange),
                      feedback: FloatingActionButton(
                          onPressed: () {}, backgroundColor: Colors.white),
                      childWhenDragging: Opacity(opacity: 0));
                })
              ])));
        } else {
          return Container(color: Colors.blue);
        }
      });
}

class ItemWgt extends StatelessWidget {
  final Item i;
  final Dir dir;

  ItemWgt(this.i, this.dir);

  @override
  build(ctx) => Expanded(
      flex: 1,
      child: Container(
          child: Center(child: ScopedModelDescendant<ListModel>(
            builder: (_, c, m) {
              return DragTarget(
                builder: (cx, accepted, rejected) {
                  return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(i.name,
                          style: Theme.of(cx).textTheme.headline.copyWith(
                              color: accepted.isEmpty
                                  ? Colors.black
                                  : Colors.white)));
                },
                onWillAccept: (data) {
                  m.updateSelected(i, dir);
                  HapticFeedback.mediumImpact();
                  return true;
                },
                onAccept: (data) {
                  m.addToList();
                },
              );
            },
          )),
          color: Color(i.colour)));
}

enum Dir { left, right }

class ItemColumn extends StatelessWidget {
  final Dir d;

  ItemColumn(this.d);

  @override
  Widget build(ctx) => ScopedModelDescendant<ListModel>(builder: (_, c, m) {
        var items = m.get(d);
        return Column(
            children: List.generate(items.length, (i) {
          return ItemWgt(items[i], d);
        }));
      });
}

class ListModel extends Model {
  var defaultLeft,
      defaultRight,
      currentOrder,
      left,
      right,
      currentDir,
      level,
      order = [];
  var itemsOrdered = LinkedHashMap<String, List>();
  var categories = LinkedHashSet();

  void init(menu) {
    left = defaultLeft = [menu.items[0], menu.items[1]];
    right = defaultRight = [menu.items[2], menu.items[3]];
  }

  void updateSelected(selected, dir) {
    order.add(selected.name);
    var items = selected.items;
    if (items != null) {
      if (dir == Dir.left) {
        right = items;
      } else {
        left = items;
      }
    } else {
      // TODO: Show release to add message!
    }
    notifyListeners();
  }

  List get(dir) => dir == Dir.left ? left : right;

  void resetLists() {
    left = defaultLeft;
    right = defaultRight;
    notifyListeners();
  }

  void addToList() {
    var category = order[0];
    if (itemsOrdered.isNotEmpty && itemsOrdered[category] != null) {
      List itemsOrdered2 = itemsOrdered[category];
      itemsOrdered2.add(order.sublist(1, order.length).join(", "));
      itemsOrdered[category] = itemsOrdered2;
    } else {
      itemsOrdered[category] = [order.sublist(1, order.length).join(", ")];
    }
    order = [];
    print(itemsOrdered);
  }

  count() {
    var count = 0;
    itemsOrdered.forEach((_, list) {
      count += list.length;
    });
    return count;
  }
}
