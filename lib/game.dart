import 'dart:async';
import 'dart:math';
import 'package:scoped/scoped.dart';
import 'util.dart';

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

enum PokerRound { Ready, Preflop, Flop, Turn, River, Over }

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

enum Action {
  Bet,
  Raise,
  Call,
  Fold,
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

  bool get known => rank != null && suit != null;

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

  //small blind seat
  int small;

  //big blind seat
  int get big => (small + 1) % seats.length;

  PokerRound round = PokerRound.Ready;

  Deck deck;
  final List<Seat> seats;
  final List<PokerCard> common = List<PokerCard>();

  PokerTable(
      {this.deck, this.seats, this.bet = 0, this.pot = 0, this.small = 0});

  static PokerTable of(int seats) => PokerTable(
      deck: Deck.shuffled(),
      seats: Iterable.generate(seats, (i) => Seat(key: i)).toList());
}

class PlayerTableSeat {
  final int small;
  final int big;

  final int bet;
  final int balance;
  final bool active;

  final String alias;
  final List<PokerCard> cards;

  PlayerTableSeat({
    this.bet,
    this.balance,
    this.active,
    this.alias,
    this.cards,
    this.small,
    this.big,
  });
}

class PlayerTable {
  final PokerRound round;
  final Player player;
  final List<PlayerTableSeat> seats;
  final List<PokerCard> common;
  final List<Action> actions;

  PlayerTable({this.player, this.seats, this.common, this.actions, this.round});
}

class Dealer {
  final PokerTable table = PokerTable.of(6);
  final List<Player> players = [];
  Map<String, PlayerTable> playerStates = {};
  final Ref<List<PlayerTable>> views = Ref(<PlayerTable>[]);

  Timer _timer;
  DateTime _startedAt;
  Duration _elapsed;

  double get actionProgress =>
      _elapsed.inMilliseconds / actionTimeout.inMilliseconds;

  final Duration actionTimeout = Duration(seconds: 10);

  fillSeats() {
    players.clear();
    players.addAll([
      Player(alias: 'alex', balance: 200),
      Player(alias: 'krisu', balance: 200),
      Player(alias: 'john', balance: 200),
      Player(alias: 'alex', balance: 200),
      Player(alias: 'krisu', balance: 200),
      Player(alias: 'john', balance: 200),
    ]);

    var i = 0;
    while (i < table.seats.length) {
      if (i < players.length) {
        table.seats[i].player = players[i];
      } else {
        table.seats[i].player = null;
      }
      i++;
    }
  }

  start() {
    _startedAt = DateTime.now();
    _timer = Timer.periodic(Duration(milliseconds: 100), handleTick);

    this.broadcast();
  }

  handleTick(Timer timer) {
    _elapsed = DateTime.now().difference(_startedAt);
    table.seats[0].balance += 1;
    revealCommon();
    broadcast();
  }

  timeout() {}

  stop() {
    _timer?.cancel();
    _timer = null;
  }

  PlayerTable projectTable(Player player) {
    final view = PlayerTable(
        round: table.round,
        player: player,
        common: table.common,
        seats: table.seats
            .map((seat) => PlayerTableSeat(
                active: seat.player != null,
                bet: seat.bet,
                alias: seat.player?.alias ?? '',
                balance: seat.balance,
                cards: seat.player == player
                    ? seat.cards
                    : seat.cards.map((e) => PokerCard()).toList()))
            .toList());
    return view;
  }

  broadcast() {
    final List<PlayerTable> v = [];

    for (final seat in table.seats) {
      v.add(projectTable(seat.player));
    }

    views.value = v;
  }

  revealCommon() {
    if (table.common.length == 5) return;
    final top = table.deck.removeTop();
    if (top != null) table.common.add(top);
  }

  reset() {
    table.round = PokerRound.Ready;
    table.deck = Deck.shuffled();
    table.common.clear();
    for (final seat in table.seats) {
      seat.cards.clear();
    }
  }

  next() {
    switch (table.round) {
      case PokerRound.Ready:
        //start
        var i = table.small;
        var l = 0;
        while (l < table.seats.length) {
          l++;
          i = (i + 1) % table.seats.length;
          if (table.seats[i].player == null) continue;
          table.seats[i].cards.add(table.deck.removeTop());
          table.seats[i].cards.add(table.deck.removeTop());
        }

        //end
        table.round = PokerRound.Preflop;
        break;
      case PokerRound.Preflop:
        table.round = PokerRound.Flop;
        break;
      case PokerRound.Flop:
        table.round = PokerRound.Turn;
        break;
      case PokerRound.Turn:
        table.round = PokerRound.River;
        break;
      case PokerRound.River:
        table.round = PokerRound.Over;
        break;
    }
  }
}
