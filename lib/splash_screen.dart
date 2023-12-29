import 'dart:async';

import 'package:flutter/material.dart';

import 'login_screen.dart';

// void main() {
//   runApp(SplashScreen());
// }

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => StartState();
}

class StartState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTime();
  }

  startTime() async {
    var duration = const Duration(seconds: 4);
    return Timer(duration, route);
  }

  route() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return initWidget(context);
  }

  Widget initWidget(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              // gradient: LinearGradient(
              //     colors: [(new Color(0xff71aa34)), new Color(0xffa0c677)],
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter)
            ),
          ),
          Center(
            child: SizedBox(
              height: 150,
              child: Image.asset("images/leaf.png"),
            ),
          )
        ],
      ),
    );
  }
}
