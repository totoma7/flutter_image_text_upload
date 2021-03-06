import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyImagePicker(),
    );
  }
}

class MyImagePicker extends StatefulWidget {
  // MyImagePicker({Key key, required this.title}) : super(key: key);
  final String title ='';

  @override
  _MyImagePickerState createState() => _MyImagePickerState();
}

class _MyImagePickerState extends State<MyImagePicker> {
   PickedFile? _imageFile;
   final myController = TextEditingController();
   String _password ='';

   final String uploadUrl = 'http://10.0.2.2/test/upload';
  final ImagePicker _picker = ImagePicker();

  Future<String> uploadImage(filepath, url,password) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.fields['userid'] = password;
    request.files.add(await http.MultipartFile.fromPath('image', filepath));
    var res = await request.send();
    return res.reasonPhrase;
  }

  Future<void> retriveLostData() async {
    final LostData response = await _picker.getLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _imageFile = response.file;
      });
    } else {
      print('Retrieve error ' + response.exception.code);
    }
  }

  Widget _previewImage() {
    if (_imageFile != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(File(_imageFile!.path),width: 100,height: 100,),
            SizedBox(
              height: 20,
            ),
            new TextFormField(
              obscureText: false,
              decoration: new InputDecoration(labelText: '??????'),
              onSaved: (value) => _password = value!,
              controller: myController,
              keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly]
            ),
            // TextField()
            RaisedButton(
              onPressed: () async {
                print('??????  '+_password);
                var res = await uploadImage(_imageFile!.path, uploadUrl,myController.text);
                print(res);
              },
              child: const Text('Upload'),
            )
          ],
        ),
      );
    } else {
      return const Text(
        'You have not yet picked an image.',
        textAlign: TextAlign.center,
      );
    }
  }

  void _pickImage() async {
    try {
      final pickedFile = await _picker.getImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = pickedFile;
      });
    } catch (e) {
      print("Image picker error " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder<void>(
            future: retriveLostData(),
            builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Text('Picked an image');
                case ConnectionState.done:
                  return _previewImage();
                default:
                  return const Text('Picked an image');
              }
            },
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image from gallery',
        child: Icon(Icons.photo_library),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}