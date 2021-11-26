import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VideoResim extends StatelessWidget {
  const VideoResim({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Ekleme Sayfası")),
      body: VideoEkrani(),
    );
  }
}

class VideoEkrani extends StatefulWidget {
  const VideoEkrani({Key? key}) : super(key: key);

  @override
  _VideoEkraniState createState() => _VideoEkraniState();
}

class _VideoEkraniState extends State<VideoEkrani> {
  late File yuklenecekDosya;
  FirebaseAuth auth = FirebaseAuth.instance;
  var indirmeBaglantisi = null;
  kameradadanVideoYukle() async {
    // ignore: deprecated_member_use
    var alinanDosya = await ImagePicker().getVideo(source: ImageSource.camera);
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });
    Reference referansYol =
        FirebaseStorage.instance.ref().child("videolar").child("videom.mp4");
    UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
    yuklemeGorevi.whenComplete(() async {
      try {
        String url = await referansYol.getDownloadURL();
        setState(() {
          indirmeBaglantisi = url;
        });
      } catch (onError) {
        print("Error");
      }
      print("Image Url:" + indirmeBaglantisi);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ElevatedButton(
              child: Text("Video Yükle"), onPressed: kameradadanVideoYukle),
        ],
      ),
    );
  }
}
