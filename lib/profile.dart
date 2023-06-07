import 'package:chatvista/log.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class profile extends StatefulWidget {
  const profile({super.key});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  // var pic;
  // @override
  // Future<void> initState() async {
  //   // TODO: implement initState
  //   super.initState();
  //   await FirebaseStorage.instance
  //       .ref()
  //       .child("${FirebaseAuth.instance.currentUser!.uid}/pic.jpg")
  //       .getDownloadURL()
  //       .then((value) {
  //     print(value);
  //   });
  // }

  // void show() {
  //   Reference ref = FirebaseStorage.instance
  //       .ref()
  //       .child("${FirebaseAuth.instance.currentUser!.uid}/pic.jpg");
  //   ref.getDownloadURL().then((value) {
  //     setState(() {
  //       pic = value;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            CircleAvatar(
              backgroundColor: Colors.black, radius: 50,
              // backgroundImage: NetworkImage(FirebaseFirestore.instance
              //     .collection("posts")
              //     .doc(pic) as String)
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Current user : ${FirebaseAuth.instance.currentUser!.displayName}",
              style: TextStyle(color: Colors.amber),
            ),
            Text(
              "User Id : ${FirebaseAuth.instance.currentUser!.email}",
              style: TextStyle(color: Colors.amber),
            ),
            TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => mainpage()),
                      (route) => false);
                },
                child: Container(
                  color: Colors.black,
                  padding: EdgeInsets.all(7),
                  child: Text(
                    "SIGN  OUT",
                    style: TextStyle(color: Colors.amber),
                  ),
                )),
            SizedBox(
              height: 20,
            ),
          ]),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 51, 50, 47),
    );
  }
}
