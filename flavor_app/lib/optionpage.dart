import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';
import 'displayRecipe.dart';
import 'userfavorites.dart';
import 'userProfileScreen.dart';

import 'main.dart';
import 'search.dart';

//This is the option page where the bottom navigator is located
class OptionPage extends StatelessWidget {
  const OptionPage({super.key});

  //this will be where the user can "sign out"
  options() {}
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<FirebaseAuth>(context);
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.red),
                    child: Text(
                      'Menu',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    )),
                ListTile(
                  leading: const Icon(
                    Icons.account_circle,
                    color: Colors.red,
                    opticalSize: 10.5,
                  ),
                  title: const Text(
                    'My Profile',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.exit_to_app_sharp,
                    color: Colors.red,
                    opticalSize: 10.5,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(fontSize: 20),
                  ),
                  onTap: () {
                    auth.signOut();
                    print('Current user: ${auth.currentUser!}');
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            title: const Text(
              'Flavor',
              style: TextStyle(fontSize: 40),
            ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
            ],
          ),
          body: const Pages()),
    );
  }
}

class Pages extends StatefulWidget {
  const Pages({super.key});

  @override
  State<Pages> createState() => _PageState();
}

class _PageState extends State<Pages> {
  int _currentIndex = 0;

  //This is the list of pages that will be displayed on the bottom navigator
  //if you want to add an extra page and bottom navigation
  // you will need to add a new page and add it to the list
  //then add a new icon to the bottom navigator
  final List<Widget> _pages = [
    const DisplayRecipePage(),
    const UserFavoritesPage(),
    const SearchPage()
  ];

  late final authUser;

  //This is the method that will be called when the user taps on the bottom navigator
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginSuccess();
  }

  loginSuccess() {
    //this is the method that will be called when the user logs in
    //so we can see the green snackbar and shows us whose currently logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<FirebaseAuth>(context, listen: false);
      User? user = auth.currentUser;
      if (user != null) {
        print('Logged in user: ${user.email}');
      } else {
        print('No user is logged in.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //this is the bottom navigator
      // Add "BottomNavigationBarItem" to add more icons
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
          ],
          currentIndex: _currentIndex,
          selectedItemColor: Colors.red,
          onTap: _onItemTapped),
    );
  }
}
