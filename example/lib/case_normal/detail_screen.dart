import 'package:flutter/material.dart';

import 'main_screen.dart';

class DetailScreen extends StatelessWidget {
  static const String routeName = 'detail_screen';

  final int id;

  const DetailScreen({super.key, this.id = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is a detail screen.',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              'Item ID: $id',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  (ModalRoute.withName(MainScreen.routeName)),
                );
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
