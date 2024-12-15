import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class ChangeProfile extends StatefulWidget {
  @override
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user
  final _formKey = GlobalKey<FormState>();

  // Profile data variables
  String name = "";
  String sex = ""; // Dropdown value
  String weight = "";
  String height = "";
  String goal = "";
  File? image; // Local image file
  String imageUrl = ""; // URL for profile image stored in Firebase

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fetch existing profile data
  void _fetchProfileData() async {
    try {
      final profileSnapshot = await FirebaseFirestore.instance
          .collection("user_info")
          .doc(user?.uid)
          .collection("profile")
          .doc("details")
          .get();

      if (profileSnapshot.exists) {
        final data = profileSnapshot.data();
        setState(() {
          name = data?['username'] ?? "";
          sex = data?['sex'] ?? "";
          weight = data?['weight'] ?? "";
          height = data?['height'] ?? "";
          goal = data?['goal'] ?? "";
          imageUrl = data?['imageUrl'] ??
              "https://via.placeholder.com/150"; // Default placeholder image
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  // Save updated profile data
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save form data

      String uploadedImageUrl = imageUrl;

      // Upload image to Firebase Storage if a new image is selected
      if (image != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_pictures/${user?.uid}.jpg');
          await storageRef.putFile(image!);
          uploadedImageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          print("Error uploading image: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to upload image")),
          );
        }
      }

      // Save data to Firestore
      try {
        final profileRef = FirebaseFirestore.instance
            .collection("user_info")
            .doc(user?.uid)
            .collection("profile")
            .doc("details");

        await profileRef.set({
          "username": name,
          "email": user?.email,
          "imageUrl": uploadedImageUrl,
          "sex": sex,
          "weight": weight,
          "height": height,
          "goal": goal,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context); // Go back after saving
      } catch (e) {
        print("Error saving profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update profile")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Profile",style: TextStyle(color: Colors.white),),
        backgroundColor: Color(0xFFB0E0E6),
        iconTheme: const IconThemeData(
          color: Colors.white, // Changes the back arrow color to white
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: image != null
                        ? FileImage(image!)
                        : NetworkImage(imageUrl) as ImageProvider,
                    child: image == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: "Name"),
                  validator: (value) =>
                  value!.isEmpty ? "Name cannot be empty" : null,
                  onSaved: (value) => name = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: sex.isNotEmpty ? sex : null,
                  decoration: const InputDecoration(labelText: "Sex"),
                  items: const [
                    DropdownMenuItem(value: "Male", child: Text("Male")),
                    DropdownMenuItem(value: "Female", child: Text("Female")),
                    DropdownMenuItem(
                        value: "Prefer not to say",
                        child: Text("Prefer not to say")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sex = value!;
                    });
                  },
                  validator: (value) =>
                  value == null ? "Please select a gender" : null,
                ),
                TextFormField(
                  initialValue: weight,
                  decoration: const InputDecoration(labelText: "Weight (kg)"),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => weight = value!,
                ),
                TextFormField(
                  initialValue: height,
                  decoration: const InputDecoration(labelText: "Height (cm)"),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => height = value!,
                ),
                TextFormField(
                  initialValue: goal,
                  decoration: const InputDecoration(labelText: "Goal/Notes"),
                  maxLines: 2,
                  onSaved: (value) => goal = value!,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFDE7B2), // Soft yellow color
                    foregroundColor: Colors.black,     // Text color (for contrast)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Optional: Rounded corners
                    ),
                  ),
                  child: const Text("Save", style: TextStyle(color: Colors.grey),),
                ),
                const SizedBox(height: 20),
                // Add Lottie Animation
                Lottie.asset(
                  'assets/animations/change_profile.json',
                  width: 300,
                  height: 300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
