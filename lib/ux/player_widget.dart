import 'package:flutter/material.dart';
import 'package:poker/app.dart';
import 'package:poker/ux/game_card_widget.dart';

class Avatar extends StatelessWidget {
  final double radius;
  final Widget child;
  Avatar({this.child, this.radius = 22});
  Widget build(BuildContext context) {
    return Container(
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
          border: Border.all(width: 2, color: Colors.white)),
      child: Center(child: child),
    );
  }
}

class PlayerWidget extends StatelessWidget {

  final String alias;
  final String balance;

  PlayerWidget({this.alias, this.balance});

  @override
  Widget build(BuildContext context) {
    const avatarRadius = 32.0;
    const cardSize = 32.0;
    const fontSize = 12.0;
    const width = avatarRadius * 1.7 + cardSize * 1.8;
    return Container(
      //color: Colors.red,
      width: width,
      height: 64,
      child: Stack(
        children: <Widget>[
          Avatar(
            radius: avatarRadius,
            child: Text('AA', style: TextStyle(color: Colors.white)),
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(avatarRadius * 1.7, cardSize * 0.2),
            child: GameCardWidget(
                card: GameCard(rank: Rank.Ace, suit: Suit.Spade),
                size: cardSize),
          ),
          Transform(
            transform: Matrix4.identity()
              ..translate(avatarRadius * 1.7 + cardSize * .7, cardSize * 0.4),
            child: GameCardWidget(
                card: GameCard(rank: Rank.Ace, suit: Suit.Spade),
                size: cardSize),
          ),
          Transform(
              transform: Matrix4.identity()..translate(0.0, avatarRadius * 1.8),
              child: Text(alias,
                  textWidthBasis: TextWidthBasis.longestLine,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: fontSize, color: Color(0xFFD4D4D4)))),
          Transform(
              transform: Matrix4.identity()
                ..translate(0.0, avatarRadius * 1.8 + fontSize * 1.1),
              child: Text(balance,
                  textWidthBasis: TextWidthBasis.longestLine,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: fontSize, color: Color(0xFFFFD295)))),
        ],
      ),
    );
  }
}
