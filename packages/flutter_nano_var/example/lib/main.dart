import 'package:flutter/material.dart';
import 'package:flutter_nano_var/flutter_nano_var.dart';
import 'package:nano_var/nano_var.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// A [NanoVar] instance for the counter.
  ///
  /// Notice that this variable is declared in a [State] instance, which means
  /// the reference to the instance is kept even if the widget tree is rebuilt.
  final _counter = NanoVar(0);

  void _incrementCounter() {
    // Increment the counter's value directly.
    // It's not required to explicitly call setState in relation to this
    // change.
    _counter.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            // Use a NanoObs to track changes of _counter by calling watch.
            NanoObs(
              builder: (context, watch) => Text(
                '${watch(_counter)}',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
