import 'dart:async';
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

enum Round { Idle, Preflop, Flop, Turn, River, Over }

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

  static HandRank from(Iterable<PokerCard> cards) {
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

    final groups = ranks.entries.length;
    final product = ranks.entries.fold(1, (p, e) => p *= e.value);

    final straight = groups == 5 &&
        ((sum - 5 * low == 0.5 * (high - low) * (high - low + 1)) || sum == 18);

    final aceHigh = low == Rank.Ten.index;
    final flushed = suits.values.max((e) => e);
    final kind =
        ranks.entries.max((e) => e.value * Rank.values.length + e.key.index);

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

class PokerCard {
  final Rank rank;
  final Suit suit;

  PokerCard({this.rank, this.suit});
}

class Deck {
  final List<PokerCard> cards;

  Deck({this.cards});

  static Deck shuffled() {
    final cards = List<PokerCard>();

    Rank.values.forEach((rank) => Suit.values
        .forEach((suit) => cards.add(PokerCard(rank: rank, suit: suit))));

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
  int key;

  int bet;
  int balance = 0;

  bool active = false;
  final List<PokerCard> cards = [];
  Player player;

  Seat({this.key});
}

class PokerTable {
  int bet;
  int pot;

  Round round = Round.Idle;

  final Deck deck;
  final List<Seat> seats;
  final List<PokerCard> common = List<PokerCard>();

  PokerTable({this.deck, this.seats, this.bet = 0, this.pot = 0});
  static PokerTable of(int seats) => PokerTable(
      deck: Deck.shuffled(),
      seats: Iterable.generate(seats, (i) => Seat(key: i)).toList());
}

class GameSeat {}

class PlayerTableSeat {
  final int bet;
  final int balance;

  final bool active;

  final String alias;
  final List<PokerCard> cards;

  PlayerTableSeat(
      {this.bet, this.balance, this.active, this.alias, this.cards});
}

class PlayerTable {
  final Player player;
  final List<PlayerTableSeat> seats;
  PlayerTable({this.player, this.seats});
}

class Dealer {
  final PokerTable table = PokerTable.of(6);
  final List<Player> players = List();

  Timer _timer;
  DateTime _startedAt;
  Duration _elapsed;



  double get actionProgress =>
      _elapsed.inMilliseconds / actionTimeout.inMilliseconds;

  final Duration actionTimeout = Duration(seconds: 10);

  start() {
    _startedAt = DateTime.now();
    _timer = Timer.periodic(Duration(milliseconds: 100), handleTick);
  }

  handleTick(Timer timer) {
    _elapsed = DateTime.now().difference(_startedAt);
  }

  timeout() {}

  stop() {
    _timer?.cancel();
    _timer = null;
  }

  broadcast() {
    playerStates.clear();
    table.seats.where((e) => e.player != null).forEach((e) {
      final state = PlayerTable(
        player: e.player,
        seats: table.seats
            .map((s) => PlayerTableSeat(
                bet: s.bet,
                alias: s.player.alias,
                balance: s.balance,
                cards: e.player == s.player
                    ? s.cards
                    : [PokerCard(), PokerCard()]))
            .toList(),
      );
      playerStates[e.player.alias] = state;
    });

    playerState.value = playerStates.values.first;
  }

  revealCommon() {
    table.common.add(table.deck.removeTop());
  }

  Map<String, PlayerTable> playerStates = {};

  Ref<PlayerTable> playerState = Ref();
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
