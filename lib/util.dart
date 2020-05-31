typedef T _IndexTransformFn<S, T>(S value, int index);

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
  final _IndexTransformFn<S, T> _f;

  factory MapIterable(Iterable<S> iterable, T function(S value, int index)) =>
      MapIterable<S, T>._(iterable, function);

  MapIterable._(this._iterable, this._f);

  Iterator<T> get iterator => _MapIterator<S, T>(_iterable.iterator, _f);
  int get length => _iterable.length;
  bool get isEmpty => _iterable.isEmpty;
}

class _MapIterator<S, T> extends Iterator<T> {
  T _current;
  int _index = -1;
  final Iterator<S> _iterator;
  final _IndexTransformFn<S, T> _f;

  _MapIterator(this._iterator, this._f);

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
