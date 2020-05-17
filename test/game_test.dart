import 'package:flutter_test/flutter_test.dart';
import 'package:poker/game.dart';

void main() {

  test('royal flush', () {
    assert(HandRank(Hand.RoyalFlush, Rank.Ace) ==
        HandRank.from([
          PokerCard(rank: Rank.Ace, suit: Suit.Spade),
          PokerCard(rank: Rank.King, suit: Suit.Spade),
          PokerCard(rank: Rank.Queen, suit: Suit.Spade),
          PokerCard(rank: Rank.Jack, suit: Suit.Spade),
          PokerCard(rank: Rank.Ten, suit: Suit.Spade),
        ]));
  });

  test('flush', () {
    assert(HandRank(Hand.Flush, Rank.Ace) ==
        HandRank.from([
          PokerCard(rank: Rank.Ace, suit: Suit.Spade),
          PokerCard(rank: Rank.King, suit: Suit.Spade),
          PokerCard(rank: Rank.Queen, suit: Suit.Spade),
          PokerCard(rank: Rank.Jack, suit: Suit.Spade),
          PokerCard(rank: Rank.Eight, suit: Suit.Spade),
        ]));
  });

}
