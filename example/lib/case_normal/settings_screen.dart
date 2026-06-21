import 'package:example/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

class SettingsScreen extends StatelessWidget {
  final int userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Settings for User $userId',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // HOW IT WORKS:
                // 1. The previous DetailScreen was pushed with the actual path 'detail_screen/999'.
                // 2. Using Flutter's standard ModalRoute.withName('detail_screen') will fail because 'detail_screen/999' != 'detail_screen'.
                // 3. Solution: Use AppRoutes.withName() from the library and pass the exact Route Pattern.
                // 4. The library will intelligently match 'detail_screen/999' as an instance of 'detail_screen/:id' and pop to the correct screen.
                Navigator.popUntil(
                  context,
                  AppRoutes.withName('${ExampleAppRoutes.detailScreen}/:id'),
                );
              },
              child: const Text('Pop until User Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  AppRoutes.withName('detail_screen'),
                );
              },
              child: const Text('Pop until User Profile (error)'),
            ),
            const Text(
              '''HOW IT WORKS:
              1. The previous DetailScreen was pushed with the actual path 'detail_screen/999'.
              2. Using Flutter's standard ModalRoute.withName('detail_screen') will fail because 'detail_screen/999' != 'detail_screen'.
              3. Solution: Use AppRoutes.withName() from the library and pass the exact Route Pattern.
              4. The library will intelligently match 'detail_screen/999' as an instance of 'detail_screen/:id' and pop to the correct screen.''',
            ),
            ElevatedButton(
              onPressed: () {
                // For normal screens without Path Parameters (like main_screen),
                // AppRoutes.withName() works exactly like Flutter's native ModalRoute.withName().
                Navigator.popUntil(context, AppRoutes.withName('main_screen'));
              },
              child: const Text('Pop until Main Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
