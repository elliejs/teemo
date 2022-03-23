import 'package:flutter/material.dart';
import 'package:teemo/teemo.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final Future<Teemo> _teemo = Teemo.create();

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2!,
      textAlign: TextAlign.center,
      child: FutureBuilder<Teemo>(
        future: _teemo, // a previously-obtained Future<String> or null
        builder: (BuildContext context, AsyncSnapshot<Teemo> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            children = <Widget>[
              OutlinedButton(
                onPressed: () {
                  snapshot.data?.setCurrentRunePage(
                      Rune.Conqueror,
                      Rune.Triumph,
                      Rune.LegendTenacity,
                      Rune.LastStand,
                      Rune.Transcendence,
                      Rune.GatheringStorm,
                      Rune.AdaptiveForcePerk,
                      Rune.AdaptiveForcePerk,
                      Rune.HealthPerk,
                      name: 'Riven');
                },
                child: Text("Send Me To A Custom Lobby"),
              )
            ];
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              )
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
