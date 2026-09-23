import 'dart:async';
class Debouncer {
  final Duration delay;
  Timer? _t;
  Debouncer({this.delay = const Duration(milliseconds: 300)});
  void call(void Function() fn) { _t?.cancel(); _t = Timer(delay, fn); }
  void dispose() => _t?.cancel();
}
