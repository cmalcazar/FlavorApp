import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:like_button/like_button.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'favoriteProvider.dart';
import 'post.dart';

//this is the page where the user can view the recipes as a timeline
//might change it to a list time so you can just click and it'll show who uploaded it and the recipe

class ShowRecipe extends StatelessWidget {
  final Post post;
  final int index;
  const ShowRecipe({required this.post, super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(post.posts.recipeName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ShowRecipePage(
          post: post,
          index: index,
        ),
      ),
    );
  }
}

class ShowRecipePage extends StatefulWidget {
  final Post post;
  final int index;
  const ShowRecipePage({required this.post, super.key, required this.index});

  @override
  State<ShowRecipePage> createState() =>
      _ShowRecipeState(post: post, index: index);
}

class _ShowRecipeState extends State<ShowRecipePage> {
  Post post;
  int index;
  var userData;
  late final db;
  String defaultPhoto =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2Fno-user-image.gif?alt=media&token=25a43660-490e-438d-b1c7-ad6f8c122f7d';
  String ifnull =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2F1000_F_251955356_FAQH0U1y1TZw3ZcdPGybwUkH90a3VAhb.jpg?alt=media&token=091b00f6-a4a8-4a4a-b66f-60e8978fb471&_gl=1*1dfhnga*_ga*MTM5MTUxODI4My4xNjk4NTE4MjUw*_ga_CW55HF8NVT*MTY5OTM1MTA4OS40MS4xLjE2OTkzNTQ2MzMuMTAuMC4w';

  _ShowRecipeState({required this.post, required this.index});


  @override
  void initState() {
    super.initState();
    db = Provider.of<FirebaseFirestore>(context, listen: false);
  }

  //This is the author of the recipe
  _postAuthor() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: userData != null
              ? NetworkImage(userData['profileImage'] ?? defaultPhoto)
              : NetworkImage(defaultPhoto),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userData['username'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  //this is the like button
  _like(var post) {
    final favs = Provider.of<FavoritesProvider>(context, listen: false);
    final db = Provider.of<FirebaseFirestore>(context);
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: FavoriteButton(
        iconColor: Colors.pinkAccent.shade400,
        iconSize: 35.5,
        isFavorite: post.posts.isFavorite,
        valueChanged: (fav) {
          post.posts.isFavorite = fav;
          if (fav) {
            post.posts.canAdd = false;
          }
          if (!favs.recipes.contains(post.posts.recipeId)) {
            favs.addFav(post);
          }
          List<Map<String, dynamic>> jsonList =
          favs.recipes.map((item) => item.posts.toJson()).toList();
          var authUser = auth.currentUser;
          db
              .collection('users')
              .doc(authUser!.uid)
              .update({'favorites': jsonList});
        },
      ),
    );
  }

  getFutureBuilder() {
    return FutureBuilder<DocumentSnapshot>(
      future: db.collection('users').doc(post.posterID).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          userData = snapshot.data!.data() as Map<String, dynamic>;

          return _postAuthor();
        }

        return const CircularProgressIndicator();
      },
    );
  }

  update() async {
    print(index);
    await db.collection('posts').doc((index + 1).toString()).update({
      'likedCount': post.likedCount,
      'dislikedCount': post.dislikedCount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          getFutureBuilder(),
          const SizedBox(
            height: 10,
          ),
          Image.network(post.posts.image ?? ifnull, fit: BoxFit.cover),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              LikeButton(
                size: 30.0,
                circleColor: const CircleColor(
                    start: Color.fromARGB(255, 251, 110, 110),
                    end: Color.fromARGB(255, 255, 28, 2)),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color.fromARGB(255, 252, 3, 3),
                  dotSecondaryColor: Color.fromARGB(255, 255, 116, 116),
                ),
                isLiked: post.isLiked,
                likeBuilder: (bool isLiked) {
                  return Icon(
                    Icons.thumb_up,
                    color: isLiked ? Colors.red : Colors.grey,
                    size: 30.0,
                  );
                },
                likeCount: post.likedCount,
                onTap: (bool isLiked) {
                  setState(() {
                    if (isLiked) {
                      if (post.likedCount > 0) {
                        post.likedCount--;
                      }
                      post.isLiked = false;
                    } else {
                      post.likedCount++;
                      post.isLiked = true;
                      if (post.isDisliked) {
                        // If the post is currently disliked
                        if (post.dislikedCount > 0) {
                          post.dislikedCount--; // Decrease the dislikedCount
                        }
                        post.isDisliked = false; // Set isDisliked to false
                      }
                    }
                  });
                  update();
                  return Future.value(post.isLiked);
                },
              ),
              const SizedBox(
                width: 10,
              ),
              LikeButton(
                size: 30.0,
                circleColor: const CircleColor(
                    start: Color.fromARGB(255, 251, 110, 110),
                    end: Color.fromARGB(255, 255, 28, 2)),
                bubblesColor: const BubblesColor(
                  dotPrimaryColor: Color.fromARGB(255, 252, 3, 3),
                  dotSecondaryColor: Color.fromARGB(255, 255, 116, 116),
                ),
                isLiked: post.isDisliked,
                likeBuilder: (bool isDisliked) {
                  return Icon(
                    Icons.thumb_down,
                    color: isDisliked ? Colors.red : Colors.grey,
                    size: 30.0,
                  );
                },
                likeCount: post.dislikedCount,
                onTap: (bool isDisliked) {
                  setState(() {
                    if (isDisliked) {
                      if (post.dislikedCount > 0) {
                        post.dislikedCount--;
                      }
                      post.isDisliked = false;
                    } else {
                      post.dislikedCount++;
                      post.isDisliked = true;
                      if (post.isLiked) {
                        // If the post is currently liked
                        if (post.likedCount > 0) {
                          post.likedCount--; // Decrease the likedCount
                        }
                        post.isLiked = false; // Set isLiked to false
                      }
                    }
                  });
                  update();

                  return Future.value(post.isDisliked);
                },
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0,bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.posts.description, style: GoogleFonts.lato(fontSize: 18)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0,bottom: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ingredients',style: TextStyle(fontFamily: 'Lato', fontSize: 25, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          SizedBox(
            width: 360,
            child:Divider(
              thickness: 4,
              color: Colors.red[500],
              height: 0,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0,bottom: 5.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < post.posts.ingredients.length; i++)
                  Container(
                    alignment:Alignment.centerLeft,
                  child:Text(post.posts.ingredients[i],style: GoogleFonts.lato(fontSize: 18),
                  ),
            ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0,bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instructions',style: TextStyle(fontFamily: 'Lato',fontSize: 25, fontWeight: FontWeight.bold))
              ],
            ),
          ),
          SizedBox(
            width: 360,
            child:Divider(
              thickness: 4,
              color: Colors.red[500],
              height: 0,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0,bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < post.posts.steps.length; i++)
                  Text('${i + 1}. ${post.posts.steps[i]}',
                    style: GoogleFonts.lato(fontSize: 18),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}