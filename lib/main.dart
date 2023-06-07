import 'dart:convert';
import 'dart:io';
import 'package:chatvista/pic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chatvista/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chatvista/chat.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'log.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', 'High_Importance_Notification',
    importance: Importance.high, playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("hola  : ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(
    MaterialApp(
      home: mainpage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ChatApp extends StatefulWidget {
  const ChatApp({super.key, required user2});
  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: chat(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  var other;
  var name;
  var b;
  var on;
  ChatScreen({Key? mykey, this.other, this.name, this.b, this.on})
      : super(key: mykey);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;
  late String _currentUserId;
  late String _otherUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(channel.id, channel.name,
                    color: Colors.amberAccent, playSound: true)));
      }
    });
    ScrollController s = new ScrollController();

    s.addListener(() {
      print(s.offset);
    });
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
        _currentUserId = user.uid;
        _otherUserId = widget.other; // Replace with the ID of the other user
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) return;
    final isBack = state == AppLifecycleState.paused;
    if (isBack) {
      FirebaseFirestore.instance
          .collection("chat")
          .doc(_otherUserId)
          .collection("message")
          .doc(_currentUserId)
          .update({"active": null});
    } else {
      FirebaseFirestore.instance
          .collection("chat")
          .doc(_otherUserId)
          .collection("message")
          .doc(_currentUserId)
          .update({"active": 1});
    }
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    var time = DateTime.now();

    await FirebaseFirestore.instance
        .collection('chats')
        .doc('$_currentUserId-$_otherUserId')
        .collection('messages')
        .doc(
            "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}")
        .set({
      'text': text,
      'senderId': _currentUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'read': null,
      "time": "${time.hour}:${time.minute}"
    });
    await FirebaseFirestore.instance
        .collection('chats')
        .doc('$_otherUserId-$_currentUserId')
        .collection('messages')
        .doc(
            "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}")
        .set({
      'text': text,
      'senderId': _currentUserId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'read': null,
      "time": "${time.hour}:${time.minute}"
    });

    // await FirebaseFirestore.instance
    //     .collection('chat')
    //     .doc(_currentUserId)
    //     .set({
    //   'text': text,
    //   'name': widget.name,
    // });

    await FirebaseFirestore.instance
        .collection('chat')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("message")
        .doc(_otherUserId)
        .update({
      "name": widget.name,
      "id": widget.other,
      'timestamp':
          "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}",
      'text': text,
      'read': 1,
      "active": null,
      "token": widget.b
    });

    await FirebaseFirestore.instance
        .collection('chat')
        .doc(_otherUserId)
        .collection("message")
        .doc(_currentUserId)
        .update({
      "name": FirebaseAuth.instance.currentUser!.displayName,
      'timestamp':
          "${time.year}-${time.month}-${time.day} ${time.hour}:${time.minute}:${time.second}",
      'text': text,
      "read": null,
      "active": 1,
    });
    print("this ${widget.b}");

    try {
      var b = {
        "to": widget.b,
        "notification": {
          "title": FirebaseAuth.instance.currentUser!.displayName,
          "body": text
        }
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    "key=AAAAf5a0AsQ:APA91bFcn6FslGmPxpwAzo1RlG1Nn-gnysO49Z7LBF2gqyDv_2u1GtMFBU8S3AsSzkjchKwK1KtoITt3zd6O46Qq6rgYKqBk-MNS_aFIWW3uIBTB-aQ7_eWBcb5FndTe-3pvvL7c_WQy"
              },
              body: jsonEncode(b));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print(e);
    }
  }

  var show = false;
  FocusNode node = FocusNode();
  String pic = "";

  Widget _buildTextComposer() {
    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          IconButton(
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                setState(() {
                  show = !show;
                });
              },
              icon: Icon(
                Icons.emoji_emotions,
                color: Colors.amber,
              )),
          Flexible(
            child: TextField(
              focusNode: node,
              onTap: () {
                if (show) {
                  setState(() {
                    show = !show;
                  });
                }
              },
              style: TextStyle(color: Colors.amber),
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 4, 4, 4),
                      ),
                      borderRadius: BorderRadius.circular(4)),
                  hintText: 'Send a message',
                  hintStyle: TextStyle(color: Colors.amberAccent),
                  fillColor: Color.fromARGB(255, 105, 104, 104)),
            ),
          ),
          IconButton(
            onPressed: () async {
              final image = await ImagePicker().pickImage(
                  source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
              Reference ref = FirebaseStorage.instance.ref().child(
                  "${FirebaseAuth.instance.currentUser!.uid}/${DateTime.now().year}-${DateTime.now().month}${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}.jpg");

              await ref.putFile(File(image!.path));
              // var c=await ImageCropper().cropImage(sourcePath: image.path);

              ref.getDownloadURL().then((value) {
                setState(() {
                  pic = value;
                  FirebaseFirestore.instance
                      .collection("chats")
                      .doc("$_currentUserId-$_otherUserId")
                      .collection("messages")
                      .doc(
                          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}")
                      .set({
                    "senderId": _currentUserId,
                    "text": value,
                    "image": 1,
                    "timestamp": DateTime.now().millisecondsSinceEpoch,
                    "time": "${DateTime.now().hour}:${DateTime.now().minute}"
                  });
                  FirebaseFirestore.instance
                      .collection("chats")
                      .doc("$_otherUserId-$_currentUserId")
                      .collection("messages")
                      .doc(
                          "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}")
                      .set({
                    "senderId": _currentUserId,
                    "text": value,
                    "image": 1,
                    "timestamp": DateTime.now().millisecondsSinceEpoch,
                    "time": "${DateTime.now().hour}:${DateTime.now().minute}"
                  });
                });
              });
              try {
                var b = {
                  "to": widget.b,
                  "notification": {
                    "title": FirebaseAuth.instance.currentUser!.displayName,
                    "body": "Sent an Image"
                  }
                };
                var response =
                    await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                        headers: {
                          HttpHeaders.contentTypeHeader: 'application/json',
                          HttpHeaders.authorizationHeader:
                              "key=AAAAf5a0AsQ:APA91bFcn6FslGmPxpwAzo1RlG1Nn-gnysO49Z7LBF2gqyDv_2u1GtMFBU8S3AsSzkjchKwK1KtoITt3zd6O46Qq6rgYKqBk-MNS_aFIWW3uIBTB-aQ7_eWBcb5FndTe-3pvvL7c_WQy"
                        },
                        body: jsonEncode(b));

                print('Response status: ${response.statusCode}');
                print('Response body: ${response.body}');
              } catch (e) {
                print(e);
              }
            },
            icon: Icon(
              Icons.photo,
              color: Colors.amber,
            ),
          ),
          IconButton(
              onPressed: () async {
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

                    FirebaseFirestore.instance
                        .collection("chats")
                        .doc("$_currentUserId-$_otherUserId")
                        .collection("messages")
                        .doc(
                            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}")
                        .set({
                      "senderId": _currentUserId,
                      "image": 1,
                      "text": value,
                      "timestamp": DateTime.now().millisecondsSinceEpoch,
                      "time": "${DateTime.now().hour}:${DateTime.now().minute}"
                    });
                    FirebaseFirestore.instance
                        .collection("chats")
                        .doc("$_otherUserId-$_currentUserId")
                        .collection("messages")
                        .doc(
                            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day} ${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}")
                        .set({
                      "senderId": _currentUserId,
                      "text": value,
                      "image": 1,
                      "timestamp": DateTime.now().millisecondsSinceEpoch,
                      "time": "${DateTime.now().hour}:${DateTime.now().minute}"
                    });
                  });
                });
                try {
                  var b = {
                    "to": widget.b,
                    "notification": {
                      "title": FirebaseAuth.instance.currentUser!.displayName,
                      "body": "Sent an Image"
                    }
                  };
                  var response = await post(
                      Uri.parse('https://fcm.googleapis.com/fcm/send'),
                      headers: {
                        HttpHeaders.contentTypeHeader: 'application/json',
                        HttpHeaders.authorizationHeader:
                            "key=AAAAf5a0AsQ:APA91bFcn6FslGmPxpwAzo1RlG1Nn-gnysO49Z7LBF2gqyDv_2u1GtMFBU8S3AsSzkjchKwK1KtoITt3zd6O46Qq6rgYKqBk-MNS_aFIWW3uIBTB-aQ7_eWBcb5FndTe-3pvvL7c_WQy"
                      },
                      body: jsonEncode(b));

                  print('Response status: ${response.statusCode}');
                  print('Response body: ${response.body}');
                } catch (e) {
                  print(e);
                }
              },
              icon: Icon(
                Icons.camera,
                color: Colors.amber,
              )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                if (_textController.text.length >= 1) {
                  _handleSubmitted(_textController.text);
                }
                ;

                // s.animateTo(s.position.maxScrollExtent,
                //     duration: const Duration(milliseconds: 10),
                //     curve: Curves.bounceInOut);
              },
              child: Text(
                "send",
                style: TextStyle(color: Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  delete() async {
    var d = FirebaseFirestore.instance
        .collection('chats')
        .doc('$_currentUserId-$_otherUserId')
        .collection("messages");
    var doc = await d.get();
    for (var del in doc.docs) {
      await del.reference.delete();
    }
  }

  final s = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: WillPopScope(
        onWillPop: () {
          if (show) {
            setState(() {
              show = !show;
            });
            return Future.value(false);
          } else {
            setState(() {
              FirebaseFirestore.instance
                  .collection("chat")
                  .doc(_otherUserId)
                  .collection("message")
                  .doc(_currentUserId)
                  .update({"active": null});
            });

            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () async {
                setState(() {
                  FirebaseFirestore.instance
                      .collection("chat")
                      .doc(_otherUserId)
                      .collection("message")
                      .doc(_currentUserId)
                      .update({"active": null});
                });
                // if (del == true) {
                //  delete();
                // }
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.amber,
              ),
            ),
            actions: [
              // Switch.adaptive(
              //     activeColor: Colors.amber,
              //     value: del,
              //     onChanged: (del) => setState(() {
              //           this.del = del;
              //         })),
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.black,
                            title: Text(
                              "Clear Chat?",
                              style: TextStyle(color: Colors.amber),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "BACK",
                                    style: (TextStyle(color: Colors.amber)),
                                  )),
                              TextButton(
                                  onPressed: () {
                                    delete();
                                    FirebaseFirestore.instance
                                        .collection("chat")
                                        .doc(_currentUserId)
                                        .collection("message")
                                        .doc(_otherUserId)
                                        .delete();

                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "CLEAR",
                                    style: TextStyle(color: Colors.amber),
                                  ))
                            ],
                          );
                        });
                  },
                  child: Text(
                    "Clear",
                    style: TextStyle(color: Colors.amber),
                  ))
            ],
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 43, 87, 85),
                ),
                SizedBox(
                  width: 10,
                ),
                Column(
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(color: Colors.amber),
                    ),
                    (widget.on == 1)
                        ? Text(
                            "active",
                            style: TextStyle(color: Colors.amber, fontSize: 18),
                          )
                        : Text("")
                  ],
                ),
              ],
            ),
            backgroundColor: Colors.black,
          ),
          body: Column(
            children: <Widget>[
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc('$_currentUserId-$_otherUserId')
                      .collection('messages')
                      .orderBy(
                        'timestamp',
                        descending: true,
                      )
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    // snapshot.data!.docs.map((DocumentSnapshot document) {
                    //   Map<String, dynamic> data =
                    //       document.data() as Map<String, dynamic>;

                    //   final bool isCurrentUser =
                    //       data['senderId'] == _currentUserId;

                    return

                        //  GroupedListView(elements: data["text"], groupBy: (data["timestamp"])=>DateTime(DateTime.fromMillisecondsSinceEpoch(data["timestamp"]).year,DateTime.fromMillisecondsSinceEpoch(data["timestamp"]).month,DateTime.fromMillisecondsSinceEpoch(data["timestamp"]).day),
                        //  groupHeaderBuilder: (data["text"]=>),

                        ListView(
                      reverse: true,
                      controller: s,
                      padding: const EdgeInsets.all(8.0),
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        final bool isCurrentUser =
                            data['senderId'] == _currentUserId;

                        return Container(
                          alignment: AlignmentDirectional.topEnd,
                          color: Colors.transparent,
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              // if (isCurrentUser)
                              //   Expanded(
                              //       child: Container()), // Add spacing for current user messages
                              if (!isCurrentUser)
                                Container(
                                  margin: const EdgeInsets.only(right: 10.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black,
                                  ),
                                ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // if (!isCurrentUser)
                                    //   Text(
                                    //     '',
                                    //     style: Theme.of(context).textTheme.subtitle1,
                                    //   ),
                                    if (!isCurrentUser)
                                      InkWell(
                                        onTap: () {
                                          if (data["image"] == 1)
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => pict(
                                                          pic: data["text"],
                                                        )));
                                        },
                                        onLongPress: () async {
                                          if (data["image"] == 1) {
                                            print("this  ${data["text"]}");
                                            try {
                                              await GallerySaver.saveImage(
                                                      data["text"],
                                                      albumName: "MeChat")
                                                  .then((success) {
                                                print("done");
                                              });
                                            } catch (e) {
                                              print(e);
                                            }
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        255, 0, 0, 0)),
                                                padding: EdgeInsets.all(10),
                                                child: data['image'] == 1
                                                    ? Image.network(
                                                        data["text"])
                                                    : Text(
                                                        data['text'],
                                                        style: TextStyle(
                                                            color: Colors.amber,
                                                            fontSize: 14),
                                                      ),
                                              ),
                                            ),
                                            Container(
                                                alignment:
                                                    Alignment.bottomRight,
                                                // alignment: Alignment.bottomRight,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: Text(
                                                    (data["time"] == null)
                                                        ? data["timestamp"]
                                                            .toString()
                                                        : data["time"]
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: const Color
                                                                .fromARGB(255,
                                                            133, 115, 115)),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),

                                    if (isCurrentUser)
                                      InkWell(
                                        onTap: () {
                                          if (data["image"] == 1)
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => pict(
                                                          pic: data["text"],
                                                        )));
                                        },
                                        onLongPress: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                actions: [
                                                  TextButton(
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('chats')
                                                            .doc(
                                                                '$_currentUserId-$_otherUserId')
                                                            .collection(
                                                                'messages')
                                                            .doc(
                                                                "${data['timestamp']}")
                                                            .delete();
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('chats')
                                                            .doc(
                                                                '$_currentUserId-$_currentUserId')
                                                            .collection(
                                                                'messages')
                                                            .doc(
                                                                "${data['timestamp']}")
                                                            .delete();
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "UNSEND",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.amber),
                                                      )),
                                                ],
                                                backgroundColor: Colors.black,
                                              );
                                            },
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Row(
                                                children: [
                                                  if (data['read'] == 1 ||
                                                      widget.on == 1)
                                                    Icon(
                                                      Icons.done_all_rounded,
                                                      color: Colors.amber,
                                                    ),
                                                  Text(
                                                    (data["time"] == null)
                                                        ? data["timestamp"]
                                                            .toString()
                                                        : data["time"]
                                                            .toString(),
                                                    style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255,
                                                            120,
                                                            103,
                                                            103)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),

                                            Flexible(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: const Color.fromARGB(
                                                        255, 0, 0, 0)),
                                                padding: EdgeInsets.all(10),
                                                child: data['image'] == 1
                                                    ? Image.network(
                                                        data["text"])
                                                    : Text(
                                                        data['text'],
                                                        style: TextStyle(
                                                            color: Colors.amber,
                                                            fontSize: 14),
                                                      ),
                                              ),
                                            ),
                                            // ),
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),

                              if (isCurrentUser)
                                Container(
                                  margin: const EdgeInsets.only(left: 0.0),
                                  // child: CircleAvatar(
                                  //   child: Text('You'),
                                  // ),
                                ),
                            ],
                          ),

                          // ChatMessage(
                          //   text: data['text'],
                          //   isCurrentUser: isCurrentUser,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                child: _buildTextComposer(),
              ),
              Container(
                  child: show
                      ? SizedBox(
                          height: 300,
                          child: EmojiPicker(
                              textEditingController:
                                  _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                              config: Config(
                                  bgColor: Color.fromARGB(255, 57, 52, 52),
                                  columns: 7,
                                  emojiSizeMax:
                                      32 * (Platform.isIOS ? 1.30 : 1.0))),
                        )
                      : null)
            ],
          ),
          backgroundColor: Color.fromARGB(255, 51, 50, 47),
        ),
      ),
    );
  }
}
