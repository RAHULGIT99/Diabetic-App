import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_otp/email_otp.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}
class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // New variables to store the selected OTP method
  String otpMethod = 'phone'; // Default to phone

  Future<void> _sendOTP(BuildContext context) async {
    try {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Passwords do not match.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      if (otpMethod == 'phone') {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+${phoneController.text}',
          verificationCompleted: (PhoneAuthCredential credential) async {},
          verificationFailed: (FirebaseAuthException e) {
            print('Phone number verification failed: ${e.message}');
          },
          codeSent: (String verificationId, int? resendToken) async {
            Navigator.pushReplacementNamed(
              context,
              'otp_verification', // Update with the correct route
              arguments: {
                'verificationId': verificationId,
                'phoneNumber': phoneController.text,
                'name': nameController.text,
                'age': ageController.text,
                'email': emailController.text,
                'password': passwordController.text,
              },
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      } else if (otpMethod == 'email') {
        EmailOTP myauth = EmailOTP();
        myauth.setConfig(
          appEmail: "me@rohitchouhan.com",
          appName: "Email OTP",
          userEmail: emailController.text,
          otpLength: 6,
          otpType: OTPType.digitsOnly,
        );

        // Send OTP
        if (await myauth.sendOTP() == true) {
          Navigator.pushReplacementNamed(
            context,
            'otp_verify_email',
            arguments: {
              'phoneNumber': phoneController.text,
              'name': nameController.text,
              'age': ageController.text,
              'email': emailController.text,
              'password': passwordController.text,
              'emailOTPInstance': myauth, // Pass the EmailOTP instance
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Oops, OTP send failed'),
            ),
          );
        }
      }
    } catch (e) {
      // Handle exceptions
      print('Error sending OTP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            Row(
              children: [
                Radio(
                  value: 'phone',
                  groupValue: otpMethod,
                  onChanged: (value) {
                    setState(() {
                      otpMethod = value as String;
                    });
                  },
                ),
                Text('Phone'),
                Radio(
                  value: 'email',
                  groupValue: otpMethod,
                  onChanged: (value) {
                    setState(() {
                      otpMethod = value as String;
                    });
                  },
                ),
                Text('Email'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _sendOTP(context);
              },
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
