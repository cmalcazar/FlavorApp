import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'postprovider.dart';
import 'package:image_picker/image_picker.dart';

import 'Recipe.dart';
import 'post.dart';

//This is the page to add recipes
class AddPosts extends StatelessWidget {
  const AddPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),

          //this is the back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(
                context,
              );
            },
          ),
          actions: [
            //this is the settings button
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        ),
        body: PostPage(),
      ),
    );
  }
}

class PostPage extends StatefulWidget {
  PostPage({Key? key}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  //this is the form keys for all input in the TextForms
  final GlobalKey<FormFieldState<String>> _recipeName = GlobalKey();
  late String image = '';
  final GlobalKey<FormFieldState<String>> _minutes = GlobalKey();
  final GlobalKey<FormFieldState<String>> _ingredients = GlobalKey();
  final GlobalKey<FormFieldState<String>> _tags = GlobalKey();
  final GlobalKey<FormFieldState<String>> _steps = GlobalKey();
  final GlobalKey<FormFieldState<String>> _description = GlobalKey();
  final GlobalKey<FormFieldState<String>> _nutrition = GlobalKey();
  final picker = ImagePicker();
  XFile? _imageFile;

  //this is the user and database variables
  late final authUser;
  late final db;
  var userData;
  int _postId = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUser();

// Prints the u
  }

  //this for when the user uploads a photo from their phone gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final storage = Provider.of<FirebaseStorage>(context, listen: false);
    setState(() {
      if (pickedFile != null) {
        _imageFile = XFile(pickedFile.path);
      }
    });
    final ref = storage.ref().child('images/${auth.currentUser!.uid}');
    await ref.putFile(File(_imageFile!.path));
    final url = await ref.getDownloadURL();
    setState(() {
      image = url;
    });
  }

  //this is for when the user uploads a photo from their camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final storage = Provider.of<FirebaseStorage>(context, listen: false);
    setState(() {
      if (pickedFile != null) {
        _imageFile = XFile(pickedFile.path);
      }
    });
    //adds to firebase storage NOT firestore database
    final ref = storage.ref().child('images/${auth.currentUser!.uid}');
    await ref.putFile(File(_imageFile!.path));
    final url = await ref.getDownloadURL();
    setState(() {
      image = url;
    });
  }

  //This is the options for the user to select where they want to upload their photo from
  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  //This is to get the user and database
  setUser() {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final dbF = Provider.of<FirebaseFirestore>(context, listen: false);
    authUser = auth.currentUser;
    print(authUser!.email);
    db = dbF;
  }

  //This is to generate a random id for the recipe
  generateId() {
    var random = Random();
    int randomNumber = random.nextInt(1000000);

    setState(() {
      _postId = randomNumber;
    });
  }

  //This is just to try to get the data from the database so that we can simulate a search
  //and adding more recipes to an already poopulated list. Haven't figured it out
  //or finished it yet.
  extraData() {
    final post = Provider.of<PostProvider>(context, listen: false);

    for (int i = 0; i < 10; i++) {
      FutureBuilder<DocumentSnapshot>(
        future: db.collection('recipes').doc(i.toString()).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return const Text(
              "Done",
              style: TextStyle(fontSize: 30),
              textAlign: TextAlign.left,
            );
          }
          return const CircularProgressIndicator();
        },
      );
    }
  }

  //This is to submit the post to the database and add it to the list of posts
  void _submitPost(var userData) {
    final post = Provider.of<PostProvider>(context, listen: false);

    generateId();
    post.addPost(Post(
      //this is the poster ID
        poster: userData,
        posts: Recipe(
          recipeName: _recipeName.currentState!.value!,
          ingredients: _ingredients.currentState!.value!.split(',').toList(),
          recipeId: _postId,
          minutes: int.parse(_minutes.currentState!.value!),
          nutrition: _nutrition.currentState!.value!
              .split(',')
              .map((e) => double.tryParse(e) ?? 0.0)
              .toList(),
          image: image,
          description: _description.currentState!.value!,
          tags: _tags.currentState!.value!.split(',').toList(),
          steps: _steps.currentState!.value!.split(',').toList(),
          canAdd: true,
          isFavorite: false,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
              children: [
                //This is the image picker
                TextButton(
                  child: Text('Select Image'),
                  onPressed: showOptions,
                ),

                //THis is the recipe name
                TextFormField(
                  key: _recipeName,
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Name of recipe',
                      icon: Icon(Icons.food_bank)),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    print(value);
                    Navigator.pop(context);
                  },
                ),

                //This is the cook time
                TextFormField(
                  key: _minutes,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.timer),
                      labelText: 'Cook time',
                      hintText: 'How long to cook ex. 55 (minutes))'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a time';
                    }
                    return null;
                  },
                ),

                //this is the ingredients
                TextFormField(
                  key: _ingredients,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.food_bank_rounded),
                      labelText: 'Ingredients',
                      hintText: "ex. '3lbs tamales', comma separated "),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter atleast one ingredient';
                    }
                    return null;
                  },
                ),

                //This is the tags
                TextFormField(
                  key: _tags,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.tag),
                      labelText: 'Tags',
                      hintText: "ex. 'mexican', comma separated "),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter atleast one tag';
                    }
                    return null;
                  },
                ),

                //This is the steps
                TextFormField(
                  key: _steps,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.list),
                      labelText: 'Steps',
                      hintText: "ex. '1.pour broth,', comma separated"),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter at least one step';
                    }
                    return null;
                  },
                ),

                //This is the description
                TextFormField(
                  key: _description,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.description),
                      labelText: 'Description',
                      hintText: 'Describe recipe'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                //This is the nutrition
                TextFormField(
                  key: _nutrition,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.inventory),
                      labelText: 'Nutrition',
                      hintText:
                      "ex. 51.0 (calories (#), total fat, sugar, sodium, protein, saturated fats), comma separated "),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter atleast one nutrition value';
                    }
                    return null;
                  },
                ),

                //This is the submit button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      //THis is to submit the post with the user displayname
                      _submitPost(authUser!.displayName);
                    });
                  },
                  child: const Text('Submit'),
                )
              ],
            )));
  }
}
