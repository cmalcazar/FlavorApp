import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'post.dart';

//This is the post provider class
class PostProvider extends ChangeNotifier {
  //holds all the posts
  final List<Post> _posts = [];
  List<Post> get posts => _posts;

  //This is the method that adds the post to the list of posts
  void addPost(Post post) {
    //calls method to check if the character is a favorite
    _posts.add(post);
    notifyListeners();
  }

  //This is the method that removes a post from the list of posts
  void removePost(Post recipe) {
    _posts.remove(recipe);
    notifyListeners();
  }
}
