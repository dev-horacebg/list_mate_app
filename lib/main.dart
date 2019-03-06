import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:list_mate/model_data.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(ctx) => MaterialApp(home: Home());
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(ctx) {
    return FutureBuilder(
        future: rootBundle.loadString('assets/data.json'),
        builder: (context, snp) {
          if (snp.connectionState == ConnectionState.done) {
            var model = ListModel();
            model.init(Menu.fromJson(json.decode(snp.data)));
            return ScopedModel<ListModel>(
              model: model,
              child: Scaffold(
                body: Center(
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
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
                      ScopedModelDescendant<ListModel>(
                        builder: (_, c, m) {
                          return Draggable(
                              onDragEnd: (end) {
                                m.resetLists();
                              },
                              child: FloatingActionButton(
                                  onPressed: () {},
                                  backgroundColor: Colors.deepOrange),
                              feedback: FloatingActionButton(
                                  onPressed: () {},
                                  backgroundColor: Colors.white),
                              childWhenDragging: Opacity(opacity: 0));
                        },
                      )
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container(color: Colors.blue);
          }
        });
  }
}

class ItemWgt extends StatelessWidget {
  final Item i;
  final Dir dir;
  ItemWgt(this.i, this.dir);

  @override
  Widget build(ctx) => Expanded(
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
                onAccept: (data) {},
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
  Menu menu;
  var _selected, defaultLeft, defaultRight, currentOrder, left, right, currentDir;
  var order = [];

  void init(mnu) {
    this.menu = mnu;
    left = defaultLeft = [menu.items[0], menu.items[1]];
    right = defaultRight = [menu.items[2], menu.items[3]];
  }

  void updateSelected(Item selected, dir) {
    this._selected = selected;
    if (dir == Dir.left) {
      right = selected.items;
    } else {
      left = selected.items;
    }
    notifyListeners();
  }
  List<Item> get(dir) => dir == Dir.left ? left : right;
  void resetLists() {
    left = defaultLeft;
    right = defaultRight;
    notifyListeners();
  }
}
