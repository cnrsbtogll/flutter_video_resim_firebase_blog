import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'videoplayer.dart';
import 'videoresim.dart';

class ProfilEkrani extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil Sayfası"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const VideoApp()),
                  (Route<dynamic> route) => true);
            },
          ),
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                FirebaseAuth.instance.signOut().then((deger) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => Iskele()),
                      (Route<dynamic> route) => false);
                });
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const VideoResim()),
                (Route<dynamic> route) => true);
          }),
      body: const ProfilTasarimi(),
    );
  }
}

class ProfilTasarimi extends StatefulWidget {
  const ProfilTasarimi({Key? key}) : super(key: key);

  @override
  _ProfilTasarimiState createState() => _ProfilTasarimiState();
}

class _ProfilTasarimiState extends State<ProfilTasarimi> {
  late File yuklenecekDosya;
  FirebaseAuth auth = FirebaseAuth.instance;
  var indirmeBaglantisi = null;
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => baglantiAl());
  }

  baglantiAl() async {
    String baglanti = await FirebaseStorage.instance
        .ref()
        .child("profilresimleri")
        .child(auth.currentUser!.uid)
        .child("profilresmi.png")
        .getDownloadURL();
    setState(() {
      indirmeBaglantisi = baglanti;
    });
  }

  kameradanYukle() async {
    // ImagePicker ile kameradan resim alıyoruz.
    // camera yerine gallery yazarak galeriden de resim alabiliriz.
    // ignore: deprecated_member_use
    var alinanDosya = await ImagePicker().getImage(source: ImageSource.camera);
    /* Kameradan aldığımız resmin dosya yolunu vererek, daha önce File tipinde
       tanımladığımız değişkene dosya olarak atadık. */
    setState(() {
      yuklenecekDosya = File(alinanDosya!.path);
    });
    // Bu dosyayı şimdi Firebase Storage'e yüklüyoruz.
    // child ile kasör ve belge isimlerini veriyoruz.
    Reference referansYol = FirebaseStorage.instance
        .ref()
        .child("profilresimleri")
        /* Eğer Firebase Auth kullanırsanız klasör ismi olarak
           kullanıcı id'sini veya e-posta adresini vermeniz de 
           mümkün olur. */
        .child(auth.currentUser!.uid)
        .child("profilresmi.png");

    // Yükleme görevi oluşturarak dosyayı referans yoluna koyuyoruz.
    UploadTask yuklemeGorevi = referansYol.putFile(yuklenecekDosya);
    yuklemeGorevi.whenComplete(() async {
      try {
        // url'i alıp geçici değişkene atıyoruz.
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
        child: Row(
      children: [
        ClipOval(
          child: indirmeBaglantisi == null
              ? Text("Resim Yok")
              : Image.network(indirmeBaglantisi,
                  width: 100, height: 100, fit: BoxFit.cover),
        ),
        ElevatedButton(onPressed: kameradanYukle, child: Text("Resim Yükle"))
      ],
    ));
  }
}
