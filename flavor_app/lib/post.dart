import 'Recipe.dart';
import 'package:firebase_auth/firebase_auth.dart';

//THis is the post class i'm not sure if it's necessary but i added it to keep track of the user who posted the recipe
//and the recipe itself
class Post {
  String? posterID;
  User? poster;
  Recipe posts;
  int isLiked = 0;
  int isDisliked = 0;

  Post({required this.posts, this.posterID});

//this is the method that converts the json data to a recipe object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      posterID: json['posterID'],
      //poster: json['poster'],
      posts: Recipe.fromJson(json['posts']),
    );
  }

  factory Post.fromJson2(String jsonPoster, Map<String, dynamic> jsonPosts) {
    return Post(
      posterID: jsonPoster,
      posts: Recipe.fromJson(jsonPosts),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posterID': posterID,
      'posts': posts.toJson(),
    };
  }
}
