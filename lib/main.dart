import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      GridWid("Tea", Colors.amber),
                      GridWid("Coffee", Colors.blue)
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: <Widget>[
                      GridWid("Snacks", Colors.red),
                      GridWid("Other", Colors.teal)
                    ],
                  ),
                ),
              ],
            ),
            Draggable(
                onDragEnd: (end) {},
                child: FloatingActionButton(
                    onPressed: () {}, backgroundColor: Colors.deepOrange),
                feedback: FloatingActionButton(
                    onPressed: () {}, backgroundColor: Colors.white),
                childWhenDragging: Opacity(opacity: 0))
          ],
        ),
      ),
    );
  }
}

class GridWid extends StatelessWidget {
  final String t;
  final MaterialColor c;

  GridWid(this.t, this.c);

  @override
  Widget build(BuildContext context) => Expanded(
      flex: 1,
      child: Container(
          child: Center(
              child: DragTarget(
            builder: (context, List candidateData, List rejected) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(t, style: Theme.of(context).textTheme.headline),
              );
            },
            onWillAccept: (data) => true,
            onAccept: (data) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text('$t selected')));
              HapticFeedback.mediumImpact();
            },
          )),
          color: c));
}

class DragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;

  DragBox(this.initPos, this.itemColor);

  @override
  _DragBoxState createState() => _DragBoxState();
}

class _DragBoxState extends State<DragBox> {
  Offset position = Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    position = widget.initPos;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        data: widget.itemColor,
        child: Container(
          width: 100,
          height: 100,
          color: widget.itemColor,
        ),
        onDraggableCanceled: (velocity, offset) {
          setState(() {
            position = offset;
          });
        },
        feedback: Container(
          width: 120,
          height: 120,
          color: widget.itemColor.withOpacity(0.5),
        ),
      ),
    );
  }
}
