import 'package:flutter_test/flutter_test.dart';
import 'package:poker/game.dart';

void main() {
  test('not flush', () {
    assert(!isFlush([
      GameCard(suit: Suit.Spade),
    ]));
  });

  test('flush', () {
    assert(isFlush([
      GameCard(suit: Suit.Spade),
      GameCard(suit: Suit.Spade),
      GameCard(suit: Suit.Spade),
      GameCard(suit: Suit.Spade),
      GameCard(suit: Suit.Spade),
    ]));
  });

  test('straight', () {
    assert(isStraight([
      GameCard(rank: Rank.Ace),
      GameCard(rank: Rank.King),
      GameCard(rank: Rank.Queen),
      GameCard(rank: Rank.Jack),
      GameCard(rank: Rank.Ten),
    ]));
  });

  test('royal flush', () {
    assert(HandRank(Hand.RoyalFlush, Rank.Ace) ==
        HandRank.from([
          GameCard(rank: Rank.Ace, suit: Suit.Spade),
          GameCard(rank: Rank.King, suit: Suit.Spade),
          GameCard(rank: Rank.Queen, suit: Suit.Spade),
          GameCard(rank: Rank.Jack, suit: Suit.Spade),
          GameCard(rank: Rank.Ten, suit: Suit.Spade),
        ]));
  });

  test('flush', () {
    assert(HandRank(Hand.Flush, Rank.Ace) ==
        HandRank.from([
          GameCard(rank: Rank.Ace, suit: Suit.Spade),
          GameCard(rank: Rank.King, suit: Suit.Spade),
          GameCard(rank: Rank.Queen, suit: Suit.Spade),
          GameCard(rank: Rank.Jack, suit: Suit.Spade),
          GameCard(rank: Rank.Eight, suit: Suit.Spade),
        ]));
  });

  test('full house', () {
    assert(isFullHouse([
      GameCard(rank: Rank.Ace),
      GameCard(rank: Rank.Ace),
      GameCard(rank: Rank.Ace),
      GameCard(rank: Rank.King),
      GameCard(rank: Rank.King),
    ]));
    assert(!isFullHouse([
      GameCard(rank: Rank.Ace),
      GameCard(rank: Rank.Ace),
      GameCard(rank: Rank.King),
      GameCard(rank: Rank.King),
      GameCard(rank: Rank.Queen),
    ]));
  });
}
