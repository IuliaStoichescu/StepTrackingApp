import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class ChangeProfile extends StatefulWidget {
  const ChangeProfile({super.key});

  @override
  _ChangeProfileState createState() => _ChangeProfileState();
}

class _ChangeProfileState extends State<ChangeProfile> {
  final User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  // Profile data variables
  String name = "";
  String sex = "";
  String weight = "";
  String height = "";
  String goal = "";
  File? image;
  String imageUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
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
              "https://via.placeholder.com/150"; // Placeholder if no image
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      if (await file.exists()) {
        setState(() {
          image = file;
        });
      } else {
        print("File does not exist: ${pickedFile.path}");
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String uploadedImageUrl = imageUrl;

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
        title: const Text("Change Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFB0E0E6),
        iconTheme: const IconThemeData(
          color: Colors.white,
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
                    backgroundColor: Colors.grey[300],
                    backgroundImage: image != null
                        ? FileImage(image!)
                        : (imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl) as ImageProvider
                        : const AssetImage('assets/images/default_avatar.png')),
                    child: image == null && imageUrl.isEmpty
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                _buildEditableField("Name", name, (value) => name = value),
                const SizedBox(height: 16),
                _buildEditableField("Sex", sex, (value) => sex = value),
                const SizedBox(height: 16),
                _buildEditableField("Weight (kg)", weight, (value) => weight = value),
                const SizedBox(height: 16),
                _buildEditableField("Height (cm)", height, (value) => height = value),
                const SizedBox(height: 16),
                _buildEditableField("Goal/Notes", goal, (value) => goal = value),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFDE7B2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Save", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 20),
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

  Widget _buildEditableField(String label, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: label),
            onChanged: onSave,
          ),
        ),
        IconButton(
          icon: Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            onSave(controller.text);
          },
        ),
      ],
    );
  }
}
