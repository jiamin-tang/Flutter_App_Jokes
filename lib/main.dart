import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:convert';

//This is an App for displaying jokes. Everytime the user hits the button, the page refreshes 
//and grabs the joke setup from API. When loading data, the page shows "waiting". 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Fetch Data'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


Future<Joke> fetchJoke() async {
  final res = await http.get('https://sv443.net/jokeapi/v2/joke/Any');

  if (res.statusCode == 200) {
    return Joke.fromJson(jsonDecode(res.body));
  } else {
    throw Exception('Failed to load joke');
  }
}

class Joke {
  final String error;
  final String category;
  final String type;
  final String setup;
  final String delivery;
  final String flags;
  final int id;
  final String lang;

  Joke({this.error, this.category, this.type, this.setup, this.delivery, this.flags, this.id, this.lang});

  factory Joke.fromJson(Map<String, dynamic> json) => Joke(
    error: json['error'],
    category: json['category'],
    type: json['type'],
    setup: json['setup'],
    delivery: json['delivery'],
    flags: json['flags'],
    id: json['id'],
    lang: json['lang'],
  );

}

class _MyHomePageState extends State<MyHomePage> {

  Future<Joke> futureJoke;

  @override
  void initState() {
    super.initState();
    futureJoke = fetchJoke();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () {
        setState(() {
          futureJoke = fetchJoke();
        });
      },child: Icon(Icons.refresh),),

      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(          
        child: FutureBuilder<Joke>(
            future: futureJoke,
            builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                print("waiting");
                return Text('waiting');
              case ConnectionState.done:
                if (snapshot.hasData) {
                return Text(snapshot.data.setup);
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
            }

              // By default, show a loading spinner.
              return CircularProgressIndicator();
            },
          ),
      ),
    );
  }
}
