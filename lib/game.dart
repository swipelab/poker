import 'dart:math';
import 'package:scoped/scoped.dart';

enum Rank {
  Two,
  Three,
  Four,
  Five,
  Six,
  Seven,
  Eight,
  Nine,
  Ten,
  Jack,
  Queen,
  King,
  Ace
}

enum Suit { Club, Diamond, Heart, Spade }

enum Round { Begin, Preflop, Flop, Turn, River, End }

enum Hand {
  HighCard,
  Pair,
  TwoPair,
  ThreeKind,
  Straight,
  Flush,
  FullHouse,
  FourKind,
  StraightFlush,
  RoyalFlush, //not necessary
}

class HandRank {
  final Hand hand;
  final Rank rank;

  HandRank(this.hand, this.rank);

  static HandRank from(Iterable<GameCard> cards) {
    final suits = <Suit, int>{};
    final ranks = <Rank, int>{};

    var high = -1;
    var low = Rank.values.length;
    var sum = 0;

    cards.forEach((e) {
      low = min(e.rank.index, low);
      high = max(e.rank.index, high);
      sum += e.rank.index;

      suits[e.suit] = (suits[e.suit] ?? 0) + 1;
      ranks[e.rank] = (ranks[e.rank] ?? 0) + 1;
    });

    final straight = sum - 5 * low == 0.5 * (high - low) * (high - low + 1);
    final aceHigh = low == Rank.Ten.index;
    final flushed = suits.values.max((e) => e);
    final kind =
        ranks.entries.max((e) => e.value * Rank.values.length + e.key.index);

    final groups = ranks.entries.length;
    final product = ranks.entries.fold(1, (p, e) => p *= e.value);

    if (flushed == 5 && straight && aceHigh)
      return HandRank(Hand.RoyalFlush, Rank.Ace);
    if (flushed == 5 && straight)
      return HandRank(Hand.StraightFlush, Rank.values[high]);
    if (groups == 2 && product == 4) return HandRank(Hand.FourKind, kind.key);
    if (groups == 2 && product == 6) return HandRank(Hand.FullHouse, kind.key);
    if (flushed == 5) return HandRank(Hand.Flush, Rank.values[high]);
    if (straight) return HandRank(Hand.Straight, Rank.values[high]);
    if (groups == 3 && product == 3) return HandRank(Hand.ThreeKind, kind.key);
    if (groups == 3 && product == 4) return HandRank(Hand.TwoPair, kind.key);
    if (groups == 3 && product == 2) return HandRank(Hand.Pair, kind.key);
    return HandRank(Hand.HighCard, kind.key);
  }

  int get value => this.hand.index * Rank.values.length + this.rank.index;

  @override
  bool operator ==(other) {
    return other is HandRank && other.value == value;
  }

  @override
  int get hashCode => this.hand.index.hashCode ^ this.rank.index.hashCode;
}

handValue(Iterable<GameCard> cards) {}

Map<Suit, int> suitCount(Iterable<GameCard> cards) =>
    cards.fold<Map<Suit, int>>({}, (p, e) {
      p[e.suit] = (p[e.suit] ?? 0) + 1;
      return p;
    });

Map<Rank, int> rankCount(Iterable<GameCard> cards) =>
    cards.fold<Map<Rank, int>>({}, (p, e) {
      p[e.rank] = (p[e.rank] ?? 0) + 1;
      return p;
    });

bool isPair(Iterable<GameCard> cards) =>
    suitCount(cards).values.where((e) => e == 2).length == 1;

bool isTwoPair(Iterable<GameCard> cards) =>
    suitCount(cards).values.where((e) => e == 2).length == 2;

bool isFlush(Iterable<GameCard> cards) =>
    suitCount(cards).values.any((e) => e == 5);

bool isTreeKind(Iterable<GameCard> cards) =>
    suitCount(cards).values.any((e) => e == 3);

bool isFourKind(Iterable<GameCard> cards) =>
    suitCount(cards).values.any((e) => e == 4);

bool isFullHouse(Iterable<GameCard> cards) =>
    rankCount(cards)
        .values
        .fold(0, (p, c) => p | (c == 2 ? 1 : (c == 3 ? 2 : 0))) ==
    3;

bool isStraight(Iterable<GameCard> cards) {
  var low = 15;
  var high = -1;
  var sum = 0;
  cards.forEach((e) {
    low = min(e.rank.index, low);
    high = max(e.rank.index, high);
    sum += e.rank.index;
  });
  return sum - 5 * low == (high - low) * (high - low + 1) * 0.5;
}

bool isStraightFlush(Iterable<GameCard> cards) =>
    isStraight(cards) && isFlush(cards);

bool isRoyalFlush(Iterable<GameCard> cards) =>
    isStraight(cards) && isFlush(cards) && cards.any((e) => e.rank == Rank.Ace);

rankString(Rank rank) {
  switch (rank) {
    case Rank.Two:
      return '2';
    case Rank.Three:
      return '3';
    case Rank.Four:
      return '4';
    case Rank.Five:
      return '5';
    case Rank.Six:
      return '6';
    case Rank.Seven:
      return '7';
    case Rank.Eight:
      return '8';
    case Rank.Nine:
      return '9';
    case Rank.Ten:
      return '10';
    case Rank.Jack:
      return 'J';
    case Rank.Queen:
      return 'Q';
    case Rank.King:
      return 'K';
    case Rank.Ace:
      return 'A';
  }
  return null;
}

suitString(Suit suit) {
  switch (suit) {
    case Suit.Club:
      return '♣';
    case Suit.Diamond:
      return '◆';
    case Suit.Heart:
      return '♥';
    case Suit.Spade:
      return '♠';
  }
  return null;
}

shuffle(List list) {
  int n = list.length;
  final rnd = Random();
  while (n > 1) {
    int k = rnd.nextInt(n);
    n--;
    final s = list[k];
    list[k] = list[n];
    list[n] = s;
  }
}

class GameCard {
  final Rank rank;
  final Suit suit;

  GameCard({this.rank, this.suit});
}

class Deck {
  final List<GameCard> cards;

  Deck({this.cards});

  static Deck shuffled() {
    final cards = List<GameCard>();

    Rank.values.forEach((rank) => Suit.values
        .forEach((suit) => cards.add(GameCard(rank: rank, suit: suit))));

    shuffle(cards);

    return Deck(cards: cards);
  }

  removeTop() {
    if (cards.isEmpty) return null;
    return cards.removeAt(0);
  }
}

class Player {
  final String alias;
  final int balance;

  Player({this.alias, this.balance});
}

class Seat {
  final int key;
  final Ref<int> balance = Ref(0);
  final Ref<bool> active = Ref(false);
  final Refs<GameCard> cards = Refs([]);
  final Ref<Player> player = Ref();

  Seat({this.key});
}

class Table {
  final Ref<int> bet = Ref(0);
  final Ref<int> pot = Ref(0);
  final Ref<Round> round = Ref(Round.Begin);

  final Deck deck = Deck.shuffled();
  final Refs<Seat> seats =
      Refs<Seat>(Iterable.generate(6, (i) => Seat(key: i)));
  final Refs<GameCard> common = Refs<GameCard>();

  revealCommon() {
    common.add(deck.removeTop());
  }
}

class Dealer {
  final Table table = Table();

  timeout() {}
}

class GameEvent {}

extension Itex<T> on Iterable<T> {
  T max<V extends Comparable>(V f(T e)) => this.reduce((max, e) {
        switch (Comparable.compare(f(max), f(e))) {
          case -1:
            return e;
          case 0:
          case 1:
          default:
            return max;
        }
      });
}
