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
  final List<PokerCard> common;
  PlayerTable({this.player, this.seats, this.common});
}

class Dealer {
  final PokerTable table = PokerTable.of(6);
  final List<Player> players = [];

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
      Player(alias: 'greeno', balance: 200),
      Player(alias: 'chris', balance: 200),
      Player(alias: 'penny', balance: 200),
      Player(alias: 'jenny', balance: 200),
    ]);

    var i = 0;
    for (var seat in table.seats) {
      seat.player = players[i];
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
  }

  timeout() {}

  stop() {
    _timer?.cancel();
    _timer = null;
  }

  broadcast() {
    playerStates.clear();

    final common = [
      PokerCard(rank: Rank.Ace, suit: Suit.Diamond),
      PokerCard(rank: Rank.King, suit: Suit.Club),
      PokerCard(rank: Rank.Queen, suit: Suit.Club),
      PokerCard(rank: Rank.Jack, suit: Suit.Club),
      PokerCard(rank: Rank.Ten, suit: Suit.Club),
    ];
    
    for (final e in table.seats) {
      if (e.player == null) continue;

      final state = PlayerTable(
        player: e.player,
        common: common,
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
    }

    playerState.value = playerStates.values.first;
  }

  revealCommon() {
    table.common.add(table.deck.removeTop());
  }

  Map<String, PlayerTable> playerStates = {};

  Ref<PlayerTable> playerState = Ref();
}

class GameEvent {}

typedef T _Transformation<S, T>(S value, int index);

extension Iter<T> on Iterable<T> {
  Iterable<V> mapi<V>(V f(T e, int i)) => MapIterable<T, V>(this, f);

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

class MapIterable<S, T> extends Iterable<T> {
  final Iterable<S> _iterable;
  final _Transformation<S, T> _f;

  factory MapIterable(Iterable<S> iterable, T function(S value, int index)) =>
      MapIterable<S, T>._(iterable, function);

  MapIterable._(this._iterable, this._f);

  Iterator<T> get iterator => MapI<S, T>(_iterable.iterator, _f);
  int get length => _iterable.length;
  bool get isEmpty => _iterable.isEmpty;
}

class MapI<S, T> extends Iterator<T> {
  T _current;
  int _index = -1;
  final Iterator<S> _iterator;
  final _Transformation<S, T> _f;

  MapI(this._iterator, this._f);

  bool moveNext() {
    if (_iterator.moveNext()) {
      _current = _f(_iterator.current, ++_index);
      return true;
    }
    _current = null;
    _index = -1;
    return false;
  }

  T get current => _current;
}
