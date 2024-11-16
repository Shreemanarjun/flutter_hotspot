import 'package:example/custom_ext.dart';
import 'package:flutter/material.dart';
import 'package:hotspot/hotspot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'hotspot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.purple,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.purple,
      ),
      home: const HotspotProvider(
        child: MyHomePage(title: 'Hotspot Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HotspotProvider.of(context).startFlow();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('hotspot').withCustomHotspot(
          order: 1,
          showCaseWidget: const Text(
              "We're going to give you an example tour with hotspot"),
          boxDecoration: BoxDecoration(
            color: Colors.red.withOpacity(
              0.6,
            ),
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              HotspotProvider.of(context).startFlow();
            },
          ).withHotspot(
            order: 4,
            icon: const Icon(Icons.play_arrow),
            title: 'Tour It!',
            text: 'Want to see the tour again? Tap this button',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have smashed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ).withCustomHotspot(
              order: 2,
              showCaseWidget: const Text(
                'This is the number of times you\'ve smashed the like button',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Like',
        child: const Icon(Icons.thumb_up),
      ).withHotspot(
        order: 3,
        title: 'Smash It!',
        text: 'Smash this button after the tour.',
      ),
    );
  }
}
