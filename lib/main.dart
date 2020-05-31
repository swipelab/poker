import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:poker/app.dart';
import 'package:poker/main_page.dart';
import 'package:poker/game.dart';
import 'package:poker/table_page.dart';
import 'package:scoped/scoped.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);

  final app = App();
  final dealer = Dealer();
  final store = Store()..add(app)..add(dealer);

  await app.init();

  runApp(Scope(store: store, child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Poker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.red,
        ),
        routes: {
          '/': (_) => MainPage(),
          '/table': (_) => TablePage(),
        });
  }
}
