import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';
import 'personalDataField.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const CreateAccountPage(),
    );
  }
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final GlobalKey<FormFieldState<String>> _email = GlobalKey();
  final GlobalKey<FormFieldState<String>> _pass = GlobalKey();
  final GlobalKey<FormFieldState<String>> _user = GlobalKey();
  final GlobalKey<FormFieldState<String>> _loc = GlobalKey();

  success() {
    return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Account created successfully!'),
      backgroundColor: Colors.green,
    ));
  }

  createUser() async {
    final auth = Provider.of<FirebaseAuth>(context, listen: false);
    final db = Provider.of<FirebaseFirestore>(context, listen: false);
    String message = '';
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _email.currentState!.value!,
        password: _pass.currentState!.value!,
      );

      User? user = userCredential.user;
      user!.updateDisplayName(_user.currentState!.value!);

      if (userCredential.additionalUserInfo!.isNewUser) {
        print('Successfully created an account!');
        print('User ID: ${user.uid}');
        print('Email: ${user.email}');
        db.collection('users').doc(user.uid).set({
          'username': _user.currentState!.value!,
          'email': _email.currentState!.value!,
          'favorites': [],
          'location': _loc.currentState!.value!,
          'uid': user.uid,
        });
        success();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'Invalid email or password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      print(e);
    }
  }

  submitReg() {
    final isValid = _email.currentState?.validate();
    final isValids = _pass.currentState?.validate();
    final isValidss = _user.currentState?.validate();
    if (!isValid! || !isValids! || !isValidss!) {
      return false;
    }
    _user.currentState?.save();
    _pass.currentState?.save();
    _email.currentState?.save();
    return true;
  }

  get values => {
    'Email': _email.currentState?.value,
    'Password': _pass.currentState?.value,
    'Username': _user.currentState?.value
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 100.0),
                child: Text(
                  'Flavor',
                  style: TextStyle(
                    fontSize: 60.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Create your account',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            //USERNAME FIELD
            PersonalDataField(
              keyField: _user, 
              labelText: 'Username', 
              hintText: 'ex. JohnDoe123', 
              errorMessage: 'Please enter a username', 
              icon: Icons.person),

            //EMAIL FIELD
            PersonalDataField(
              keyField: _email, 
              labelText: 'Email', 
              hintText: 'ex. johndoe123@yahoo.com', 
              errorMessage: 'Please enter an email', 
              icon: Icons.email),
            
            //PASSWORD FIELD
            PersonalDataField(
              keyField: _pass, 
              labelText: 'Password', 
              hintText: 'Enter your password', 
              errorMessage: 'Password is required', 
              icon: Icons.lock),

            //LOCATION FIELD
            PersonalDataField(
              keyField: _loc,
              labelText: 'Location',
              hintText: 'ex. New York, NY',
              icon: Icons.location_on,
              errorMessage: 'Location is required'),
            
            const SizedBox(height: 20.0),
            
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
                shape: MaterialStateProperty.all(const StadiumBorder()),
                textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 17)),
                fixedSize: MaterialStateProperty.all(const Size(200, 50))),
              onPressed: () async {
                if (createUser().call() && submitReg()) {
                  print(values);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                }
              },
              child: const Text(
                'Create Account',
                style: TextStyle(color: Colors.black)),
            ),
             const SizedBox(height: 30.0,),
             const Text(
              'Already an existing member?',
              style: TextStyle(fontStyle: FontStyle.italic),
             ),
             const SizedBox(height: 10.0),
             ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.deepOrange),
                shape: MaterialStateProperty.all(const StadiumBorder()),
                textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 17)),
                fixedSize: MaterialStateProperty.all(const Size(200, 50))),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Login()));
              },
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
