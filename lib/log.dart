import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'home.dart';

class loading extends StatefulWidget {
  const loading({Key? key}) : super(key: key);

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {
  var load = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageState();
  }

  _pageState() async {
    await Future.delayed(Duration(seconds: 2));
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => home(
                  c: 0,
                )),
        (route) => false);
  }

  var a = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            height: 370,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => home(
                            c: 0,
                          )));
            },
            child: Center(
              child: SpinKitSpinningLines(
                color: Colors.grey,
                duration: Duration(seconds: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////////
class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  var a = TextEditingController();
  var b = TextEditingController();
  var v = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Sign In',
            style: TextStyle(color: Colors.amber),
          ),
          centerTitle: true,
          backgroundColor: Color.fromARGB(255, 8, 8, 8),
        ),
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(
            height: 250,
          ),
          TextField(
            controller: a,
            decoration: InputDecoration(
                hintText: 'EMAIL',
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(30)),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                suffixText: ''),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: b,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: 'PASSWORD',
              prefixIcon: Icon(
                Icons.password,
                color: Colors.black,
              ),
              suffixIcon: IconButton(
                icon: v ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                onPressed: () => setState(
                  () => v = !v,
                ),
              ),
            ),
            obscureText: !v,
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              try {
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                  email: a.text.trim(),
                  password: b.text.trim(),
                );
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => mainpage()));
              } on FirebaseAuthException catch (e) {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: Text(e.message!.trim()),
                        ));
              }
            },
            child: Container(
              child: Text(
                'Sign In',
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => reset()));
            },
            child: Text(
              'Forgot Password?',
              style: (TextStyle(color: Colors.amber)),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'dont have an account?',
            style: TextStyle(color: Colors.black),
          ),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => signup()));
              },
              child: Text(
                'signup',
                style: TextStyle(color: Colors.amber),
              ))
        ])),
        backgroundColor: Color.fromARGB(255, 111, 98, 98));
  }

//   Future signIn() async {
//     await FirebaseAuth.instance
//         .signInWithEmailAndPassword(
//           email: a.text.trim(),
//           password: b.text.trim(),
//         );
//         Navigator.push(
//             context, MaterialPageRoute(builder: (context) => mainpage()));
//   }
}

///////////////////////////////////////////////////////////////////////////////////////////
class mainpage extends StatelessWidget {
  const mainpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                FirebaseAuth.instance.currentUser!.displayName != "") {
              return loading();
            } else {
              return login();
            }
          }),
    );
  }
}

class mainpage2 extends StatelessWidget {
  var d;
  var e;
  mainpage2({Key? key, required this.d, required this.e}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              FirebaseAuth.instance.currentUser!.updateDisplayName(d);
              print(d);

              FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .set({
                "id": FirebaseAuth.instance.currentUser!.uid,
                "name": d,
                "email": e,
              });
              return loading();
            } else {
              return signup();
            }
          }),
    );
  }
}

//////////////////////////////////////////////////////////////////////////////////

class signup extends StatefulWidget {
  const signup({Key? key}) : super(key: key);

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  var a = TextEditingController();
  var b = TextEditingController();
  var c = TextEditingController();
  var d = TextEditingController();
  var v = false;

  @override
  Widget build(BuildContext context) {
    var t;
    var t2;
    var t3;
    var t4;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: TextStyle(color: Colors.amber),
        ), //fromARGB(255, 229, 23, 181)
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
          child: Form(
        child: Column(children: <Widget>[
          SizedBox(
            height: 250,
          ),
          TextFormField(
            controller: a,
            decoration: InputDecoration(
                hintText: 'EMAIL',
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(30)),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                suffixText: ''),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (email) =>
                email != null && !EmailValidator.validate(email)
                    ? 'enter valid email'
                    : t3 = null,
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: b,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: 'PASSWORD',
              prefixIcon: Icon(
                Icons.password,
                color: Colors.black,
              ),
              suffixIcon: IconButton(
                icon: v ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                onPressed: () => setState(
                  () => v = !v,
                ),
              ),
            ),
            obscureText: !v,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) =>
                value != null && value.length <= 6 ? 'invalid' : t2 = null,
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: c,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: 'PASSWORD',
              prefixIcon: Icon(
                Icons.password,
                color: Colors.black,
              ),
              suffixIcon: IconButton(
                icon: v ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
                onPressed: () => setState(
                  () => v = !v,
                ),
              ),
            ),
            obscureText: !v,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value == b.text && value!.length >= 6
                ? t = null
                : "Pass doesn't match",
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: d,
            decoration: InputDecoration(
                hintText: 'USERNAME',
                enabledBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(30)),
                prefixIcon: Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                suffixText: ''),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) => value == d.text && value!.length >= 4
                ? t4 = null
                : "Enter Longer Name",
          ),
          SizedBox(
            height: 50,
          ),
          InkWell(
            onTap: () async {
              if (a.text.isNotEmpty &&
                  b.text.isNotEmpty &&
                  c.text.isNotEmpty &&
                  d.text.isNotEmpty &&
                  t4 == null &&
                  t == null &&
                  t2 == null &&
                  t3 == null) {
                try {
                  FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: a.text, password: b.text);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => mainpage2(
                                e: a.text,
                                d: d.text,
                              )));
                } on FirebaseAuthException catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            content: Text(e.message!.trim()),
                          ));
                }
              } else {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: Border(left: BorderSide()),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "OK",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 242, 181, 39)),
                            ),
                          )
                        ],
                        title: Text("Enter Valid Details! "),
                        backgroundColor: Colors.amber,
                      );
                    });
              }
            },
            child: Container(
              child: Text(
                'Sign Up',
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.black),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text('Already have an account?'),
          TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => login()));
              },
              child: Text(
                'Sign In',
                style: TextStyle(color: Colors.amber),
              ))
        ]),
      )),
      backgroundColor: Color.fromARGB(255, 117, 104, 104),
    );
  }
}

// Future signUp() async {
//     await FirebaseAuth.instance
//         .createUserWithEmailAndPassword(
//           email: a.text.trim(),
//           password: b.text.trim(),
//         )
//         .then((value) => Navigator.push(
//             context, MaterialPageRoute(builder: (context) => mainpage())));
//   }
// }

class Utils {
  static showSnackBar(String? text) {
    final messengerkey = GlobalKey<ScaffoldMessengerState>();
    if (text == null) return;

    final snackBar = SnackBar(content: Text(text));
    messengerkey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

////////////////////////////////////////////////////////////////////////////////////
class reset extends StatefulWidget {
  const reset({Key? key}) : super(key: key);

  @override
  State<reset> createState() => _resetState();
}

class _resetState extends State<reset> {
  final a = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PASSWORD RESET',
          style: TextStyle(color: Colors.amber),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 200,
            ),
            TextFormField(
              controller: a,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Enter Email'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (email) =>
                  email != null && !EmailValidator.validate(email)
                      ? 'invalid'
                      : null,
            ),
            SizedBox(
              height: 50,
            ),
            MaterialButton(
              onPressed: send,
              child: Text(
                'RESET',
                style: TextStyle(color: Colors.amber),
              ),
              color: Colors.black,
            ),
          ],
        ),
      ),
      backgroundColor: Color.fromARGB(255, 133, 111, 111),
    );
  }

  Future send() async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: a.text);
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text('check your email'),
            ));
  }
}
