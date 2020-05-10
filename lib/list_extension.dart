extension ListExtension on Iterable {
  Iterable<T> mapIndex<S, T>(T fn(S e, int i)) =>
      MapIndexedIterable<S, T>(this, fn);
}

typedef T _Transformation<S, T>(S value, int index);

class MapIndexedIterable<S, T> extends Iterable<T> {
  final Iterable<S> _iterable;
  final _Transformation<S, T> _f;

  factory MapIndexedIterable(Iterable<S> iterable, T function(S value, int index)) =>
      MapIndexedIterable<S, T>._(iterable, function);

  MapIndexedIterable._(this._iterable, this._f);

  Iterator<T> get iterator => MapIterator<S, T>(_iterable.iterator, _f);

  // Length related functions are independent of the mapping.
  int get length => _iterable.length;
  bool get isEmpty => _iterable.isEmpty;
}

class MapIterator<S, T> extends Iterator<T> {
  T _current;
  int _index = -1;
  final Iterator<S> _iterator;
  final _Transformation<S, T> _f;

  MapIterator(this._iterator, this._f);

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
