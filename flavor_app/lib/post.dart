import 'Recipe.dart';

//THis is the post class i'm not sure if it's necessary but i added it to keep track of the user who posted the recipe
//and the recipe itself
class Post {
  String poster;
  Recipe posts;

  Post({required this.poster, required this.posts});
}
