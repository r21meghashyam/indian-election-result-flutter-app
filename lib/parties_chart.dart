import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:charts_flutter/flutter.dart' as charts;

class PartiesChartRoute extends StatefulWidget {
  PartiesChartRoute();

  @override
  PartiesChartRouteState createState() => PartiesChartRouteState();
}

class PartiesChartRouteState extends State<PartiesChartRoute> {
  bool sortByName = true;
  List<Party> sortPartiesChart(List<Party> parties) {
    
    parties.sort((first, second) {
      if (sortByName)
        return first.partyName.compareTo(second.partyName);
      else
        return second.seats - first.seats;
    });
    return parties;
  }

  generateLabels(List<Party>parties) {
    parties.sort((first,second){
      return second.seats - first.seats;
    });
    List<Party> top = parties.sublist(0,5);
    int seats=0;
    top.forEach((party){
      seats+=party.seats;
    });
    top.add(Party(partyName: 'OTHERS',seats: 534-seats));

    

    return top; 
    // return [
    //   new PartiesLabel('BJP', 100),
    //   new PartiesLabel('CONGRESS', 75),
    //   new PartiesLabel('JDS', 25),
    //   new PartiesLabel('3', 5),
    // ];
  }

  String shortName(String name){
    RegExp exp = new RegExp("[A-Z]");
    Iterable<Match> matches = exp.allMatches(name);
    String short = "";
    matches.forEach((match){
      
      short += name[match.start];
    });
    //print(short);
    return short;
  } 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List>(
          future: fetchPartiesChart(),
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return Center(child:Container(width: MediaQuery.of(context).size.width-100 ,child:charts.PieChart([
                new charts.Series<Party, String>(
                  id: 'Sales',
                  domainFn: (Party party, _) => shortName(party.partyName),
                  measureFn: (Party party, _) => party.seats,
                  colorFn: (Party party, _) => party.color,
                  labelAccessorFn: (Party party, _) =>
                      '${shortName(party.partyName)}\n ${party.seats}',
                      
                  data: generateLabels(snapshot.data),

                )
              ],
                  defaultRenderer: new charts.ArcRendererConfig(
                      
                      arcWidth: 70,
                      arcRendererDecorators: [
                        
          new charts.ArcLabelDecorator(
              labelPadding: 10,
              outsideLabelStyleSpec: charts.TextStyleSpec(fontSize: 8),
              labelPosition: charts.ArcLabelPosition.auto),
              
        ], 
                      
                      )
                      ,
                      
                      )));
            else
              return Center(child: CircularProgressIndicator());
          }
          // This trailing comma makes auto-formatting nicer for build methods.
          ),
    );
  }
}

class Party {
  String partyName;
  int seats;
  Map<String,String> colors = {
      'BJP': '0f07238',
      'INC': '03d881f',
      'DMK': '0000000',
      'YSRCP': '0134a7c',
      'AITC': '0266dac'
    };
  String shortName="";
  charts.Color color = charts.Color.fromHex(code:"AAAAAA0");
  Party({this.partyName, this.seats}){
    RegExp exp = new RegExp("[A-Z]");
        Iterable<Match> matches = exp.allMatches(this.partyName);
        matches.forEach((match){
          shortName += this.partyName[match.start];
        });
    if(colors[shortName]!=null)
      color=charts.Color.fromHex(code: colors[shortName]);
  }
  
}

Future<List> fetchPartiesChart() async {
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
    var seats = int.parse(tr.children[1].text);
    return new Party(partyName: partyName, seats: seats);
  });
  return parties.toList();
}

