import 'package:flutter/services.dart';

class HapticService {
  void success() {
    HapticFeedback.lightImpact();
  }

  void error() {
    HapticFeedback.vibrate();
  }

  void selection() {
    HapticFeedback.selectionClick();
  }

  void heavy() {
    HapticFeedback.heavyImpact();
  }
}
