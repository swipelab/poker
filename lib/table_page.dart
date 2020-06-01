import 'package:flutter/material.dart';
import 'package:poker/app.dart';
import 'package:poker/game.dart';
import 'package:poker/ux/card_widget.dart';
import 'package:poker/ux/seat_widget.dart';
import 'package:scoped/scoped.dart';
import 'package:poker/util.dart';
import 'package:ux/ux.dart';

class TablePage extends StatefulWidget {
  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  Dealer game;

  initState() {
    super.initState();
    this.game = Dealer()
      ..fillSeats()
      ..start();
  }

  Widget cell(Widget child) => Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.white)),
        child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(height: 600, width: 800, child: child)),
      );

  @override
  Widget build(BuildContext context) {
    final dealer = game;

    final container = Container(
      child: dealer.views.bindValue((context, v) => GridView.count(
            crossAxisCount: 2,
            children: v.map((e) => cell(PlayerTableWidget(table: e))).toList(),
          )),
    );

    return Scaffold(
      backgroundColor: Color(0xFF003723),
      //drawer: Drawer(),
      appBar: AppBar(
        title: Text('Poker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          context.get<App>().user.bindValue(
              (context, value) => Center(child: Text(value?.email ?? ''))),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: context.get<App>().signIn,
          )
        ],
      ),
      body: container,
      floatingActionButton: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,

            children: <Widget>[
              FlatButton(
                color: Colors.red,
                child: Icon(Icons.refresh),
                onPressed: dealer.reset,
              ),
              SizedBox(width: 12),
              FlatButton(
                color: Colors.red,
                child: Icon(Icons.skip_next),
                onPressed: dealer.next,
              ),
            ],
          )),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class PlayerTableWidget extends StatelessWidget {
  final PlayerTable table;

  PlayerTableWidget({this.table});

  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 64.0),
                  child: TableWidget(progress: 0, table: table))),
          Align(
            alignment: Alignment(0, 0.95),
            child: Container(
              height: 38,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF919292),
                      Color(0xFF525252),
                      Color(0xFF323232),
                      Color(0xFF181818),
                    ],
                    stops: [0, 0.1, 0.7, 1],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(child: Text('Fold'), onPressed: () {}),
                  Container(width: 1, color: Colors.grey.shade200),
                  FlatButton(child: Text('Call'), onPressed: () {}),
                  Container(width: 1, color: Colors.grey.shade200),
                  FlatButton(child: Text('Raise'), onPressed: () {}),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FacePlaceholder extends StatelessWidget {
  final Widget child;

  FacePlaceholder({this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.yellowAccent, width: 2)),
      padding: const EdgeInsets.all(3),
      child: child ?? Container(width: 100, height: 150),
    );
  }
}

class TableWidget extends StatelessWidget {
  final PlayerTable table;

  final double cardSize;
  final double progress;

  TableWidget({this.cardSize = 24, this.progress, this.table});

  Widget buildCommonCards(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                table.round.toString(),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: table.common
                .mapi((e, i) => Padding(
                      padding: EdgeInsets.only(left: i > 2 ? 24.0 : 6.0),
                      child: CardWidget(card: e, size: 48),
                    ))
                .toList()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(64.0),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Positioned.fill(child: CustomPaint(painter: TablePainter())),
          Positioned.fill(
            child: buildCommonCards(context),
          ),
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) => TableSeater(
                  constraints: constraints,
                  children: table.seats
                      .mapi((e, i) => SeatWidget(
                            active: e.active,
                            alias: e.alias ?? '',
                            balance: e.balance?.toString(),
                            cards: e.cards,
                          ))
                      .toList()),
            ),
          ),
        ],
      ),
    );
  }
}

class TableSeater extends StatelessWidget {
  final List<Widget> children;
  final BoxConstraints constraints;

  TableSeater({this.children, this.constraints});

  Widget build(BuildContext context) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    final outerRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(width / 2, height / 2),
            width: width,
            height: height),
        Radius.circular(height / 2));
    final path = PathBezier.roundedRect(outerRect);

    return Stack(
      overflow: Overflow.visible,
      children: children.mapi((e, i) {
        final p = path.point(i.toDouble() / children.length);
        return Positioned(
          left: p.dx - 40,
          top: p.dy - 30,
          width: 110,
          height: 100,
          child: children[i],
        );
      }).toList(),
    );
  }
}

class TablePainter extends CustomPainter {
  TablePainter();

  void paintBounds(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final gap = 192;
    final radius = size.height / 2;

    final fill = Paint()
      ..color = Color(0x20000000)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final outerRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
        Radius.circular(radius));
    canvas.drawRRect(outerRect, fill);
    canvas.drawRRect(outerRect, stroke);

    final innerRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: center, width: size.width - gap, height: size.height - gap),
        Radius.circular(radius));
    canvas.drawRRect(innerRect, fill);
    canvas.drawRRect(innerRect, stroke);
  }

  void paint(Canvas canvas, Size size) {
    // paintDealerTimming(canvas, size);
    paintBounds(canvas, size);
  }

  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
