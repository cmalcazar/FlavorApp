import 'package:flutter/material.dart';

import 'post.dart';

//This is the favorites provider class
class FavoritesProvider extends ChangeNotifier {
  //This is the list of recipes that the user has favorited
  List<Post> _recipeFav = [];
  List<Post> get recipes => _recipeFav;

  //This is the list of reviews that the user has favorited(optional)
  List<String> reviews = [];

  //This is the method that adds the recipe to the list of favorites
  void addFav(Post recipe) {
    //calls method to check if the character is a favorite
    final isFav = recipe.posts.isFavorite;
    if (isFav!) {
      _recipeFav.insert(0, recipe);

      //if theres already a character in the list remove it
    } else if (!recipe.posts.canAdd!) {
      _recipeFav.remove(recipe);
    }
    notifyListeners();
  }

  //This is the method that clears the list of favorites
  void clearFavorite() {
    _recipeFav = [];
    notifyListeners();
  }

  //This is the method that removes the recipe from the list of favorites
  void removeFav(Post recipe) {
    _recipeFav.remove(recipe);
    notifyListeners();
  }
}
