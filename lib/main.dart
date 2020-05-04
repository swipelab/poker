import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poker/app.dart';
import 'package:scoped/scoped.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  final app = App();
  final store = Store()..add(app);

  await app.init();

  runApp(Scope(store: store, child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {'/': (_) => TablePage()},
    );
  }
}

Color faceColor(Face face) =>
    (face.suit == Suit.Heart || face.suit == Suit.Diamond)
        ? Colors.red
        : Colors.black;

Widget faceSuit(BuildContext context, Face face, {double size = 24}) =>
    Image.asset('assets/${face.suit.toString()}.Inner.png',
        width: size, height: size, filterQuality: FilterQuality.high);
//    Text(suitString(face.suit),
//    style: TextStyle(color: faceColor(face), fontSize: 32, height: 1));

Widget faceRank(BuildContext context, Face face, {double size = 24}) =>
    Text(rankString(face.rank),
        style: TextStyle(
            color: faceColor(face),
            fontSize: size,
            height: 1,
            fontWeight: FontWeight.bold,
            letterSpacing: -3));

class CardWidget extends StatelessWidget {
  final Face face;

  CardWidget({this.face});

  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white),
          boxShadow: [BoxShadow(blurRadius: 6, color: Colors.black26)],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Align(
                alignment: Alignment(-1, -1),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      faceRank(context, face, size: 22),
                      faceSuit(context, face, size: 22),
                    ],
                  ),
                ),
              ),
            ),
//            Positioned.fill(
//              child: Align(
//                alignment: Alignment(1, 1),
//                child: Padding(
//                  padding: const EdgeInsets.all(8),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.center,
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    children: <Widget>[
//                      faceRank(context, face, size: 22),
//                      faceSuit(context, face, size: 22),
//                    ],
//                  ),
//                ),
//              ),
//            ),
          ],
        ));
  }
}

class TablePage extends StatefulWidget {
  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final Deck deck = Deck.shuffled();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Poker'),
        actions: <Widget>[
          context.get<App>().user.bindValue(
              (context, value) => Center(child: Text(value?.email ?? ''))),
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: context.get<App>().signIn,
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Image.asset(
            'assets/table.cotton.jpg',
            fit: BoxFit.cover,
          )),
          Positioned.fill(
              child: CustomPaint(
            painter: TablePainter(),
          )),
          Center(
            child: Row(
              children: deck.cards
                  .take(5)
                  .map((face) => AnimatedPadding(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(8),
                      child: FacePlaceholder(child: CardWidget(face: face))))
                  .toList(),
            ),
          ),
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

class TablePainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {}

  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
