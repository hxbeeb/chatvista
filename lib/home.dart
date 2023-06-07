import 'dart:convert';
import 'dart:io';

import 'package:chatvista/chat.dart';
import 'package:chatvista/main.dart';
import 'package:chatvista/post.dart';
import 'package:chatvista/profile.dart';
import 'package:chatvista/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class home extends StatefulWidget {
  var c;
  home({super.key, required this.c});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home>with WidgetsBindingObserver {
  static FirebaseMessaging m = FirebaseMessaging.instance;
  Future<void> getm() async {
    await m.requestPermission();
    await m.getToken().then((value) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"token": value as String});

      print(value);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getm();
    // SystemChannels.lifecycle.setMessageHandler((message) {
    //   if (message.toString().contains("resume")) {
    //     FirebaseFirestore.instance
    //         .collection("users")
    //         .doc(FirebaseAuth.instance.currentUser!.uid)
    //         .update({"active": true});
    //   }
    //   if (message.toString().contains("pause")) {
    //     FirebaseFirestore.instance
    //         .collection("users")
    //         .doc(FirebaseAuth.instance.currentUser!.uid)
    //         .update({"active": true});
    //   }
    //   return Future.value(message);
    // });
  }

  String pic = "";
  void upload() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 100);
    Reference ref = FirebaseStorage.instance.ref().child(
        "${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().year}-${DateTime.now().month}${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.jpg");

    await ref.putFile(File(image!.path));
    // var c=await ImageCropper().cropImage(sourcePath: image.path);

    ref.getDownloadURL().then((value) {
      setState(() {
        pic = value;
        FirebaseAuth.instance.currentUser!.updatePhotoURL(value);
        FirebaseFirestore.instance
            .collection("posts")
            .doc(
                "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}")
            .set({
          "pic": value,
          "timestamp":
              "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
          "name": FirebaseAuth.instance.currentUser!.displayName,
          "likes": 0
        });
      });
    });
  }

  void click() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 100);
    Reference ref = FirebaseStorage.instance.ref().child(
        "${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().year}-${DateTime.now().month}${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.jpg");

    await ref.putFile(File(image!.path));

    ref.getDownloadURL().then((value) {
      setState(() {
        pic = value;
        FirebaseAuth.instance.currentUser!.updatePhotoURL(value);
        FirebaseFirestore.instance
            .collection("posts")
            .doc(
                "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}")
            .set({
          "pic": value,
          "timestamp":
              "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}",
          "name": FirebaseAuth.instance.currentUser!.displayName,
          "likes": 0
        });
      });
    });
  }

  var a = FirebaseAuth.instance.currentUser!.uid;
  final screens = [
    posts(),
    chat(),
    search(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MeChat",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.amber),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    backgroundColor: Colors.black,
                    showDragHandle: true,
                    enableDrag: true,
                    context: context,
                    builder: (context) => BottomSheet(
                        backgroundColor: Colors.black,
                        onClosing: () {},
                        builder: (context) => Container(
                              height: 120,
                              child: Column(
                                children: [
                                  InkWell(
                                      onTap: () async {
                                        click();
                                        try {
                                          var b = {
                                            "to":
                                                "f2ZNO6C6RR6lTPG6buPykx:APA91bFbOTYVTn_l1xzb-UR6T1h9Dv0esDfPQNlu00zQu2mNOaO1qdvzHnNB8Web-IkESmp9ydlMcxccgTpyRL7R7tIrXCOxscF_UsaFkvmrgqZ-0og1p0WiZvR927eNrXSLghavA-Ui",
                                            "notification": {
                                              "title": FirebaseAuth.instance
                                                  .currentUser!.displayName,
                                              "body": "Added A Post"
                                            }
                                          };
                                          var response = await post(
                                              Uri.parse(
                                                  'https://fcm.googleapis.com/fcm/send'),
                                              headers: {
                                                HttpHeaders.contentTypeHeader:
                                                    'application/json',
                                                HttpHeaders.authorizationHeader:
                                                    "key=AAAAf5a0AsQ:APA91bFcn6FslGmPxpwAzo1RlG1Nn-gnysO49Z7LBF2gqyDv_2u1GtMFBU8S3AsSzkjchKwK1KtoITt3zd6O46Qq6rgYKqBk-MNS_aFIWW3uIBTB-aQ7_eWBcb5FndTe-3pvvL7c_WQy"
                                              },
                                              body: jsonEncode(b));

                                          print(
                                              'Response status: ${response.statusCode}');
                                          print(
                                              'Response body: ${response.body}');
                                        } catch (e) {
                                          print(e);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.camera,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Camera",
                                              style: TextStyle(
                                                  color: Colors.amber),
                                            )
                                          ],
                                        ),
                                      )),
                                  InkWell(
                                      onTap: () async {
                                        upload();
                                        try {
                                          var b = {
                                            "to":
                                                "f2ZNO6C6RR6lTPG6buPykx:APA91bFbOTYVTn_l1xzb-UR6T1h9Dv0esDfPQNlu00zQu2mNOaO1qdvzHnNB8Web-IkESmp9ydlMcxccgTpyRL7R7tIrXCOxscF_UsaFkvmrgqZ-0og1p0WiZvR927eNrXSLghavA-Ui",
                                            "notification": {
                                              "title": FirebaseAuth.instance
                                                  .currentUser!.displayName,
                                              "body": "Added A Post"
                                            }
                                          };
                                          var response = await post(
                                              Uri.parse(
                                                  'https://fcm.googleapis.com/fcm/send'),
                                              headers: {
                                                HttpHeaders.contentTypeHeader:
                                                    'application/json',
                                                HttpHeaders.authorizationHeader:
                                                    "key=AAAAf5a0AsQ:APA91bFcn6FslGmPxpwAzo1RlG1Nn-gnysO49Z7LBF2gqyDv_2u1GtMFBU8S3AsSzkjchKwK1KtoITt3zd6O46Qq6rgYKqBk-MNS_aFIWW3uIBTB-aQ7_eWBcb5FndTe-3pvvL7c_WQy"
                                              },
                                              body: jsonEncode(b));

                                          print(
                                              'Response status: ${response.statusCode}');
                                          print(
                                              'Response body: ${response.body}');
                                        } catch (e) {
                                          print(e);
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.photo,
                                              color: Colors.amber,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Gallery",
                                              style: TextStyle(
                                                  color: Colors.amber),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            )));
                // upload();
              },
              icon: Icon(
                Icons.podcasts_rounded,
                color: Colors.amber,
              )),
          // Icon(
          //   Icons.heart_broken,
          //   color: Colors.amber,
          // ),
          SizedBox(
            width: 10,
          ),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => profile()));
              },
              icon: Icon(
                Icons.person,
                color: Colors.amber,
              ))
        ],
      ),
      backgroundColor: Color.fromARGB(255, 72, 68, 68),
      body: IndexedStack(index: widget.c, children: screens),
      bottomNavigationBar: BottomNavigationBar(
          elevation: 0,
          selectedItemColor: Colors.amber,
          showSelectedLabels: false,
          unselectedItemColor: Color.fromARGB(255, 90, 85, 85),
          selectedIconTheme: IconThemeData(color: Colors.amber),
          showUnselectedLabels: false,
          backgroundColor: Color.fromARGB(255, 3, 3, 3),
          currentIndex: widget.c,
          onTap: (value) => setState(() {
                widget.c = value;
              }),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              backgroundColor: const Color.fromARGB(20, 0, 0, 0),
              label: "home",
            ),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.message,
                ),
                backgroundColor: const Color.fromARGB(20, 0, 0, 0),
                label: "chat"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                ),
                backgroundColor: const Color.fromARGB(20, 0, 0, 0),
                label: "search"),
            //   BottomNavigationBarItem(
            //       icon: Icon(
            //         Icons.video_collection,
            //       ),
            //       backgroundColor: const Color.fromARGB(20, 0, 0, 0),
            //       label: "reels"),
            //   BottomNavigationBarItem(
            //       icon: Icon(
            //         Icons.person,
            //       ),
            //       backgroundColor: const Color.fromARGB(20, 0, 0, 0),
            //       label: "profile")
          ]),
    );
  }
}
