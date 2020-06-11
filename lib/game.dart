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

enum PokerAction {
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

class PokerTable {
  int bet;
  int pot;

  //small blind seat
  int small;

  //big blind seat
  int get big => nextTo(small);

  int entry;

  int current;

  PokerRound round = PokerRound.Ready;

  int nextTo(int seat) {
    if (seat == null) return null;
    var i = seat;
    var l = 0;
    while (l < seats.length) {
      i = (i + 1) % seats.length;
      l++;
      if (seats[i].active != true) continue;
      return i;
    }
    return null;
  }

  reset() {
    bet = 0;
    pot = 0;

    entry = 5;

    small = 0;
    round = PokerRound.Ready;
    deck = Deck.shuffled();
    common.clear();

    for (final seat in seats) {
      seat.reset();
    }
  }

  deal() {
    var index = small;
    var length = 0;
    while (length < seats.length) {
      length++;
      index = (index + 1) % seats.length;
      if (seats[index].player == null) continue;

      seats[index].cards.add(deck.removeTop());
      seats[index].cards.add(deck.removeTop());
    }

    current = nextTo(big);
  }

  dealCommon() {
    if (common.length == 5) return;
    final top = deck.removeTop();
    if (top != null) common.add(top);
  }

  Deck deck;
  final List<Seat> seats;
  final List<PokerCard> common = List<PokerCard>();

  PokerTable(
      {this.deck, this.seats, this.bet = 0, this.pot = 0, this.small = 0});

  static PokerTable of(int seats) => PokerTable(
      deck: Deck.shuffled(),
      seats: Iterable.generate(seats, (i) => Seat(key: i)).toList());
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
//      Player(alias: 'alex', balance: 200),
//      Player(alias: 'krisu', balance: 200),
//      Player(alias: 'john', balance: 200),
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
    broadcast();
  }

  timeout() {}

  stop() {
    _timer?.cancel();
    _timer = null;
  }

  PlayerTable projectTable(Player player) {
    final seat = table.seats.indexWhere((e) => e.player == player);
    final view = PlayerTable(
        round: table.round,
        player: player,
        common: table.common,
        seat: seat,
        current: seat == table.current,
        bet: table.bet,
        entry: table.entry,
        seats: table.seats
            .mapi((seat, i) => PlayerTableSeat(
                active: seat.active,
                current: table.current == i,
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
      if (seat.player != null) v.add(projectTable(seat.player));
    }

    views.value = v;
  }

  reset() {
    table.reset();
  }

  call(int seat) {
    if (seat != table.current) return;

    final target = table.bet;
    final diff = target - table.seats[seat].bet;

    table.pot += diff;
    table.seats[seat].bet = target;
    table.seats[seat].balance -= diff;

    table.bet = target;

    nextPlayer();
  }

  raise(int seat, int amount) {
    if (seat != table.current) return;

    final target = table.bet + amount;
    final diff = target - table.seats[seat].bet;

    table.pot += diff;
    table.seats[seat].bet = target;
    table.seats[seat].balance -= diff;

    table.bet = target;

    nextPlayer();
  }

  fold(int seat) {
    table.seats[seat].active = false;

    if (table.current == seat) nextPlayer();
  }

  nextPlayer() {
    table.current = table.nextTo(table.current);
  }

  next() {
    switch (table.round) {
      case PokerRound.Ready:
        table.round = PokerRound.Preflop;
        table.deal();

        table.current = table.small;

        raise(table.small, table.entry);
        raise(table.big, table.entry);

        break;
      case PokerRound.Preflop:
        table.round = PokerRound.Flop;
        table.dealCommon();
        table.dealCommon();
        table.dealCommon();

        break;
      case PokerRound.Flop:
        table.round = PokerRound.Turn;
        table.dealCommon();

        break;
      case PokerRound.Turn:
        table.round = PokerRound.River;
        table.dealCommon();

        break;
      case PokerRound.River:
        table.round = PokerRound.Over;
        break;
      case PokerRound.Over:
        //finished
        break;
    }
  }
}

class PlayerTableSeat {
  final int small;
  final int big;

  final int bet;
  final int balance;
  final bool active;

  final bool current;

  final String alias;
  final List<PokerCard> cards;

  PlayerTableSeat({
    this.bet,
    this.balance,
    this.active,
    this.current,
    this.alias,
    this.cards,
    this.small,
    this.big,
  });
}

class PlayerTable {
  final PokerRound round;

  final Player player;
  final int seat;
  final int bet;
  final int entry;

  final bool current;

  bool get active => seats[seat].active;

  final List<PlayerTableSeat> seats;
  final List<PokerCard> common;
  final List<PokerAction> actions;

  PlayerTable(
      {this.player,
      this.seat,
      this.bet,
      this.entry,
      this.current,
      this.seats,
      this.common,
      this.actions,
      this.round});
}

class PlayerAction {
  final PokerAction action;
  final Player player;

  PlayerAction({this.action, this.player});
}

class Player {
  final String alias;
  final int balance;

  Player({this.alias, this.balance});
}

class Seat {
  int key;

  int bet = 0;
  int balance = 0;

  bool active = false;
  final List<PokerCard> cards = [];
  Player player;

  Seat({this.key});

  reset() {
    active = player != null;

    cards.clear();
    bet = 0;
    balance = 0;
  }
}
