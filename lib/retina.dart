import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
// void main() {
//   runApp(MyApp());
// }
class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;

  // Function to open the image picker
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Function to send the image to the Flask app
  Future<void> _sendImage() async {
    if (_image == null) {
      // Handle case where no image is selected
      return;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.16.91:5000/predict'), // Replace with your Flask server URL
    );
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Prediction result: ${await response.stream.bytesToString()}');
      } else {
        print('Failed to send image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Image Upload'),
        ),
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image == null
                    ? Text('No image selected.')
                    : Image.file(
                  _image!,
                  height: 200,
                  width: 200,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendImage,
                  child: Text('Send Image to Flask'),
                ),
              ],
            ),
            ),
        );
    }
}