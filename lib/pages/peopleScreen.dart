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
  List<String> latitudes = [];
  List<String> longitudes = [];

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
      latitudes.add(person[2]);
      longitudes.add(person[3]);
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
                          subtitle: Row(
                            children: [
                              Text(
                                'Latitude: ${latitudes[index]}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Longitude: ${longitudes[index]}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 14),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
