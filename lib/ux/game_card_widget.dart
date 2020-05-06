import 'package:flutter/material.dart';
import 'package:poker/app.dart';

class GameCardWidget extends StatelessWidget {
  Color color(GameCard card) =>
      (card.suit == Suit.Heart || card.suit == Suit.Diamond)
          ? Colors.red
          : Colors.black;

  Widget suit(BuildContext context, GameCard card, {double size = 22}) =>
      Image.asset('assets/${card.suit.toString()}.Inner.png',
          width: size, height: size, filterQuality: FilterQuality.high);

  Widget rank(BuildContext context, GameCard card, {double size = 22}) =>
      Text(rankString(card.rank),
          style: TextStyle(
              color: color(card),
              fontSize: size,
              height: 1,
              fontWeight: FontWeight.w100));

  final GameCard card;

  GameCardWidget({this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
              colors: [Color(0xFFF5F4E9), Color(0xFFDCDBCD), Color(0xFFC9C9BB)],
              begin: Alignment(0, -1),
              end: Alignment(0, 1),
              stops: [0, 0.5, 1]),
          boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black54)]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[suit(context, card), rank(context, card)],
      ),
    );
  }
}
