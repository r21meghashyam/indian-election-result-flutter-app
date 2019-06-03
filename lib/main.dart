import 'package:flutter/material.dart';
import 'provinces.dart';
import 'parties.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Indian Election 2019',
        theme: ThemeData(
          primaryColor: Colors.orange,
        ),
        home: MyAppScaffold());
  }
}

class MyAppScaffold extends StatefulWidget {
  @override
  MyAppScaffoldState createState() => MyAppScaffoldState();
}

class MyAppScaffoldState extends State<MyAppScaffold> {
  List<List> routes = [
    ['Constituency Wise', ProvincesRoute()],
    ['Party Wise', PartiesRoute()],
  ];
  int activeRouteIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
        appBar: AppBar(
          title: Text("Indian Election 2019",style: TextStyle(color: Colors.white),),
        ),
        body: routes[activeRouteIndex][1],
        drawer: Drawer(
          
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Indian Loksabha Election 2019',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(50.0),
                decoration: BoxDecoration(
                  color: Colors.orange,
                ),
              ),
              Column(
                  children: routes.map((route) {
                return Ink(
                  child: ListTile(
                    title: Text(
                      route[0],
                      style: TextStyle(
                          color: activeRouteIndex == routes.indexOf(route)
                              ? Colors.white
                              : Colors.black),
                    ),
                    onTap: () {
                      setState(() {
                        Navigator.of(context).pop();
                        activeRouteIndex = routes.indexOf(route);
                      });
                    },
                  ),
                  color: activeRouteIndex == routes.indexOf(route)
                      ? Colors.lightBlue
                      : Colors.white,
                );
              }).toList())
            ],
          ),
        )
        // This trailing comma makes auto-formatting nicer for build methods.
        );

    
  }
}
