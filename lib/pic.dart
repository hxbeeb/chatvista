import 'package:flutter/material.dart';

class pict extends StatefulWidget {
  var pic;
  pict({super.key, this.pic});

  @override
  State<pict> createState() => _pictState();
}

class _pictState extends State<pict> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          child: Center(
            child: Image.network(
              widget.pic,
              height: 900,
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 56, 46, 46),
    );
  }
}
