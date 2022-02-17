import 'package:amazon/db/TasksDataSource.dart';
import 'package:amazon/db/UserDataSource.dart';
import 'package:amazon/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final TasksDataSource tasksDataSource = TasksDataSource();

  CustomDrawer({Key? key}) : super(key: key);

  Future clearDatabase() async {
    await tasksDataSource.deleteAll();
  }

  _buildDrawerItems(Icon icon, String title, Function onTap) {
    return ListTile(
      leading: icon,
      onTap: () {
        onTap();
      },
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }

  final user = UserDataSource.loggedInUser;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: EdgeInsets.only(top: 30.0),
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text(
                  user!.username,
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              )
            ],
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(bottom: 80.0),
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: _buildDrawerItems(Icon(Icons.logout), 'LogOut', () async {
                // await clearDatabase();
                Navigator.of(context, rootNavigator: true).pushReplacement(
                  new CupertinoPageRoute(
                    builder: (BuildContext context) => new MyApp(),
                  ),
                );
              }),
            ),
          ))
        ],
      ),
    ));
  }
}
