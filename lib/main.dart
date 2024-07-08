import 'dart:io';

import 'package:banking_track/pages/login_test.dart';
import 'package:flutter/material.dart';
import 'package:banking_track/pages/login.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import 'package:banking_track/pages/multiuser/user_login.dart';
Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }
  databaseFactory = databaseFactoryFfi;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFFF8E1), // Ivory
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF001F3F)), // Navy Blue
          displayMedium: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF006400)), // Dark Green
          bodyLarge: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(255, 16, 24, 33)), // Dark Slate Gray
          bodyMedium: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Color(0xFF001F3F)),
          bodySmall: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              color: Color(0xFF008080)),
          // Teal
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 25),
          color: Color(0xFF4B0082), // Deep Purple
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFFDC143C), // Crimson Red
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF008080), // White text
            textStyle:
                const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF8C00), // Dark Orange
        ),
      ),
      // darkTheme: ThemeData.dark(useMaterial3: true),
      home: MyWidget(),
    );
  }
}

// class MyWidget extends StatelessWidget {
//   const MyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black26,
//         title: const Text(
//           "Banking",
//           style: TextStyle(color: Colors.amber),
//         ),
//       ),
//       body: BankingApp(),
//     );
//   }
// }

class MyWidget extends StatelessWidget {
  MyWidget({super.key});
  final TextEditingController _usernameLoginController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  void _checkLogin(BuildContext context) {
    String username = _usernameLoginController.text;
    String password = _passwordController.text;
    if (username == 'prasadrajanmenon' && password == 'Prm@2024F') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BankingApp()));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid credentials')));
    }
    _passwordController.clear();
    _usernameLoginController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.black26,
        title: Text(
          "Banking ",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              style: Theme.of(context).textTheme.displayMedium,
              controller: _usernameLoginController,
              decoration: InputDecoration(
                labelStyle: Theme.of(context).textTheme.displayMedium,
                label: const Text("Username"),
              ),
            ),
            TextFormField(
              controller: _passwordController,
              style: Theme.of(context).textTheme.displayMedium,
              decoration: InputDecoration(
                  labelStyle: Theme.of(context).textTheme.displayMedium,
                  label: const Text("Password")),
              obscureText: true,
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
                // style: Theme.of(context).buttonTheme.buttonColor,
                onPressed: () => _checkLogin(context),
                child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}
