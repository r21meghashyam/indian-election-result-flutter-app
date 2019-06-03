import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class PartiesRoute extends StatefulWidget {
  PartiesRoute();

  @override
  PartiesRouteState createState() => PartiesRouteState();
}

class PartiesRouteState extends State<PartiesRoute> {
bool sortByName = true;
List<Party> sortParties(List<Party> parties){
    parties.sort((first,second){
      if(sortByName)
        return first.partyName.compareTo(second.partyName);
      else
       return int.parse(second.seats) - int.parse(first.seats);
    });
  return parties;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List>(
          future: fetchParties(),
          builder: (context, snapshot) {
            print(snapshot);
            if (snapshot.hasData)
              return SingleChildScrollView(
                  child: Column(
                children: <Widget>[
                  Ink(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Center(
                                child: Container(
                          child: Text("Party",
                              style: TextStyle(color: Colors.white)),
                          padding: EdgeInsets.all(20),
                        ))),
                        Expanded(
                            child: Center(
                                child: Container(
                          child: Text("Seats",
                              style: TextStyle(color: Colors.white)),
                          padding: EdgeInsets.all(20),
                        ))),
                      ],
                    ),
                    color: Colors.blue,
                  ),
                  Column(
                      children: sortParties(snapshot.data)
                          .map((party) => Column(children: [
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Center(
                                            child: Container(
                                      child: Text(party.partyName,
                                          style:
                                              TextStyle(color: Colors.black)),
                                      padding: EdgeInsets.all(20),
                                      alignment: Alignment.centerLeft,
                                    ))),
                                    Expanded(
                                        child: Center(
                                            child: Container(
                                      child: Text(party.seats,
                                          style:
                                              TextStyle(color: Colors.black)),
                                      padding: EdgeInsets.all(20),
                                    ))),
                                  ],
                                ),
                                Divider(color: Colors.grey)
                              ]))
                          .toList())
                ],
              ));
            else
              return Center(child: CircularProgressIndicator());
          }
          // This trailing comma makes auto-formatting nicer for build methods.
          ),
      floatingActionButton: new FloatingActionButton(
          elevation: 0.0,
          child: new Icon(Icons.sort),
          backgroundColor: Colors.blue,
          onPressed: () {
            setState((){
              sortByName  = !sortByName;
            });
          }),
    );
  }
}

class Party {
  String partyName;
  String seats;
  Party({this.partyName, this.seats});
}

Future<List> fetchParties() async {
  http.Response data =
      await http.get('http://results.eci.gov.in/pc/en/partywise/index.htm');
  var html = parse(data.body);
  var tableParty = html.getElementsByClassName("table-party")[0];
  var trs = tableParty.getElementsByTagName("tr");
  trs.removeRange(0, 3); //headings
  trs.removeLast(); //All Party
  trs.removeLast(); //total
  var parties = trs.map((tr) {
    var partyName = tr.children[0].text;
    var seats = tr.children[1].text;
    return new Party(partyName: partyName, seats: seats);
  });
  return parties.toList();
}
