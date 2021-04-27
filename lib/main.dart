import 'package:flutter/material.dart';
import 'package:checkout/entry_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check Out',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Check Out'),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var loc_name = [];
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yy');

  @override
  initState()  {
    //initial state
    _getName();
  }

  void _getName() async {
    //EasyLoading.show(status: 'loading...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String lastdate = await prefs.getString("last_date");
    String receivedJson = await prefs.getString("loc_name");
    var list = json.decode(receivedJson);
    if (lastdate != formatter.format(now)){
      list.asMap().forEach((index, value) {
        list[index]["data"].asMap().forEach((ind, value) {
          list[index]["data"][ind]["status"] = false;
        });
      });
      setState(() {
        loc_name.addAll(list);
      });
      await prefs.setString("loc_name", json.encode(loc_name));
    } else {
      setState(() {
        loc_name.addAll(list);
      });
    }
    await prefs.setString("last_date", formatter.format(now));
    final snackBar = SnackBar(content: Text("Today date ${formatter.format(now)}"));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //EasyLoading.dismiss();
  }

  void refreshData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String receivedJson = await prefs.getString("loc_name");
    var list = json.decode(receivedJson);
    setState(() {
      loc_name = [];
      loc_name.addAll(list);
    });
    await prefs.setString("loc_name", json.encode(loc_name));
  }

  TextEditingController nameController = new TextEditingController();
  Future<String> NameAlertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Enter a Name"),
        content: TextField(
          controller: nameController,
        ),
        actions: <Widget>[
          MaterialButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              }
          ),
          MaterialButton(
               child: Text('Submit'),
              onPressed: () {
                  Navigator.of(context).pop(nameController.text.toString());
                  nameController.text = "";
              }
          )
        ],
      );
    });
  }

  Future<String> YONAlertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Are you sure to delete this?"),
        actions: <Widget>[
          MaterialButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop("no");
              }
          ),
          MaterialButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop("yes");
              }
          )
        ],
      );
    });
  }

  void _addList(name) async {
    //EasyLoading.show(status: 'loading...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loc_name.add({"name": name, "data": []});
    });
    final snackBar = SnackBar(content: Text('Location Added'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await prefs.setString("loc_name", json.encode(loc_name));
    //EasyLoading.dismiss();
  }

  void _locDelete(index) async {
    //EasyLoading.show(status: 'loading...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loc_name.removeAt(index);
    });
    final snackBar = SnackBar(content: Text('Location Deleted'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await prefs.setString("loc_name", json.encode(loc_name));
    //EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Center(
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => refreshData(),
            ),
          )
        ],
      ),
      body: Center(
        child: loc_name.length == 0 ? NoList() : ListView.builder(
          itemCount: loc_name.length,
          itemBuilder: (BuildContext context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6,horizontal: 4),
              elevation: 5,
              child: ListTile(
                title: Text(loc_name[index]['name']),
                selectedTileColor: Colors.amberAccent,
                selected: loc_name[index]["data"].where((element) => element["status"] == false).length == 0 ? loc_name[index]["data"].length != 0 ? true : false : false,
                trailing: IconButton(
                  icon: Icon(Icons.restore_from_trash_rounded),
                  onPressed: () {
                    YONAlertDialog(context).then((value) {
                      if (value == "yes"){
                        _locDelete(index);
                      }
                    });
                  },
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder:
                      (context) =>
                          EntryScreen(id: index)
                  )
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NameAlertDialog(context).then((value) {
            if (value.isNotEmpty){
              _addList(value);
            } else {
              final snackBar = SnackBar(content: Text(
                  'Please enter name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.0
                  ),
              ));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget NoList(){
    return Center(
      child: Text("There is no item."),
    );
  }
}

class Fact {
  String name;
  String email;

  Fact(this.name, this.email);

  Fact.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'];

  Map<String, dynamic> toJson() =>
      {
        'name' : name,
        'email': email,
      };
}

class User {
  final String name;
  final String email;

  User(this.name, this.email);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'];

  Map<String, dynamic> toJson() =>
      {
        'name': name,
        'email': email,
      };
}