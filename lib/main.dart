import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth
import 'login.dart';
import 'sign_up.dart';
import 'welcome_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBR5JoJi_pJcndvZLoBl4DzJlpUJe8guc8",
        authDomain: "punews-4c251.firebaseapp.com",
        projectId: "punews-4c251",
        storageBucket: "punews-4c251.appspot.com",
        messagingSenderId: "301931511754",
        appId: "1:301931511754:web:b73f257e4a0de78365d933",
      ),
    );
  }
  else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthWrapper(),  // Use AuthWrapper to determine initial route
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),  // Listen to auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();  // Show a loading spinner while waiting
        } else if (snapshot.hasData) {
          return WelcomePage(userName: snapshot.data!.email!, userId: '',);  // Navigate to WelcomePage if logged in
        } else {
          return LoginPage();  // Navigate to LoginPage if not logged in
        }
      },
    );
  }
}
