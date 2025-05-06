import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'first.dart';
import 'home.dart';
import 'login.dart';
import 'register.dart';
import 'otp_verification.dart';
import 'otp_verify_email.dart';
import 'two_options.dart';
import 'retina.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'first',
    routes: {
      'first': (context) => MyFirst(),
      'register': (context) => SignupPage(),
      'login': (context) => MyLogin(),
      'home': (context) => DiabetesPredictionPage(),
      'otp_verification' : (context) => VerifyOTPPage(),
      'otp_verify_email': (context) => VerifyOTPEmailPage(),
      'two_options': (context) => Options(),
      'retina': (context) => ImageUploadPage(),
      // 'two_options.dart': (context) => const Options(),






    },
  ));
}