import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_reader/auth.dart';
import 'package:simple_reader/favorite.dart';
import 'package:simple_reader/model.dart';
import 'package:simple_reader/weibo.dart';

void main() => runApp(MyApp());

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
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [WeiboPage(), FavoritePage()];
  String accessToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weibo"),
      ),
      floatingActionButton: (accessToken == null)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WebPage()), //
                );
              },
              child: Icon(Icons.navigation),
            )
          : null,
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Home'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            title: Text('Favorite'),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  static const platform = const MethodChannel('samples.flutter.dev/battery');

  @override
  void initState() {
    super.initState();

    checkAccessToken();

    // Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    // prefs.then((value) {
    //   try {
    //     print("SharedPreferences");
    //     print(value.getString('access_token'));
    //     // final Future<String> result = platform.invokeMethod('getBatteryLevel');
    //     // result.then((value1) {
    //     //   value.setString('access_token', value1);
    //     // });
    //   } on PlatformException catch (e) {
    //     print("Failed to get battery level: '${e.message}'.");
    //   }
    // });
  }

  void checkAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString("access_token");
    DatabaseHelper.accessToken = token;
    if (token != null) {
      setState(() {
        accessToken = token;
      });
    }
  }
}
