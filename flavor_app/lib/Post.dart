import 'recipe.dart';

//THis is the post class i'm not sure if it's necessary but i added it to keep track of the user who posted the recipe
//and the recipe itself
class Post {
  String? posterID;
  Recipe posts;
  String? location;
  bool isLiked;
  bool isDisliked;
  int likedCount = 0;
  int dislikedCount = 0;


  Post(
      {required this.posts,
        this.posterID,
        this.location,
        this.isDisliked = false,
        this.isLiked = false,
        this.likedCount = 0,
        this.dislikedCount = 0});


//converts the json data to a recipe object
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      posterID: json['posterID'],
      posts: Recipe.fromJson(json['posts']),
      location: json['location'],
      likedCount: json['likedCount'],
      dislikedCount: json['dislikedCount'],
    );
  }

  //converts object to a json string
  Map<String, dynamic> toJson() {
    return {
      'posterID': posterID,
      'posts': posts.toJson(),
      'location': location,
      'likedCount': likedCount,
      'dislikedCount': dislikedCount,
    };

  }


}
