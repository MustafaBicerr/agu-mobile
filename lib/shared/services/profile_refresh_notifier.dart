import 'package:flutter/foundation.dart';

class ProfileRefreshNotifier {
  static final ValueNotifier<int> tick = ValueNotifier<int>(0);

  static void notify() {
    tick.value = tick.value + 1;
  }
}
