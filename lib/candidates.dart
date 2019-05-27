import 'package:flutter/material.dart';
import 'constituencies.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:intl/intl.dart';


class CandidatesRoute extends StatefulWidget {
  final Constituency constituency;

  CandidatesRoute(this.constituency);
  
  @override
  CandidatesRouteState createState() => CandidatesRouteState(this.constituency);
}


class CandidatesRouteState extends State<CandidatesRoute> {
  final Constituency constituency;
  bool sortByVotes=true;
  CandidatesRouteState(this.constituency);

  Card candidateCard(BuildContext context, Candidate candidate) {
    final formatter = new NumberFormat();
    String total = formatter.format(candidate.total);
    return new Card(
        child: new Container(
      child: Column(
        children: <Widget>[
          Text(candidate.candidateName),
          Text(candidate.party),
          Text(total + " votes"),
          Text(candidate.voteShare + "%"),
        ],
      ),
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
    ));
  }

  List<Widget> candidateList(BuildContext context, AsyncSnapshot snapshot) {
    List<Widget> candidates = new List();
    print(snapshot.data.candidates.length);
    CandidatesList candidateslist = snapshot.data;

    candidateslist.candidates.sort((first, second) {
      if(sortByVotes)
        return  second.total - first.total;
      else
        return first.osn - second.osn;
    });
    candidateslist.candidates.forEach((candidate) {
      candidates.add(candidateCard(context, candidate));
    });
    return candidates;
  }

  @override
  Widget build(BuildContext context) {
    print(constituency.constituencyName);
    return Scaffold(
        appBar: AppBar(
          title: Text(constituency.constituencyName),
        ),
        body: FutureBuilder<CandidatesList>(
            future: loadCandidatesList(constituency),
            builder: (context, snapshot) {
              print(snapshot.hasError);
              if (snapshot.hasData) {
                return SingleChildScrollView(
                    child: Column(
                      children:[
                        Container(
                          child: 
                          Text(
                            sortByVotes?"Sorted by votes":"Sorted by OSN",
                            style: TextStyle(color: Colors.white),
        
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          color: Colors.blue,
                        ),
                        Column(children: candidateList(context, snapshot))
                      ]
                    ));
              } else if(snapshot.hasError) {
                return Center(child:Text('${snapshot.error}'));
              }
              print("No Error");
              return Center(child: CircularProgressIndicator()); 
              
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
           
            setState(() {
               sortByVotes=!sortByVotes;
            print(sortByVotes);
            });
          },
          tooltip: sortByVotes?'Sort by OSN':'Sort by votes',
          child: Icon(sortByVotes?Icons.sort_by_alpha:Icons.format_list_numbered),
          backgroundColor: Colors.blue,
        ));
  }
}

class Candidate {
  final int osn;
  final String candidateName;
  final String party;
  final int evmVotes;
  final int postVotes;
  final int total;
  final String voteShare;

  Candidate(
      {this.osn,
      this.candidateName,
      this.party,
      this.evmVotes,
      this.postVotes,
      this.total,
      this.voteShare});

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return new Candidate(
        osn: json['osn'],
        candidateName: json['candidate_name'].toString(),
        party: json['party_name'],
        evmVotes: json['evm_votes'],
        postVotes: json['post_votes'],
        total: json['total_votes'],
        voteShare: json['vote_share'].toString());
  }
  
}

class CandidatesList {
  List<Candidate> candidates = [];

  CandidatesList({
    this.candidates,
  });

  factory CandidatesList.fromJson(
      List<dynamic> parsedJson, Constituency constituency) {
    List<Candidate> candidates = new List<Candidate>();
    parsedJson.removeWhere((test) =>
        test["province_id"].toString() != constituency.provinceId.toString());
    parsedJson.removeWhere((test) =>
        test["constituency_id"].toString() !=
        constituency.constituencyId.toString());
    candidates = parsedJson.map((i) => Candidate.fromJson(i)).toList();
    
    
    candidates.sort((first, second) {
      return first.osn - second.osn;
    });
    return new CandidatesList(candidates: candidates);
  }
}

Future<String> _loadAConstituencyAsset() async {
  return await rootBundle.loadString('assets/candidates.json');
}

Future<CandidatesList> loadCandidatesList(Constituency constituency) async {
  String jsonString = await _loadAConstituencyAsset();
  dynamic jsonResponse = await json.decode(jsonString);
  return new CandidatesList.fromJson(jsonResponse, constituency);
}
