import 'Recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';

//THis is the post class i'm not sure if it's necessary but i added it to keep track of the user who posted the recipe
//and the recipe itself
class Post {
  User? poster;
  Recipe posts;
  int isLiked = 0;
  int isDisliked = 0;

  Post({required this.poster, required this.posts});

//this is the method that converts the json data to a recipe object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      poster: json['poster'],
      posts: Recipe.fromJson(json['posts']),
    );
  }

  factory Post.fromJson2(User? jsonPoster, Map<String, dynamic> jsonPosts) {
    return Post(
      poster: jsonPoster,
      posts: Recipe.fromJson(jsonPosts),
    );
  }
}
