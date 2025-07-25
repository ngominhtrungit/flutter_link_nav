import 'package:example/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_nav/flutter_link_nav.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = 'main_screen';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    /// option 1: use the default deep link handler
    DeepLinkHandler().init(context);
    /// option 2: use a custom deep link handler
    // DeepLinkHandler().init(context, customHandler: (context, uri) {
    //   // Custom deep link handling logic can be added here
    //   debugPrint('MainScreen Custom deep link handler: $uri');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('This is the main screen.', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, ExampleAppRoutes.detailScreen);
              },
              child: const Text('Go to Detail Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
