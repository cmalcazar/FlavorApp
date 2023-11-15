import 'package:flutter/material.dart';

class RatingProvider extends ChangeNotifier {
  int _likesRating = 0;
  int _dislikesRating = 0;
  int get likes => _likesRating;
  int get dislikes => _dislikesRating;

  addLikes() {
    _likesRating++;
    notifyListeners();
  }

  subLikes() {
    _likesRating--;
    notifyListeners();
  }

  addDislikes() {
    _dislikesRating++;
    notifyListeners();
  }

  subDislikes() {
    _dislikesRating--;
    notifyListeners();
  }
}
