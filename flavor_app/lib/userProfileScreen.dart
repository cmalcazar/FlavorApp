import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}
class _UserProfileScreenState extends State<UserProfileScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();

  //define profilePictureKey
  final GlobalKey<RefreshIndicatorState> profilePictureKey = GlobalKey<RefreshIndicatorState>();

  //all users will start with this default profile photo
  String defaultPhoto =
      'https://firebasestorage.googleapis.com/v0/b/recipeapp-3ab43.appspot.com/o/images%2Fno-user-image.gif?alt=media&token=25a43660-490e-438d-b1c7-ad6f8c122f7d';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FirebaseAuth>(context);
    final User? user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _triggerRefresh,
        child: FutureBuilder(
          key: profilePictureKey,
          future: getUserData(user!.uid),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //red loading indicator while data gets displayed
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            //after fetching user data, store it in userData
            final userData = snapshot.data ?? {};
            //check if 'profileImage' is empty in Firestore collection
            //all users will start with an "empty" profile picture since we
            //don't ask for one when creating an account
            String userPhoto = (userData['profileImage'] != null && userData['profileImage'] != '')
                ? userData['profileImage']
                : defaultPhoto;

            //favorites array since we are going to use it below
            List<dynamic> favorites = userData['favorites'] ?? [];

            return Center(
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      //space between top of screen and profile picture
                      padding: const EdgeInsets.only(top: 25.0),
                      //stack camera icon on top of profile picture
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 135,
                            //profile picture
                            backgroundImage: NetworkImage('$userPhoto?${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(1000)}'),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => _updateProfilePicture(context),
                              child: CircleAvatar(
                                radius: 30,
                                //while waiting to display the profile picture
                                //the circle avatar background color will be red
                                //it might take some second to actually display the image
                                backgroundColor: Colors.red,
                                child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //small space
                    SizedBox(height: 10),

                    UserInfoRow(
                      label: 'Username',
                      data: userData['username'],
                      icon: Icons.person,
                    ),
                    //small space
                    SizedBox(height: 10),

                    UserInfoRow(
                      label: 'Email',
                      data: user?.email,
                      icon: Icons.email,
                    ),
                    //small space
                    SizedBox(height: 10),

                    UserInfoRow(
                      label: 'Location',
                      data: userData['location'],
                      icon: Icons.location_on,
                    ),

                    //small space
                    SizedBox(height: 10),

                    UserInfoRow(
                      label: 'Favorites',
                      data: favorites.length.toString(),
                      icon: Icons.favorite,
                    ),
                  ],
                ),
                ),
            );
          }
          },
        ),
      ),
    );
  }

  Future<void> _triggerRefresh() async {
    setState(() {});
  }

  //update user's profile picture
  //(similar to "addpost" when uploading a recipe image)
  Future<void> _updateProfilePicture(BuildContext context) async {
    print('Updating profile picture...');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      File imageFile = File(result.files.single.path!);

      //retrieve authenticated user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        //upload the new selected image file to Firebase Storage
        final storage = FirebaseStorage.instance;
        final path = 'profileImages/${user.uid}.png';

        UploadTask uploadTask = storage.ref().child(path).putFile(imageFile);

        //wait for upload to complete
        await uploadTask.whenComplete(() => null);

        //get the download URL of the uploaded image
        String downloadURL = await storage.ref(path).getDownloadURL();

        //update the 'profileImage' field in Firestore with the download URL
        //if there is no field yet, it creates it
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImage': downloadURL});

        //print the image URL
        print('Image URL: $downloadURL');

        //trigger refresh
        _triggerRefresh();

        //snackBar with a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully updated profile picture!'),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  //get user data from Firestore
  Future<Map<String, dynamic>> getUserData(String uid) async {
      var querySnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      var uData = querySnapshot.data() ?? {};
      return uData;
    }
  }

  //styles font colors and icons
class UserInfoRow extends StatelessWidget {
  final String label;
  final String? data;
  final IconData icon;

  UserInfoRow({required this.label, required this.data, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 25,
        ),
        SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 25,
          ),
        ),
        Text(
          data ?? '',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
      ],
    );
  }
}