import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late File _image;
  final picker = ImagePicker();
  final TextEditingController commentController = TextEditingController();

  Future<void> _captureImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final response = await http.post(
        'https://flutter-sandbox.free.beeceptor.com/upload_photo/',
        body: {
          'comment': commentController.text,
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
        },
        // Attach the image file to the request
        files: [
          http.MultipartFile.fromBytes(
            'photo',
            await _image.readAsBytes(),
            filename: 'photo.png',
          ),
        ],
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Upload successful');
      } else {
        Fluttertoast.showToast(msg: 'Upload failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _image != null
                ? Image.file(_image, height: 200, width: 200, fit: BoxFit.cover)
                : Placeholder(fallbackHeight: 200, fallbackWidth: 200),
            SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: 'Enter your comment',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _captureImage();
                await _uploadData();
              },
              child: Text('Capture and Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
