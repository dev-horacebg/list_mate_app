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
          model.init(Menu.from(json.decode(snp.data)));
          return ScopedModel<ListModel>(
              model: model,
              child: Scaffold(
                  body:
                      Stack(alignment: AlignmentDirectional.center, children: [
                Row(
                  children: [
                    ItemColumn(Dir.L),
                    ItemColumn(Dir.R),
                  ],
                ),
                ScopedModelDescendant<ListModel>(builder: (_, c, m) {
                  var count = m.count();
                  return Draggable(
                      onDragEnd: (end) {
                        m.reset();
                      },
//                      data: m.lastSelected,
                      child: FloatingActionButton(
                          child: count == 0 ? null : Text('$count'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => OrderW(m.itemsOrdered)),
                          );
                        },),
                      feedback: FloatingActionButton(
                          onPressed: () {}),
                      childWhenDragging: Opacity(opacity: 0));
                })
              ])));
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
      child: Container(
          child: Center(child: ScopedModelDescendant<ListModel>(
            builder: (_, c, m) {
              return DragTarget(
                builder: (ctx, ac, re) {
                  return Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(i.name,
                          style: Theme.of(ctx).textTheme.headline.copyWith(
                              color: ac.isEmpty
                                  ? Colors.black
                                  : Colors.white)));
                },
                onWillAccept: (data) {
                    m.update(i, dir);
                    HapticFeedback.mediumImpact();
                    print("Selected ${i.name}");
                  return true;
                },
                onAccept: (data) {
                  m.accept();
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
        return Expanded(
          flex: 1,
          child: Column(
              children: List.generate(items.length, (i) {
            return ItemWgt(items[i], d);
          })),
        );
      });
}

class ListModel extends Model {
  var defLeft, defRight, left, right, lastSelected, currentFloor = 0, order = [];
  var itemsOrdered = LinkedHashMap();

  init(menu) {
    left = defLeft = [menu.items[0], menu.items[1]];
    right = defRight = [menu.items[2], menu.items[3]];
  }

  update(selected, dir) {
    if (selected != lastSelected) {
      lastSelected = selected;
      order.add(selected.name);
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
  }

  get(dir) => dir == Dir.L ? left : right;

  reset() {
    left = defLeft;
    right = defRight;
    notifyListeners();
  }

  accept() {
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
    itemsOrdered.forEach((_, l) => c += l.length);
    return c;
  }
}

class OrderW extends StatelessWidget {

  final LinkedHashMap items;

  OrderW(this.items);

  @override
  Widget build(BuildContext context) {
    var keys = items.keys.toList();
    return Scaffold(
      appBar: AppBar(title: Text('My stuff')),
      body: Column(
        children: List.generate(keys.length, (i) {
          var item = items[keys[i]];
          return Column(
            children: <Widget>[
              Container(
                child: Text(keys[i]),
              ),
              ListView(
                shrinkWrap: true,
                children: List.generate(item.length, (x) {
                  return Text(item[x]);
                }))]
          );
        }),
      ));
  }
}