import 'package:flutter/material.dart';

import 'main_screen.dart';

class DetailScreen extends StatelessWidget {
  static const String routeName = 'detail_screen';

  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Screen')),
      body: Center(
        child: Column(
          children: [
            Text('This is a detail screen.', style: TextStyle(fontSize: 24)),

            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (ModalRoute.withName(MainScreen.routeName)),
                );
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
