import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VerifyOTPPage extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();

  VerifyOTPPage({Key? key});

  Future<void> _verifyOTPAndCreateUser(
      BuildContext context,
      String verificationId,
      String smsCode,
      String name,
      String age,
      String email,
      String password,
      String phoneNumber) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // If sign-in successful, create the user account
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // You can perform additional checks or validation before creating the user

        // Create user in Firebase Authentication
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Save user information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'age': age,
          'email': email,
          'phoneNumber': phoneNumber, // Include phone number in user data
          // You can add more fields here
        });

        // Navigate to the success page
        Navigator.pushReplacementNamed(context, 'home');
      } else {
        print('User not found or verification failed.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid OTP. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      print('Error verifying OTP and creating user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String verificationId = args['verificationId'];
    final String name = args['name'];
    final String age = args['age'];
    final String email = args['email'];
    final String password = args['password'];
    final String phoneNumber =
    args['phoneNumber']; // Get phone number from arguments

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                _verifyOTPAndCreateUser(
                  context,
                  verificationId,
                  otpController.text,
                  name,
                  age,
                  email,
                  password,
                  phoneNumber, // Pass phone number to the function
                );
              },
              child: const Text('Verify OTP & Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
