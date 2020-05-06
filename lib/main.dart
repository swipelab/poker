import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poker/app.dart';
import 'package:poker/ux/game_card_widget.dart';
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

class TablePage extends StatefulWidget {
  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  final Deck deck = Deck.shuffled();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003723),
      drawer: Drawer(),
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
      body: Stack(
        children: [
//          Positioned.fill(
//              child: Image.asset(
//            'assets/table.cotton.jpg',
//            fit: BoxFit.cover,
//          )),
          Positioned.fill(
              child: CustomPaint(
            painter: TablePainter(),
          )),
          Center(
            child: Row(
              children: deck.cards
                  .take(5)
                  .map((card) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GameCardWidget(card: card),
                  ))
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
