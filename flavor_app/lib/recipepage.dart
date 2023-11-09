import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';

import 'package:provider/provider.dart';
import 'favoriteProvider.dart';
import 'post.dart';

//this is the page where the user can view the recipes as a timeline
//might change it to a list time so you can just click and it'll show who uploaded it and the recipe

class ShowRecipe extends StatelessWidget {
  Post post;
  ShowRecipe({
    required this.post,
    super.key,
  });

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
        ),
      ),
    );
  }
}

class ShowRecipePage extends StatefulWidget {
  Post post;
  ShowRecipePage({required this.post, super.key});

  @override
  State<ShowRecipePage> createState() => _ShowRecipeState(post: post);
}

class _ShowRecipeState extends State<ShowRecipePage> {
  Post post;
  String defaultPhoto =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2Fno-user-image.gif?alt=media&token=25a43660-490e-438d-b1c7-ad6f8c122f7d';

  _ShowRecipeState({
    required this.post,
  });

  //This is the author of the recipe
  _postAuthor() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(post.poster!.photoURL ?? defaultPhoto),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.poster!.displayName!,
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
          favs.addFav(post);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _postAuthor(),
          const SizedBox(
            height: 10,
          ),
          Image.network(post.posts.image!, fit: BoxFit.cover),
          const SizedBox(
            height: 10,
          ),
          Text(post.posts.description, style: const TextStyle(fontSize: 18)),
          const Row(
            children: [
              Text('Ingredients',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (var i = 0; i < post.posts.ingredients.length; i++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    post.posts.ingredients[i],
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
            ],
          ),
          const Row(
            children: [
              Text('Steps',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold))
            ],
          ),
          Column(
            children: [
              for (var i = 0; i < post.posts.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${i + 1}. ${post.posts.steps[i]}',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.left,
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
