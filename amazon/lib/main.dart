import 'package:amazon/screens/home_screen.dart';
import 'package:amazon/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  bool isLoggedIn = false;

  checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print("user is logged in = $isLoggedIn");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AmazonDelivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.black),
      home: FutureBuilder(
        future: checkIfLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return isLoggedIn ? const HomeScreen() : const LoginScreen();
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}
