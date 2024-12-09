import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool isLoginMode = true; // Toggle between Login and Sign Up
  bool isLoading = false; // Loading indicator

  Future<void> _authenticate() async {
    if (!_validateInputs()) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isLoginMode) {
        // Login logic
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fetch username from Firestore after successful login
        DocumentSnapshot userDoc = await _firestore.collection('user_info').doc(userCredential.user!.uid).get();
        if (userDoc.exists) {
          String username = userDoc['username'] ?? 'Unknown';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome back, $username!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User data not found in Firestore")),
          );
        }

        Navigator.pushNamed(context, '/mainPage');
      } else {
        // Sign-up logic
        final String email = _emailController.text.trim();
        final String password = _passwordController.text.trim();
        final String username = _usernameController.text.trim();

        // Create user in Firebase Auth
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save user info in Firestore
        await _firestore.collection('user_info').doc(userCredential.user!.uid).set({
          'username': username,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created Successfully!")),
        );
        Navigator.pushNamed(context, '/mainPage');
      }
    } on FirebaseAuthException catch (e) {
      // Firebase-specific errors
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = "No user found for that email.";
          break;
        case 'wrong-password':
          errorMessage = "Wrong password provided.";
          break;
        case 'email-already-in-use':
          errorMessage = "The account already exists for that email.";
          break;
        default:
          errorMessage = "An error occurred. Please try again.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Input validation
  bool _validateInputs() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (!isLoginMode && _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username cannot be empty")),
      );
      return false;
    }

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email and password cannot be empty")),
      );
      return false;
    }

    if (!isLoginMode && password != _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLoginMode ? "Welcome Back!" : "Create Account",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!isLoginMode) ...[
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                      ),
                      if (!isLoginMode) ...[
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: true,
                        ),
                      ],
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: isLoading ? null : _authenticate,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                          elevation: 5,
                          backgroundColor: isLoading ? Colors.grey : Colors.deepPurpleAccent,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLoginMode ? Icons.login : Icons.person_add,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isLoginMode ? "Login" : "Sign Up",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLoginMode = !isLoginMode;
                          });
                        },
                        child: Text(
                          isLoginMode
                              ? "Don't have an account? Sign Up"
                              : "Already have an account? Login",
                          style: const TextStyle(color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
