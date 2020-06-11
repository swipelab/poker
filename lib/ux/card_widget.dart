import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:poker/game.dart';

class CardWidget extends StatefulWidget {
  final PokerCard card;
  final double size;

  CardWidget({this.card, this.size = 48});

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  double t = 0;

  Color color(PokerCard card) =>
      (card.suit == Suit.Heart || card.suit == Suit.Diamond)
          ? Colors.red
          : Colors.black;

  Widget suit(BuildContext context, PokerCard card, {double size = 22}) =>
      Image.asset('assets/${card.suit.toString()}.Inner.png',
          width: size, height: size, filterQuality: FilterQuality.high);

  Widget rank(BuildContext context, PokerCard card, {double size = 22}) =>
      Text(rankString(card.rank),
          style: TextStyle(
              color: color(card),
              fontSize: size,
              height: 1,
              fontWeight: FontWeight.w300));

  LinearGradient get gradient => LinearGradient(
      colors: [Color(0xFFF5F4E9), Color(0xFFDCDBCD), Color(0xFFC9C9BB)],
      begin: Alignment(0, -1),
      end: Alignment(0, 1),
      stops: [0, 0.5, 1]);

  Widget face(BuildContext context, PokerCard card, {double size = 48}) =>
      Container(
        width: size,
        height: size * 1.33,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: gradient,
            boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black54)]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            suit(context, card, size: size * 0.5),
            rank(context, card, size: size * 0.5)
          ],
        ),
      );

  Widget back(BuildContext context, {double size = 48}) => Container(
      width: size,
      height: size * 1.33,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Color(0x00000000), width: 2),
          image: DecorationImage(
              image: AssetImage('assets/Back.Grill.png'),
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.1), BlendMode.dstATop),
              fit: BoxFit.scaleDown),
          boxShadow: [BoxShadow(blurRadius: 3, color: Colors.black54)]),
      child: Image.asset('assets/Logo.png', filterQuality: FilterQuality.high));

  @override
  Widget build(BuildContext context) {
    final child = widget.card?.known != true
        ? back(context, size: widget.size)
        : face(context, widget.card, size: widget.size);
    return Transform(
        transform: Matrix4.identity()..setEntry(3, 2, 0.002)
        //..rotateY(-pi * t)
        ,
        alignment: Alignment(0, 0),
        child: child);
  }
}
