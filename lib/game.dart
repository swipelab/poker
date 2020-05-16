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

  timeout() {
  }


}

class GameEvent {}
