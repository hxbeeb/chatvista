import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class posts extends StatefulWidget {
  const posts({super.key});

  @override
  State<posts> createState() => _postState();
}

class _postState extends State<posts> {
  var name = FirebaseAuth.instance.currentUser?.displayName;
  var pro = FirebaseAuth.instance.currentUser!.photoURL;
  String pic = "";
  void upload() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("${FirebaseAuth.instance.currentUser!.uid}");

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
          "timestamp": DateTime.now(),
          "name": FirebaseAuth.instance.currentUser!.displayName,
          "likes": 0
        });
      });
    });
  }

  List<Map<String, dynamic>>? items;
  var collection = FirebaseFirestore.instance.collection("posts");

  _incrementCounter() async {
    List<Map<String, dynamic>> temp = [];
    var data = await collection.get();

    data.docs.forEach((e) {
      temp.add(e.data());
    });

    setState(() {
      items = temp.reversed.toList();
    });
  }

  var ss = 0;

  ScrollController s = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("posts")
              .orderBy("timestamp", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              _incrementCounter();
              // if (ss == 0)
              //   setState(() {
              //     items = items?.reversed.toList();
              //   });

              return ListView.builder(
                controller: s,
                itemCount: items?.length,
                itemBuilder: (context, Index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromARGB(255, 0, 0, 0)),
                      alignment: Alignment.topRight,
                      // color: const Color.fromARGB(255
                      //.., 50, 45, 45),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 7,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color.fromARGB(255, 0, 0, 0)),
                            // color: Colors.black,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(255, 36, 70, 69),
                                  // backgroundImage: Image.network(pro!),
                                  radius: 18,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      items?[Index]["name"] ?? "",
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                    Text(
                                      items?[Index]["timestamp"] ?? "",
                                      style: TextStyle(color: Colors.amber),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 200,
                                ),
                                // IconButton(
                                //     onPressed: () {},
                                //     icon: Icon(
                                //       Icons.menu,
                                //       color: Colors.amber,
                                //     ))
                              ],
                            ),
                          ),
                          InkWell(
                              onDoubleTap: () async {
                                if (items?[Index][
                                        "${FirebaseAuth.instance.currentUser!.displayName}"] !=
                                    1)
                                  await FirebaseFirestore.instance
                                      .collection("posts")
                                      .doc(items?[Index]["timestamp"])
                                      .update({
                                    "likes": items?[Index]["likes"] + 1,
                                    "${FirebaseAuth.instance.currentUser!.displayName}":
                                        1
                                  });
                              },
                              onLongPress: () {
                                if (FirebaseAuth.instance.currentUser!
                                            .displayName ==
                                        items?[Index]["name"] ||
                                    FirebaseAuth.instance.currentUser!.email ==
                                        "habeebsalehalhussain@gmail.com") {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.black,
                                          title: Text(
                                            "Remove this post?",
                                            style:
                                                TextStyle(color: Colors.amber),
                                          ),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "CANCEL",
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                )),
                                            TextButton(
                                                onPressed: () {
                                                  FirebaseFirestore.instance
                                                      .collection("posts")
                                                      .doc(items?[Index]
                                                          ["timestamp"])
                                                      .delete();
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "REMOVE",
                                                  style: TextStyle(
                                                      color: Colors.amber),
                                                ))
                                          ],
                                        );
                                      });
                                }
                              },
                              child: Image.network(
                                items?[Index]["pic"],
                                fit: BoxFit.cover,
                                height: 500,
                              )),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Color.fromARGB(255, 0, 0, 0)),
                            padding: EdgeInsets.all(6),
                            // color: Colors.black,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.thumb_up_sharp,
                                  color: Colors.amber,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Center(
                                    child: Text(
                                  ("${items?[Index]["likes"] ?? "0"}"),
                                  style: TextStyle(color: Colors.amber),
                                )),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              );
            } else
              return Center(
                  child: CircularProgressIndicator(
                color: Colors.amber,
              ));
          }),

      // SingleChildScrollView(
      //   child: Column(
      //     children: [
      //       SizedBox(
      //         height: 10,
      //       ),
      //       Container(
      //         color: const Color.fromARGB(255, 50, 45, 45),
      //         child: Row(
      //           children: [
      //             SizedBox(),
      //             CircleAvatar(
      //               backgroundColor: Colors.black,
      //               // backgroundImage: Image.network(pro!),
      //               radius: 20,
      //             ),
      //             SizedBox(
      //               width: 10,
      //             ),
      //             Text(
      //               name!,
      //               style: TextStyle(color: Colors.amber),
      //             ),
      //             SizedBox(
      //               width: 250,
      //             ),
      //             // IconButton(
      //             //     onPressed: () {},
      //             //     icon: Icon(
      //             //       Icons.menu,
      //             //       color: Colors.amber,
      //             //     ))
      //           ],
      //         ),
      //       ),

      //       // Container(
      //       //   width: double.infinity,
      //       //   height: 400,
      //       //   color: Color.fromARGB(255, 98, 86, 86),
      //       //   child: Image.asset("assets/images.jpeg"),
      //       // ),
      //       // Divider(
      //       //   color: Colors.black,
      //       //   thickness: 3,
      //       // ),
      //       Container(
      //         width: double.infinity,
      //         height: 400,
      //         color: Color.fromARGB(255, 98, 86, 86),
      //         child: pic == "" ? null : Image.network(pic),
      //       ),
      //       Center(
      //         child: MaterialButton(
      //           onPressed: () {
      //             upload();
      //           },
      //           color: Colors.black,
      //           child: Text(
      //             "Upload",
      //             style: TextStyle(color: Colors.amber),
      //           ),
      //         ),
      //       ),

      //     ],
      //   ),
      // ),
      backgroundColor: Color.fromARGB(255, 51, 50, 47),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     setState(() {
      //       items = items!.reversed.toList();
      //     });

      //     // s.jumpTo(s.position.maxScrollExtent);
      //     // ss = 1;
      //   },
      //   backgroundColor: Colors.black,
      //   child: Icon(Icons.arrow_drop_up),
      // )
    );
  }
}
