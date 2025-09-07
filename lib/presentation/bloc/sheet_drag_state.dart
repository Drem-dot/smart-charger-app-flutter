// lib/presentation/bloc/sheet_drag_state.dart
import 'package:flutter/foundation.dart';

class SheetDragState extends ChangeNotifier {
  bool _isDragging = false;
  bool get isDragging => _isDragging;

  void startDragging() {
    if (!_isDragging) {
      _isDragging = true;
      notifyListeners();
    }
  }

  void stopDragging() {
    if (_isDragging) {
      _isDragging = false;
      notifyListeners();
    }
  }
}