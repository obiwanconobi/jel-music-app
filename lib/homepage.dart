import 'package:flutter/material.dart';
import 'package:jel_music/widgets/start_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child:  Column(
          children: [
            Expanded(child: StartPage()),
          ],
        )
      ),
    );
  }
}
