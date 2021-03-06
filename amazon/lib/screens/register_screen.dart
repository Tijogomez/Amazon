import 'dart:ui';
import 'package:email_validator/email_validator.dart';
import 'package:amazon/db/UserDataSource.dart';
import 'package:amazon/screens/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final items = ['Supervisor', 'Administrator', 'Delivery Agent'];
  String? value;
  bool _emailValid = false;
  bool _passwordValid = false;
  bool _numberValid = false;
  final UserDataSource dataSource = UserDataSource();
  String username = "",
      password = "",
      confirmedPassword = "",
      email = "",
      phoneNumber = '';

  Future<bool> registerUser() async {
    if (username.isEmpty || password.isEmpty || confirmedPassword.isEmpty)
      return false;

    if (password != confirmedPassword) return false;
    await dataSource.createUser(username, password, email);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text(
          'Sign Up Page',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Form(
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 80.0,
                  ),
                  const Text(
                    'Register Here',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 34.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        username = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Username',
                        prefixIcon: Icon(
                          Icons.account_box,
                          size: 30.0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          _emailValid = false;
                          return 'Please enter your email';
                        } else if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)) {
                          _emailValid = false;
                          return 'Please enter a valid email';
                        }
                        _emailValid = true;
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Email',
                        prefixIcon: Icon(
                          Icons.email,
                          size: 30.0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        phoneNumber = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          _numberValid = false;
                          return 'Please enter your phone number';
                        } else if (!RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)')
                            .hasMatch(value)) {
                          _numberValid = false;
                          return 'Please enter a valid number';
                        }
                        _numberValid = true;
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Phone Number',
                        prefixIcon: Icon(
                          Icons.phone,
                          size: 30.0,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 25.0, top: 8, bottom: 8),
                    child: Container(
                        width: 385,
                        child: DropdownButton<String>(
                            icon: Icon(Icons.arrow_drop_down),
                            hint: Text('Role'),
                            value: value,
                            iconSize: 15,
                            isExpanded: true,
                            items: items.map(buildMenuItem).toList(),
                            onChanged: (value) =>
                                setState(() => this.value = value))),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          _passwordValid = false;
                          return 'Please enter a password';
                        } else if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                            .hasMatch(value)) {
                          _passwordValid = false;
                          return 'Please enter a valid password';
                        }
                        _passwordValid = true;
                        return null;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Password (Use numbers and sp charaters)',
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 30.0,
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: TextField(
                      onChanged: (value) {
                        confirmedPassword = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Confirm Password',
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 30.0,
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 23.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        if (_emailValid && _passwordValid && _numberValid) {
                          await registerUser();
                          Navigator.of(context, rootNavigator: true)
                              .pushReplacement(
                            new CupertinoPageRoute(
                              builder: (BuildContext context) =>
                                  new LoginScreen(),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Registration Successful'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Please fill all fields'),
                            ),
                          );
                        }
                      },
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}

DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(item),
    );
