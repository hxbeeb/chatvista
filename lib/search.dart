import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class search extends StatefulWidget {
  const search({super.key});

  @override
  State<search> createState() => _searchState();
}

class _searchState extends State<search> {
  static FirebaseMessaging m = FirebaseMessaging.instance;
  Future<void> getm(String user2) async {
    await m.getToken().then((value) {
      FirebaseFirestore.instance
          .collection("chat")
          .doc(user2)
          .collection("message")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"token": value});
      print(value);
    });
  }

  List<Map<String, dynamic>>? items;

  var collection = FirebaseFirestore.instance.collection("users");

  String name = "";

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

  TextEditingController a = TextEditingController();
  List<Map<String, dynamic>>? found = [];
  @override
  void initState() {
    // TODO: implement initState
    a.addListener(() {
      found = items;
      setState(() {});
    });
    super.initState();
  }

  void filter(String text) {
    List<Map<String, dynamic>> result = [];
    if (text.isEmpty) {
      result = items!;
    } else {
      result = items!
          .where((element) => element["name"]
              .toString()
              .toLowerCase()
              .contains(text.toLowerCase()))
          .toList();
    }
    setState(() {
      found = result;
    });
  }

  FocusNode node = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        body: Column(children: [
          SizedBox(
            height: 5,
          ),
          TextField(
            style: TextStyle(color: Colors.amber),
            onChanged: (value) {
              filter(a.text);
            },
            autofocus: false,
            focusNode: node,
            controller: a,
            decoration: InputDecoration(
              hintText: 'Search',
              hintStyle: TextStyle(color: Colors.amber),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.amber)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 218, 204, 52), width: 3),
                  borderRadius: BorderRadius.circular(30)),
              prefixIcon: Icon(
                Icons.search,
                color: Color.fromARGB(255, 221, 190, 52),
              ),
              suffixIcon: a.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => a.clear(),
                    )
                  : null,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection("users").snapshots(),
                builder: (context, snapshot) {
                  // if (snapshot.connectionState == ConnectionState.waiting)
                  //   return Center(child: CircularProgressIndicator(),);
                  if (snapshot.hasData) {
                    _incrementCounter();

                    return ListView.builder(
                        itemCount: found?.length,
                        itemBuilder: (context, Index) {
                          var data = snapshot.data!.docs[Index]
                              .get("name")
                              .toString()
                              .toLowerCase();

                          return Card(
                            color: Color.fromARGB(255, 51, 50, 47),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              child: ListTile(
                                title: Text(
                                  found?[Index]["name"] ?? "UNKNOWN",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                subtitle: Text(
                                  found?[Index]["email"] ?? "",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                leading: CircleAvatar(
                                  child: InkWell(
                                    onDoubleTap: () {},
                                    onLongPress: () {},
                                  ),
                                  backgroundColor:
                                      Color.fromARGB(255, 43, 87, 85),
                                ),
                                onTap: () async {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  var user2 = await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(snapshot.data!.docs[Index].id)
                                      .id;
                                  var name = await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(snapshot.data!.docs[Index]
                                          .get("name"))
                                      .id;

                                  var time = DateTime.now();

                                  await FirebaseFirestore.instance
                                      .collection('chat')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection("message")
                                      .doc(user2)
                                      .set({
                                    "name": name,
                                    "id": user2,
                                    'timestamp':
                                        "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}",
                                    'text': "",
                                    'read': 1,
                                    "active": null,
                                    "token": ""
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('chat')
                                      .doc(user2)
                                      .collection("message")
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .set({
                                    "name": FirebaseAuth
                                        .instance.currentUser!.displayName,
                                    "id": user2,
                                    'timestamp':
                                        "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}",
                                    'text': "",
                                    'read': 1,
                                    "active": null,
                                    "token": ""
                                  });

                                  await getm(user2);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatScreen(
                                                other: user2,
                                                name: name,
                                              )));
                                  print(user2);
                                },
                              ),
                            ),
                          );
                        }
                        // if (data.contains(name.toLowerCase())) {
                        //   return Card(
                        //     color: Color.fromARGB(255, 99, 83, 83),
                        //     child: ListTile(
                        //       title: Text(
                        //         items?[Index]["name"] ?? "UNKNOWN",
                        //         style: TextStyle(color: Colors.amber),
                        //       ),
                        //       subtitle: Text(
                        //         items?[Index]["email"] ?? "UNAVAILABLE",
                        //         style: TextStyle(color: Colors.amber),
                        //       ),
                        //       leading: CircleAvatar(
                        //         child: InkWell(
                        //           onDoubleTap: () {},
                        //           onLongPress: () {},
                        //         ),
                        //         backgroundColor: Colors.black,
                        //       ),
                        //       onTap: () async {
                        //         var user2 = await FirebaseFirestore.instance
                        //             .collection("users")
                        //             .doc(snapshot.data!.docs[Index].id)
                        //             .id;
                        //         var name = await FirebaseFirestore.instance
                        //             .collection("users")
                        //             .doc(snapshot.data!.docs[Index].get("name"))
                        //             .id;
                        //         var t = await FirebaseFirestore.instance
                        //             .collection("users")
                        //             .doc(
                        //                 snapshot.data!.docs[Index].get("token"))
                        //             .id;
                        //         Navigator.push(
                        //             context,
                        //             MaterialPageRoute(
                        //                 builder: (context) => ChatScreen(
                        //                     other: user2, name: name)));
                        //         print(user2);
                        //       },
                        //     ),
                        //   );
                        // }

                        );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("NO DATA"),
                    );
                  } else
                    return Center(child: CircularProgressIndicator());
                }),
          )
        ]),
        backgroundColor: Color.fromARGB(255, 51, 50, 47),
      ),
    );
  }
}
