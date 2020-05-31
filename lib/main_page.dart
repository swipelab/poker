import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF003723),
      appBar: AppBar(
        title: Text('Poker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[],
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FlatButton(
                child: Text('Main Table'),
                onPressed: () => Navigator.pushNamed(context, '/table'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
