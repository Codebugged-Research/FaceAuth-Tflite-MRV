import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/database.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  bool isLoading = false;
  DataBaseService dataBaseService = DataBaseService();

  List<String> names = [];

  @override
  void initState() {
    super.initState();
    loadDatabase();
  }

  loadDatabase() async {
    setState(() {
      isLoading = true;
    });
    dataBaseService.loadDB();
    dataBaseService.db.forEach((key, value) {
      var person = key.toString().split(':');
      names.add(person[0]);
    });

    print(names);
    setState(() {
      isLoading = false;
    });
  }

  Future<String> getTime(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Screen'),
        brightness: Brightness.dark,
        backgroundColor: Color(0xff25354E),
      ),
      body: isLoading
          ? CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(
                Color(0xff25354E),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: dataBaseService.db.length == 0 ||
                      dataBaseService.db.length == null
                  ? Center(
                      child: Text(
                      'No one is registered!',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ))
                  : ListView.builder(
                      itemCount: dataBaseService.db.length,
                      shrinkWrap: true,
                      itemBuilder: (_, int index) {
                        return ListTile(
                          leading: Text(
                            '${index + 1}.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          title: Text(
                            names[index],
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          subtitle: Text('Time: ${getTime(names[index])}'),
                        );
                      },
                    ),
            ),
    );
  }
}
