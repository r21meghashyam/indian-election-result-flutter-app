import 'package:flutter/material.dart';
import 'constituencies.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;


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
    String total = formatter.format(int.parse(candidate.total));
    
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
    List<Candidate> candidateslist = snapshot.data;

    candidateslist.sort((first, second) {
      if(sortByVotes)
        return  int.parse(second.total) - int.parse(first.total);
      else
        return int.parse(first.osn) - int.parse(second.osn);
    });
    candidateslist.forEach((candidate) {
      candidates.add(candidateCard(context, candidate));
    });
    return candidates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(constituency.constituencyName,style:TextStyle(color:Colors.white)),
        ),
        body: FutureBuilder<List<Candidate>>(
            future: loadCandidatesList(constituency),
            builder: (context, snapshot) {
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
              return Center(child: CircularProgressIndicator()); 
              
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: (){
           
            setState(() {
               sortByVotes=!sortByVotes;
            });
          },
          tooltip: sortByVotes?'Sort by OSN':'Sort by votes',
          child: Icon(sortByVotes?Icons.sort_by_alpha:Icons.format_list_numbered),
          backgroundColor: Colors.blue,
        ));
  }
}

class Candidate {
  final String osn;
  final String candidateName;
  final String party;
  final String evmVotes;
  final String postVotes;
  final String total;
  final String voteShare;

  Candidate(
      {this.osn,
      this.candidateName,
      this.party,
      this.evmVotes,
      this.postVotes,
      this.total,
      this.voteShare});
  
}


Future<List<Candidate>> loadCandidatesList(Constituency constituency) async {
   http.Response data =
      await http.get('http://results.eci.gov.in/pc/en/constituencywise/Constituencywise${constituency.provinceId}${constituency.constituencyId}.htm?ac=${constituency.constituencyId}`');
    
  var html = parse(data.body);
  var tableParty = html.getElementsByClassName("table-party")[0];
  var trs = tableParty.getElementsByTagName("tr");
  trs.removeRange(0, 3); //headings
  trs.removeLast(); //All Party
  trs.removeLast(); //total
  var candidates = trs.map((tr) {
    
    return Candidate(
      osn: tr.children[0].text,
      candidateName: tr.children[1].text,
      party: tr.children[2].text,
      evmVotes: tr.children[3].text,
      postVotes: tr.children[4].text,
      total: tr.children[5].text,
      voteShare: tr.children[6].text
      );
  });
  //return parties.toList();

  return candidates.toList();
}

