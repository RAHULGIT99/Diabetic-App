import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class MyFirst extends StatelessWidget {
  const MyFirst({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hello there!',
              style: TextStyle(fontSize:40, fontWeight: FontWeight.bold ),
            ),
            const SizedBox(height: 32),
            if (user != null)
              const Text('Welcome')//${user.email}!
            else
              const Text('Please login or register'),
            const SizedBox(height: 32),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'login');
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[900], // Dark Blue
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                  minimumSize: Size(200, 60),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Login')),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'register');
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // Red
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Rounded corners
                  ),
                  minimumSize: Size(200, 60),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Register')),
          ],
        ),
      ),
    );
  }
}
