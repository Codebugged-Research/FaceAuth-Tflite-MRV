import 'package:FaceNetAuthentication/pages/db/database.dart';
import 'package:flutter/material.dart';

class PeopleScreen extends StatefulWidget {
  @override
  _PeopleScreenState createState() => _PeopleScreenState();
}

class _PeopleScreenState extends State<PeopleScreen> {
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
    // print(dataBaseService.db);
    var people = dataBaseService.db.forEach((key, value) {
      var person = key.toString().split(':');
      names.add(person[0]);
    });

    print(names);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registered People'),
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
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                '${index + 1}.',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                              SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                names[index],
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                            ],
                          ),
                        );
                      }),
            ),
    );
  }
}
