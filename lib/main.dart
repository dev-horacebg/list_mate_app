import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:list_mate/data.dart';
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
                      child: ItemColumn(Dir.L),
                    ),
                    Expanded(
                      flex: 1,
                      child: ItemColumn(Dir.R),
                    ),
                  ],
                ),
                ScopedModelDescendant<ListModel>(builder: (_, c, m) {
                  var count = m.count();
                  return Draggable(
                      onDragEnd: (end) {
                        m.reset();
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

  @override build(ctx) => Expanded(
      flex: 1,
      child: Container(
          child: Center(child: ScopedModelDescendant<ListModel>(
            builder: (_, c, m) {
              return DragTarget(
                builder: (cx, ac, re) {
                  return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(i.name,
                          style: Theme.of(cx).textTheme.headline.copyWith(
                              color: ac.isEmpty
                                  ? Colors.black
                                  : Colors.white)));
                },
                onWillAccept: (data) {
                  m.update(i, dir);
                  HapticFeedback.mediumImpact();
                  return true;
                },
                onAccept: (data) {
                  m.addToList();
                }
              );
            }
          )),
          color: Color(i.colour)));
}

enum Dir{L,R}

class ItemColumn extends StatelessWidget {
  final Dir d;
  ItemColumn(this.d);
  @override build(ctx) => ScopedModelDescendant<ListModel>(builder: (_, c, m) {
        var items = m.get(d);
        return Column(
            children: List.generate(items.length, (i) {
          return ItemWgt(items[i], d);
        }));
      });
}

class ListModel extends Model {
  var defLeft, defRight, currentOrder, left, right, currentDir, level, order = [];
  var itemsOrdered = LinkedHashMap();

  void init(menu) {
    left = defLeft = [menu.items[0], menu.items[1]];
    right = defRight = [menu.items[2], menu.items[3]];
  }

  void update(selected, dir) {
    order.add(selected.name);
    var items = selected.items;
    if (items != null) {
      if (dir == Dir.L) {
        right = items;
      } else {
        left = items;
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

  addToList() {
    var cat = order[0];
    var list = order.sublist(1, order.length).join(", ");
    if (itemsOrdered.isNotEmpty && itemsOrdered[cat] != null) {
      itemsOrdered[cat].add(list);
    } else {
      itemsOrdered[cat] = [list];
    }
    order = [];
    print(itemsOrdered);
  }

  count() {
    var c = 0;
    itemsOrdered.forEach((_, l) {
      c += l.length;
    });
    return c;
  }
}
