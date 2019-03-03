import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ListModel>(
      model: ListModel(),
      child: Scaffold(
        body: Center(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ItemColumn(Direction.left),
                  ),
                  Expanded(
                    flex: 1,
                    child: ItemColumn(Direction.right),
                  ),
                ],
              ),
              ScopedModelDescendant<ListModel>(
                builder: (ctx, ch, m) {
                return Draggable(
                    onDragEnd: (end) {
                      m.resetLists();
                    },
                    child: FloatingActionButton(
                        onPressed: () {}, backgroundColor: Colors.deepOrange),
                    feedback: FloatingActionButton(
                        onPressed: () {}, backgroundColor: Colors.white),
                    childWhenDragging: Opacity(opacity: 0));},
              )
            ],
          ),
        ),
      ),
    );
  }
}

class GridWid extends StatelessWidget {
  final Item item;

  GridWid(this.item);

  @override
  Widget build(BuildContext context) => Expanded(
      flex: 1,
      child: Container(
          child: Center(child: ScopedModelDescendant<ListModel>(
            builder: (ctx, ch, m) {
              return DragTarget(
                builder: (context, List accepted, List rejected) {
                  return Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(item.t,
                        style: Theme.of(context).textTheme.headline.copyWith(
                            color: accepted.isEmpty
                                ? Colors.black
                                : Colors.white)),
                  );
                },
                onWillAccept: (data) {
                  Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('${item.t} selected')));
                  m.updateSelected(item.t);
                  HapticFeedback.mediumImpact();
                  return true;
                },
                onAccept: (data) {},
              );
            },
          )),
          color: item.c));
}

enum Direction { left, right }

class ItemColumn extends StatelessWidget {
  final Direction d;

  ItemColumn(this.d);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ListModel>(builder: (ctx, ch, m) {
      List<Item> items = m.get(d);

      return Column(
        children: List<Widget>.generate(items.length, (index) {
          return GridWid(items[index]);
        }),
      );
    });
  }
}

class Item {
  final String t;
  final MaterialColor c;

  Item(this.t, this.c);
}

class ListModel extends Model {
  var _selected;

  static List<Item> defaultLeft = [Item("Coffee", Colors.blue), Item("Snacks", Colors.red)];
  static List<Item> defaultRight = [Item("Tea", Colors.amber), Item("Other", Colors.teal)];

  List<Item> left = defaultLeft;
  List<Item> right = defaultRight;

  void updateSelected(selected) {
    this._selected = selected;
    if (selected == "Tea") {
      left = [
        Item("Latte", Colors.brown),
        Item("Espresso", Colors.pink),
        Item("Mocha", Colors.yellow)
      ];
    }
    notifyListeners();
  }

  List<Item> get(Direction dir) => dir == Direction.left ? left : right;

  void resetLists() {
    left = defaultLeft;
    right = defaultRight;
    notifyListeners();
  }
}
