import 'dart:math';

import 'package:flutter/material.dart';
import 'package:poker/game.dart';
import 'package:poker/ux/game_card_widget.dart';
import 'package:poker/ux/seat_widget.dart';
import 'package:poker/list_extension.dart';

class TableWidget extends StatelessWidget {
  final List<PokerCard> cards = [
    PokerCard(rank: Rank.Ace, suit: Suit.Spade),
    PokerCard(rank: Rank.King, suit: Suit.Spade),
    PokerCard(rank: Rank.Jack, suit: Suit.Spade),
    PokerCard(rank: Rank.Ten, suit: Suit.Spade),
    PokerCard(rank: Rank.Nine, suit: Suit.Spade),
  ];

  final List<Player> players = [
    Player(alias: 'alex', balance: 300),
    Player(alias: 'krisu', balance: 640),
    Player(alias: 'seb', balance: 980),
    Player(alias: 'seb', balance: 980),
    Player(alias: 'seb', balance: 980),
    Player(alias: 'seb', balance: 980),
  ];

  final List<int> seats = List.filled(6, null);

  final double cardSize;
  final double progress;

  TableWidget({this.cardSize = 24, this.progress});

  final playerCount = 6;
  final align = {
    1: [
      Alignment(0, 1),
    ],
    2: [
      Alignment(0, 1),
      Alignment(0, -1),
    ],
    3: [
      Alignment(0, 1),
      Alignment(-1, -1),
      Alignment(1, -1),
    ],
    4: [
      Alignment(0, 1),
      Alignment(-1, 0),
      Alignment(0, -1),
      Alignment(1, 0),
    ],
    5: [
      Alignment(0, 1),
      Alignment(-1, 1),
      Alignment(-0.7, -1),
      Alignment(0.7, -1),
      Alignment(1, 1),
    ],
    6: [
      Alignment(0, 1.1),
      Alignment(-0.85, 0.85),
      Alignment(-0.85, -0.85),
      Alignment(0, -1.1),
      Alignment(0.9, -0.9),
      Alignment(0.9, 0.9),
    ]
  };

  Widget buildCommonCards(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: cards
            .mapIndex((e, i) => Padding(
                  padding: EdgeInsets.only(left: i > 2 ? 24.0 : 6.0),
                  child: GameCardWidget(card: e, size: 48),
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          width: 1280 * .55,
          height: 720 * .55,
          child: CustomPaint(
            painter: TablePainter(offset: pi / players.length, playerCount: playerCount, length: 0, progress: progress),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: buildCommonCards(context),
                ),
              ]..addAll(
                  players.mapIndex(
                    (e, i) => Align(
                      alignment: align[players.length][i],
                      child: SeatWidget(alias: e.alias, balance: e.balance.toString()),
                    ),
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }
}

class TablePainter extends CustomPainter {
  final double offset;
  final int playerCount;
  final double progress;
  final double length;

  TablePainter({this.offset, this.playerCount, this.progress, this.length});

  void paintBounds(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final gap = 192;
    final radius = size.height / 2;

    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: size.width, height: size.height), Radius.circular(radius)),
        paint);

    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size.width - gap, height: size.height - gap),
            Radius.circular(radius)),
        paint);
  }

  void paintDealerTimming(Canvas canvas, Size size) {
    final length = 250.0;
    final center = size.center(Offset.zero);
    final playerArch = (2 * pi) / playerCount.toDouble();
    final p2 =
        Offset(sin(offset + playerArch - playerArch * progress), cos(offset + playerArch - playerArch * progress))
            .scale(length, length);

    canvas.drawLine(
        center,
        center + p2,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke);

    var archPos = offset;
    for (int x = 0; x < playerCount; x++) {
      final from = Offset(sin(archPos), cos(archPos)).scale(length, length);
      final paint = Paint()
        ..color = Colors.white.withAlpha(255 - 255 * x ~/ playerCount)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, center + from, paint);
      archPos -= playerArch;
    }
  }

  void paint(Canvas canvas, Size size) {
    // paintDealerTimming(canvas, size);
    paintBounds(canvas, size);
  }

  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
