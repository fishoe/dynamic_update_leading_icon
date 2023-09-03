import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LeadingIconStatus(),
      child: const MaterialApp(
        home: AppBody(),
      ),
    );
  }
}

class AppBody extends StatelessWidget {
  const AppBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<LeadingIconStatus>();
    var isBell = appState.isBell;
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Body"),
        leading: LeadingIcon(isBell: isBell),
      ),
      body: const BodyRouter(),
    );
  }
}

class BodyRouter extends StatelessWidget {
  const BodyRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '1',
      onGenerateRoute: interceptor(context),
      observers: [MyRouteObserver(context)],
    );
  }

  Route<MaterialPageRoute> Function(RouteSettings) interceptor (BuildContext context) {
    return (RouteSettings settings) {
      WidgetBuilder builder = switch (settings.name) {
        "1" => (context) => const FirstPage(),
        "2" => (context) => const SecondPage(),
        "3" => (context) => const ThirdPage(),
        _ => throw Exception("Invalid route: ${settings.name}"),
      };
      return MaterialPageRoute(builder: builder, settings: settings);
    };
  }

}

class LeadingIcon extends StatelessWidget {
  const LeadingIcon({super.key, required this.isBell});
  final bool isBell;

  @override
  Widget build(BuildContext context) {
    return ( isBell ) ? _circleIcon(context) : _arrowIcon(context);
  }

  Widget _circleIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.circle),
      iconSize: 40,
      onPressed: () {
        debugPrint("pushed a circle button");
      },
    );
  }

  Widget _arrowIcon(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      iconSize: 40,
      onPressed: () {
        Navigator.of(context).pushNamed('2');
      },
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('2');
          },
          child: const Text("Go to Second Page"),
        ),
      );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pushNamed('3');
        },
        child: const Text("Go to Third Page"),
      ),
    );
  }
}

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Text("Go to First Page"),
      ),
    );
  }
}

class MyRouteObserver extends NavigatorObserver {
  MyRouteObserver(this.context);
  final BuildContext context;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    String? routeName = previousRoute?.settings.name;
    if (routeName != null) {
      context.read<LeadingIconStatus>().currentRoute(routeName);
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    String? routeName = previousRoute?.settings.name;
    if (routeName != null) {
      context.read<LeadingIconStatus>().currentRoute(routeName);
    }
    super.didPush(route, previousRoute);
  }
}


class LeadingIconStatus extends ChangeNotifier {
  bool isBell = true;

  void currentRoute(String route) {
    isBell = route == "1";
    notifyListeners();
  }
}