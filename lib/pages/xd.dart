import 'package:flutter/material.dart';

import 'home.dart';

class AgainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Action Screen'),
        brightness: Brightness.dark,
        backgroundColor: Color(0xff25354E),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            'You are already registered!',
            style: TextStyle(color: Colors.black, fontSize: 22),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff25354E),
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => MyHomePage()));
        },
        child: Icon(Icons.arrow_forward_ios_sharp),
      ),
    );
  }
}
