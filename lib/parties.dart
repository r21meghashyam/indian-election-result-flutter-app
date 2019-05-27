import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart';



class PartiesRoute extends StatefulWidget {
  PartiesRoute();

  @override
  PartiesRouteState createState() => PartiesRouteState();
}

class PartiesRouteState extends State<PartiesRoute> {

  List<String> sortOptions = ['votes','name','seats'];
  int sortBy=0;

   Card partyCard(BuildContext context, Party party) {
    final formatter = new NumberFormat();
    String total = formatter.format(party.totalVotes);
    return new Card(
        child: new Container(
      child: Column(
        children: <Widget>[
          Text(party.name),
          Text(party.totalSeats.toString()+" seats"),
          Text(total+" votes"),
        ],
      ),
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
    ));
  }
  List<dynamic> orderParties(List<Party> parties){
    parties.sort((first,second){
      switch(sortOptions[sortBy]){
        case 'name': 
          return first.name.compareTo(second.name);
        case 'votes': 
          return second.totalVotes-first.totalVotes;
        case 'seats':
          return second.totalSeats-first.totalSeats;
        
        
      }
      return -1;
    });
    return parties.map((party)=>partyCard(context,party)).toList();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Party>>(
            future: loadPartiesList(),
            builder: (context, snapshot) {
              List<Party> parties = snapshot.data;
              if(snapshot.hasData)
                return SingleChildScrollView(
                    child:Column(children:orderParties(parties)));
              if(snapshot.hasError)
                return Center(child:Text("${snapshot.error}"));
              return Center(child: CircularProgressIndicator()); 
            }
        
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Party {
  String name;
  int totalVotes=0;
  int totalExposure;//total no of people in all participating constituency
  int totalSeats=0;
  int totalConstituencies;
  Party(dynamic json){
    this.name = json['party_name'];
    this.totalVotes=0;
  }
}
class Constituency{
  String name;
  String province;
  int winnerVotes;
  Party winnerParty;
  Constituency(dynamic json,List<Party> parties){
    this.name = json['constituency_name'];
    this.province = json['province_name'];
    this.winnerVotes = json['total_votes'];
    this.winnerParty = parties.firstWhere((item)=>item.name==json['party_name']);
    this.winnerParty.totalSeats++;
    this.winnerParty.totalVotes+=json['total_votes'];
  }
  void update(dynamic json,List<Party> parties){
    if(this.winnerVotes>json['total_votes'])
      return;

    this.winnerParty.totalSeats--;
    this.winnerParty = parties.firstWhere((item)=>item.name==json['party_name']);
    this.winnerParty.totalSeats++;
    this.winnerVotes=json['total_votes'];
    this.winnerParty.totalVotes+=this.winnerVotes;
  }
}

Future<List<Party>> loadPartiesList() async {
  String jsonString = await rootBundle.loadString('assets/candidates.json');
  List<dynamic> jsonResponse = await json.decode(jsonString);
  List<Party> parties = new List();
  List<Constituency> constituencies = new List();

  jsonResponse.forEach((item){
    if(!parties.any((party)=>party.name==item['party_name']))
      parties.add(new Party(item));
    if(!constituencies.any((constituency)=>constituency.name==item['constituency_name']&&constituency.province==item['province_name']))
      constituencies.add(new Constituency(item, parties));
    else{
      constituencies.firstWhere((constituency)=>constituency.name==item['constituency_name']&&constituency.province==item['province_name']).update(item, parties);
    }
  });

  return parties;
}