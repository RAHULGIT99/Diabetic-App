import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class MyLogin extends StatefulWidget {
  const MyLogin({Key? key}) : super(key: key);
  @override
  _MyLoginState createState() => _MyLoginState();
}
class _MyLoginState extends State<MyLogin> {
  String email = '';
  String pass = '';
  bool isPasswordVisible = false;
  String errorMessage = ''; // New variable to store error message
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
                decoration: const InputDecoration(hintText: 'Email'),
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    pass = value;
                  });
                },
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    child: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: email,
                      password: pass,
                    );

                    // Check if the login was successful
                    if (userCredential != null) {
                      // Always navigate to '/home' after a successful login
                      Navigator.pushNamed(context, "two_options");
                    } else {
                      // Handle unexpected case (userCredential is null)
                      print('Unexpected error: userCredential is null');
                    }
                  } on FirebaseAuthException catch (e) {
                    // Handle error messages
                    setState(() {
                      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                        errorMessage = 'Invalid email or password. Please try again.';
                      } else {
                        errorMessage = 'An unexpected error occurred. Please try again later.';
                      }
                    });
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
