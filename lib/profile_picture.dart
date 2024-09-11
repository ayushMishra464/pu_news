import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager {
  static const _profilePictureKey = 'profile_picture';

  // Method to pick an image using ImagePicker
  Future<File?> pickProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Method to save the image path to SharedPreferences
  Future<void> saveProfilePicture(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profilePictureKey, imagePath);
  }

  // Method to get the saved profile picture path from SharedPreferences
  Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePictureKey);
  }

  // Method to remove the saved profile picture (optional)
  Future<void> removeProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profilePictureKey);
  }
}
