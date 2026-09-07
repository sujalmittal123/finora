import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String _guestKey = 'guest_mode';

class GuestNotifier extends StateNotifier<bool> {
  GuestNotifier() : super(_load());

  static bool _load() {
    try {
      return Hive.box('finora_state').get(_guestKey) as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  void enterGuestMode() {
    state = true;
    _save();
  }

  void exitGuestMode() {
    state = false;
    _save();
  }

  void _save() {
    try {
      Hive.box('finora_state').put(_guestKey, state);
    } catch (_) {
      // Never crash on storage failure.
    }
  }
}

final guestModeProvider =
    StateNotifierProvider<GuestNotifier, bool>((ref) => GuestNotifier());
