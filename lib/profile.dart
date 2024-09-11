import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String userName;
  final String email;

  ProfilePage({required this.userId, required this.userName, required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('Initializing ProfilePage');
    _loadUserProfile();  // Load profile when page initializes
  }

  void _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.userId)
          .get();
      print('Document exists: ${userDoc.exists}');
      if (userDoc.exists) {
        print('User data: ${userDoc.data()}');
        setState(() {
          _userNameController.text = userDoc['userName'] ?? widget.userName;
          _emailController.text = userDoc['email'] ?? widget.email;
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Updating user profile for userId: ${widget.userId}');
      print('New userName: ${_userNameController.text}');
      print('New email: ${_emailController.text}');

      await FirebaseFirestore.instance.collection('Users').doc(widget.userId).update({
        'userName': _userNameController.text,
        'email': _emailController.text,
      });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully!')));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the drawer icon here
        ),
        title: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,  // Set the title text color to white
            )),
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/profile_pic.jpg'), // Fixed profile image
            ),
            SizedBox(height: 20),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
