import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
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
  Ace,
}

enum Suit {
  Club,
  Diamond,
  Heart,
  Spade,
}

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
}

class Player {
  final String alias;
  final int balance;
  Player({this.alias, this.balance});
}

class Seat {
  final Strip<GameCard> cards;
  final Player player;
  final int balance;
  Seat({this.cards, this.player, this.balance});
}

class Table {
  final Strip<Player> players = Strip<Player>();
  final Strip<Seat> seats = Strip<Seat>();
}

class App {
  Ref<FirebaseUser> user = Ref();

  init() async {
    FirebaseAuth.instance.onAuthStateChanged.listen(handleAuthStateChanged);
    await FirebaseAuth.instance.currentUser();
  }

  signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: 'alex@swipelab.co', password: 'cucubau');
  }

  void handleAuthStateChanged(FirebaseUser firebaseUser) {
    user.value = firebaseUser;
  }
}
