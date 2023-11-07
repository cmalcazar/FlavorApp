import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:favorite_button/favorite_button.dart';

import 'package:provider/provider.dart';
import 'addpost.dart';
import 'favoriteProvider.dart';

import 'post.dart';
import 'postprovider.dart';

//this is the page where the user can view the recipes as a timeline
//might change it to a list time so you can just click and it'll show who uploaded it and the recipe

class DisplayRecipe extends StatelessWidget {
  const DisplayRecipe({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const DisplayRecipePage(),
    );
  }
}

class DisplayRecipePage extends StatefulWidget {
  const DisplayRecipePage({super.key});

  @override
  State<DisplayRecipePage> createState() => _DisplayRecipeState();
}

class _DisplayRecipeState extends State<DisplayRecipePage> {
  late List<Post> posts = [];
  late final provider;
  var recipe;

  //this is the method that will be called when the user taps on the bottom navigator
  @override
  void initState() {
    super.initState();
    provider = Provider.of<PostProvider>(context, listen: false);
    posts = provider.posts;

    print(posts.length);
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
    return Scaffold(
      //This button is to add recipes
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            //This is the button that will take you to the add recipe page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddPosts()),
            );
          },
          child: const Icon(Icons.add)),
      body: Column(children: [
        Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                var post = posts[index];
                //this is the list of recipes
                return ListTile(
                  leading: Image.network(
                    post.posts.image!,
                    fit: BoxFit.cover,
                  ),
                  title: Text(post.posts.recipeName),
                  subtitle: Text(post.poster!.displayName!),
                  trailing: _like(post),
                );
              },
            )),
      ]),
    );
  }
}
