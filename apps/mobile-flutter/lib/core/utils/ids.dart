/// Generates locally unique ids for new records.
///
/// There is no backend this term, so a timestamp plus a per-launch counter is
/// enough to keep ids unique inside one device's `SharedPreferences`.
class IdGenerator {
  IdGenerator({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  int _counter = 0;

  String next(String prefix) {
    _counter += 1;
    return '$prefix-${_now().microsecondsSinceEpoch}-$_counter';
  }
}
