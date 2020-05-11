import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poker/app.dart';
import 'package:poker/ux/game_card_widget.dart';
import 'package:poker/ux/player_widget.dart';
import 'package:poker/ux/table_widget.dart';
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

  Duration _elapsed;
  Duration _playerTurn;
  Timer _timer;
  DateTime _startedAt;
  double _progress = 0.0;

  initState() {
    super.initState();
    _elapsed = Duration.zero;
    _startedAt = DateTime.now();
    _playerTurn = Duration(seconds: 10);
    _timer = Timer.periodic(Duration(milliseconds: 100), handleTick);
    _progress = 0;
  }

  dispose() {
    super.dispose();
    _timer?.cancel();
    _timer = null;
  }

  handleTick(Timer t) {
    _elapsed = DateTime.now().difference(_startedAt);

    _progress = _elapsed.inMilliseconds / _playerTurn.inMilliseconds;
    setState(() {});
  }

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
        body: Container(
            child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 128.0),
                    child: TableWidget(progress: _progress))),
            Align(
              alignment: Alignment(0, 0.95),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFC6C6C6),
                        Color(0xFFFFFFFF),
                        Color(0xFFE0E0E0),
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
        )));
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
