import 'package:chatvista/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'log.dart';

class name extends StatelessWidget {
  name({super.key});
  TextEditingController a = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("enter your name")),
      body: Center(
        child: Column(
          children: [
            TextFormField(
              controller: a,
              decoration: InputDecoration(
                  hintText: 'USERNAME',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(30)),
                  prefixIcon: Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  suffixText: ''),
            ),
            ElevatedButton(
                onPressed: () async {
                  // if(FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get("name"))
                  if (a.text.length >= 4) {
                    await FirebaseAuth.instance.currentUser!
                        .updateDisplayName(a.text);
                    FirebaseFirestore.instance
                        .collection("users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({"name": a.text});
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => loading()));
                  } else {
                    return showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("enter longer name"),
                          );
                        });
                  }
                },
                child: Text("DONE"))
          ],
        ),
      ),
    );
  }
}
