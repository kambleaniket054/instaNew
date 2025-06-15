import 'package:flutter/foundation.dart';

class VideoEditorProvider with ChangeNotifier {
  double currentPosition = 0.0;

  void updatePosition(double position) {
    currentPosition = position;
    notifyListeners();
  }
}
