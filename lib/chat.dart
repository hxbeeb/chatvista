import 'package:chatvista/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class chat extends StatefulWidget {
  chat({
    super.key,
  });

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  static FirebaseMessaging m = FirebaseMessaging.instance;

  Future<void> getm(String user2) async {
    await m.getToken().then((value) {
      FirebaseFirestore.instance
          .collection("chat")
          .doc(user2)
          .collection("message")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"token": value});
    });
  }

  List<Map<String, dynamic>>? items;

  var collection = FirebaseFirestore.instance
      .collection("chat")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection("message");
  var chat = FirebaseFirestore.instance.collection("chat");

  _incrementCounter() async {
    List<Map<String, dynamic>> temp = [];
    var data = await collection.get();

    data.docs.forEach((e) {
      temp.add(e.data());
    });

    setState(() {
      items = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    String id = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     TextButton(
      //         onPressed: () {
      //           FirebaseAuth.instance.signOut();
      //           Navigator.pushReplacement(context,
      //               MaterialPageRoute(builder: (context) => mainpage()));
      //         },
      //         child: Text(
      //           "Sign Out",
      //           style: TextStyle(color: Color.fromARGB(255, 185, 167, 1)),
      //         ))
      //   ],
      //   backgroundColor: Color.fromARGB(255, 38, 36, 32),
      // ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("chat")
              .doc(id)
              .collection("message")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              _incrementCounter();

              return ListView.builder(
                itemCount: items?.length,
                itemBuilder: (context, Index) {
                  return Card(
                    color: Color.fromARGB(255, 51, 50, 47),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Color.fromARGB(255, 0, 0, 0)),
                      child: ListTile(
                        title: Text(
                          items?[Index]["name"] ?? "",
                          style: TextStyle(color: Colors.amber),
                        ),
                        subtitle: Text(
                          items?[Index]["text"] ?? "",
                          style: TextStyle(color: Colors.amber),
                        ),
                        // subtitle: Text(items?[Index]["No"] ?? "UNAVAILABLE"),

                        leading: CircleAvatar(
                          child: InkWell(),
                          backgroundColor: Color.fromARGB(255, 43, 87, 85),
                        ),
                        trailing: Icon(
                          (items?[Index]["active"] == null)
                              ? (items?[Index]["read"] == null)
                                  ? Icons.circle_notifications
                                  : null
                              : Icons.online_prediction_rounded,
                          color: Colors.amber,
                        ),

                        onLongPress: () {},

                        onTap: () async {
                          var user2 = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(snapshot.data!.docs[Index].id)
                              .id;
                          var name = await FirebaseFirestore.instance
                              .collection("users")
                              .doc(snapshot.data!.docs[Index].get("name"))
                              .id;
                          await getm(user2);

                          // var doc = await FirebaseFirestore.instance
                          //     .collection("chats")
                          //     .doc(
                          //         "${FirebaseAuth.instance.currentUser!.uid}-$user2")
                          //     .collection("messages");
                          // doc.get("read");
                          var time = DateTime.now();

                          var t = items?[Index]["timestamp"];
                          var b = items?[Index]["token"];

                          print(t);

                          var on = items?[Index]["active"];

                          // var n = await FirebaseFirestore.instance
                          //     .collection("chat")
                          //     .doc(user2)
                          //     .collection("message")
                          //     .doc(FirebaseAuth.instance.currentUser!.uid);
                          // n.get("timestamp");

                          // .update({"read": "done"});
                          // var doc = snapshot.data!['timestamp'];

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                      other: user2, name: name, b: b, on: on)));
                          print(user2);
                          await FirebaseFirestore.instance
                              .collection("chat")
                              .doc(user2)
                              .collection("message")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({"active": 1});
                          await FirebaseFirestore.instance
                              .collection("chats")
                              .doc(
                                  "${user2}-${FirebaseAuth.instance.currentUser!.uid}")
                              .collection("messages")
                              .doc(t)
                              .update({
                            "read": 1,
                          });
                          await FirebaseFirestore.instance
                              .collection("chat")
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection("message")
                              .doc(user2)
                              .update({"read": 1});
                        },
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("NO DATA"),
              );
            } else
              return Center(child: const CircularProgressIndicator());
          }),
      backgroundColor: Color.fromARGB(255, 51, 50, 47),
    );
  }
}
