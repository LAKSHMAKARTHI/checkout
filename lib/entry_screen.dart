import 'package:checkout/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';

class EntryScreen extends StatefulWidget {
  final int id;
  EntryScreen({Key key, @required this.id}) : super(key: key);

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  List entryList = [];

  @override
  initState(){
    //initial state
    _getData();
  }

  void _getData() async {
    EasyLoading.show(status: 'loading...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String receivedJson = await prefs.getString("loc_name");
    var list = json.decode(receivedJson);
    entryList.clear();
    setState(() {
      entryList.addAll(list);
    });
    EasyLoading.dismiss();
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

  TextEditingController itemController = new TextEditingController();
  Future<String> ItemAlertDialog(BuildContext context){
    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Enter a Name"),
        content: TextField(
          controller: itemController,
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
                Navigator.of(context).pop(itemController.text.toString());
                itemController.text = "";
              }
          )
        ],
      );
    });
  }

  void _addItem(name) async {
    EasyLoading.show(status: 'loading...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      entryList[widget.id]["data"].add({"title": name, "status": false});
    });
    final snackBar = SnackBar(content: Text('List Added'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await prefs.setString("loc_name", json.encode(entryList));
    EasyLoading.dismiss();
  }

  void _itemDelete(index) async {
    EasyLoading.show(status: 'loading...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      entryList[widget.id]["data"].removeAt(index);
    });
    final snackBar = SnackBar(content: Text('Item Deleted'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await prefs.setString("loc_name", json.encode(entryList));
    EasyLoading.dismiss();
  }

  void _resetData() async {
    EasyLoading.show(status: 'loading...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      entryList.asMap().forEach((index, value) {
        entryList[index]["data"].asMap().forEach((ind, value) {
          entryList[index]["data"][ind]["status"] = false;
        });
      });
    });
    final snackBar = SnackBar(content: Text('Item Deleted'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    await prefs.setString("loc_name", json.encode(entryList));
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${entryList.length == 0 ? "Loading" : entryList[widget.id]["name"] }'),
        actions: [
          Center(
            child: IconButton(
              icon: Icon(Icons.cleaning_services),
              onPressed: () => _resetData(),
            ),
          )
        ],
      ),
      body: Center(
        child: entryList.length == 0 ? NoList() : ListView.builder(
          itemCount: entryList[widget.id]["data"].length,
          itemBuilder: (BuildContext context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 6,horizontal: 4),
              elevation: 5,
              child: ListTile(
                leading: Checkbox(
                  value: entryList[widget.id]["data"][index]["status"],
                ),
                title: Text(entryList[widget.id]["data"][index]["title"]),
                trailing: IconButton(
                  icon: Icon(Icons.restore_from_trash_rounded),
                  onPressed: ()  {
                    YONAlertDialog(context).then((value) {
                      if (value == "yes"){
                        _itemDelete(index);
                      }
                    });
                },
                ),
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  entryList[widget.id]["data"][index]["status"] = entryList[widget.id]["data"][index]["status"] ? false : true;
                  var isCheckAll = entryList[widget.id]["data"].where((element) => element["status"] == false).length;
                  if (isCheckAll == 0){
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      entryList[widget.id]["data"][index]["status"] = entryList[widget.id]["data"][index]["status"];
                    });
                  }
                  await prefs.setString("loc_name", json.encode(entryList));
                },
              ),
            );
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ItemAlertDialog(context).then((value) {
            if (value.isNotEmpty){
              _addItem(value);
            } else {
              final snackBar = SnackBar(content: Text('Please enter name'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget NoList(){
    return Center(
      child: Text("There is no item."),
    );
  }
}
