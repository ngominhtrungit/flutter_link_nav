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

    // Initialize deep link handler with fallback for unknown routes
    DeepLinkHandler().init(
      context,
      onUnknownRoute: (uri) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unknown route: ${uri.path}')));
      },
      onError: (e, stack) {
        debugPrint('Deep link error: $e');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Screen')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is the main screen.',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  ExampleAppRoutes.detailScreen,
                  arguments: {'id': 2},
                );
              },
              child: const Text('Go to Detail Screen'),
            ),
            ElevatedButton(
              onPressed: () {
                AppRoutes.executeRouteAction(
                  'sheet',
                  arguments: {'label': 'Action executed from button'},
                );
                // Navigator.pushNamed(context, 'sheet', arguments:{'label': 'Action executed from button'}  );
              },
              child: const Text('Show Sheet (Action)'),
            ),
          ],
        ),
      ),
    );
  }
}
