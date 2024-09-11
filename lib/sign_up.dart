import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google Sign-In
import 'package:fluttertoast/fluttertoast.dart';
import 'welcome_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // GoogleSignIn instance
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();

                try {
                  // Register user using FirebaseAuth
                  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  User? user = userCredential.user;
                  String userId = user!.uid;  // Get the user's UID

                  // Store user data in Firestore
                  await FirebaseFirestore.instance.collection('Users').doc(userId).set({
                    "email": email,
                    "pass": password,
                    "uid": userId,
                    "userName": "User",  // Default value set to "User"
                  });

                  // Navigate to WelcomePage with userId
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WelcomePage(
                        userName: email,
                        userId: userId,  // Pass the userId to WelcomePage
                      ),
                    ),
                  );
                } catch (e) {
                  showToast(getFriendlyErrorMessage(e));
                }
              },
              child: Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleGoogleSignUp(), // Call Google Sign-In
              child: Text('Sign Up with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to display toast messages
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Function to map error codes to user-friendly messages
  String getFriendlyErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'This email is already in use. Please use a different email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password is too weak. Please choose a password with at least 6 characters.';
        default:
          return 'An error occurred. Please try again.';
      }
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Google Sign-In method
  Future<void> _handleGoogleSignUp() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        String userId = user.uid;  // Get the user's UID

        // Store user data in Firestore
        await FirebaseFirestore.instance.collection('Users').doc(userId).set({
          "email": user.email,
          "userName": user.displayName,
          "uid": userId,
          // You can store additional user info here
        });

        // Navigate to WelcomePage with userId
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WelcomePage(
              userName: user.email!,
              userId: userId,  // Pass the userId to WelcomePage
            ),
          ),
        );
      }
    } catch (e) {
      showToast(getFriendlyErrorMessage(e));
    }
  }
}
