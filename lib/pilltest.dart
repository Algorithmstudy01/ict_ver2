import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;



class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final picker = ImagePicker();
  String _pillCode = '';
  String _pillName = '';
  String _confidence = '';
  String _extractedText = '';
  bool _isLoading = false; // Flag to track loading state

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _pillCode = '';      // Reset values for new image
        _pillName = '';
        _confidence = '';
        _extractedText = '';
        _isLoading = true;   // Start loading
      });

      await _uploadImage(_image!);
    }
  }

  Future<void> _uploadImage(File image) async {
    final url = Uri.parse('https://80d4-113-198-180-184.ngrok-free.app/predict2/'); // Ensure this URL is correct

    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);

        setState(() {
          final pillInfo = decodedData['pill_info'];
          _pillCode = pillInfo['code'] ?? 'Unknown';
          _pillName = pillInfo['name'] ?? 'Unknown';
          _confidence = decodedData['confidence']?.toString() ?? 'Unknown';
          _extractedText = decodedData['extracted_text']?.toString() ?? 'No text found';
          _isLoading = false; // Stop loading
        });
      } else {
        setState(() {
          _pillCode = 'Error: ${response.statusCode}';
          _pillName = 'Error';
          _confidence = 'Error';
          _extractedText = 'Error';
          _isLoading = false; // Stop loading
        });
      }
    } catch (e) {
      setState(() {
        _pillCode = 'Error: $e';
        _pillName = 'Error';
        _confidence = 'Error';
        _extractedText = 'Error';
        _isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Image Upload'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Text('No image selected.')
                  : Container(
                      constraints: BoxConstraints(maxHeight: 300), // Image maximum height limit
                      child: Image.file(_image!),
                    ),
              SizedBox(height: 20),
              if (_isLoading) // Show loading indicator if loading
                CircularProgressIndicator(),
              if (!_isLoading) ...[
                Text(
                  'Pill Code: $_pillCode',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  'Pill Name: $_pillName',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  'Confidence: $_confidence',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  'Extracted Text: $_extractedText',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
