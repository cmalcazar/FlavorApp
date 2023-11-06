import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
          print(favs.recipes.length);
        },
      ),
    );
  }

  //This is the description of the recipe
  _postDescription(var post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(post.posts.description, style: const TextStyle(fontSize: 16)),
    );
  }

  //this is the image of the recipe
  // _postImage(var index) {
  //   return Column(
  //     children: <Widget>[
  //       Image.network(
  //           'https://pixabay.com/photos/spaghetti-tomatoes-basil-1932466/'),
  //     ],
  //   );
  // }

  //This is the author of the recipe
  _postAuthor(var post) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage("https://picsum.photos/200"),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.poster,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  //this is the view of the recipe
  _postView(var post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _postAuthor(post),
        // _postImage(post),
        _postDescription(post),
        _like(post)
      ],
    );
  }

  //this is the list view of the recipe
  _postListView(var posts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _postView(posts),
      ],
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
                return _postListView(post);
              },
            )),
      ]),
    );
  }
}
