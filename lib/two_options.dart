import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Options extends StatelessWidget {
  const Options({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            if (user != null)
              const Text('') //${user.email}!
            else
              const Text('Please login or register'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'home'); // Change to the correct route name
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue[900],
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: Size(200, 60),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Machine Learning'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, 'retina');
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                minimumSize: Size(200, 60),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text('Retinopathy'),
            ),
          ],
        ),
      ),
    );
  }
}
