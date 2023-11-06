import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'favoriteProvider.dart';

//THis is the user favorites class
class UserFavorites extends StatelessWidget {
  const UserFavorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Favorites',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const Scaffold(body: UserFavoritesPage()),
    );
  }
}

class UserFavoritesPage extends StatefulWidget {
  const UserFavoritesPage({super.key});

  @override
  State<UserFavoritesPage> createState() => _UserFavoritesPageState();
}

class _UserFavoritesPageState extends State<UserFavoritesPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context, listen: false);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            //This is the list of recipes that the user has favorited
              child: ListView.builder(
                itemCount: provider.recipes.length,
                itemBuilder: (BuildContext context, int index) {
                  var post = provider.recipes[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        //This is the list of recipes that the user has favorited
                        //via list tile
                        ListTile(
                          title: Text(post.posts.recipeName),
                          subtitle: Text(post.posts.description),
                          trailing: FavoriteButton(
                            iconColor: Colors.pinkAccent.shade400,
                            iconSize: 35.5,
                            isFavorite: post.posts.isFavorite,
                            valueChanged: (fav) {
                              post.posts.isFavorite = fav;
                              if (fav) {
                                post.posts.canAdd = false;
                              }
                              provider.addFav(post);
                            },
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  );
                },
              ))
        ],
      ),
    );
  }
}
