import 'package:flutter/material.dart';
import 'provinces.dart';
import 'candidates.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;


class ConstituencyRoute extends StatelessWidget {

  final Province province;
  ConstituencyRoute(this.province);
  
    List<Card> displayConstituencies(List<Constituency> constituencies, BuildContext context) {
    return constituencies
        .map((constituency) => Card(
            child: InkWell(
              child: Container(
                child: Row(children: [
                  
                  Container(child:Icon(Icons.account_balance,size: 50),alignment: Alignment.centerLeft,),
                  Expanded(child:Container(child: Text(
                    constituency.constituencyName,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 17),
                    
                  ),alignment: Alignment.center,)
                  ,),
                  
                ]),
                padding: EdgeInsets.all(20),
                color: Color.fromRGBO(239, 240, 241, 1)
              ),
              onTap: () {
                 Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CandidatesRoute(constituency)),
                    );
              },
            ),
            margin: EdgeInsets.only(top: 5, bottom: 5)))
        .toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(province.name.replaceAll("&amp;", "&"),style:TextStyle(color:Colors.white)),
      ),
      body: FutureBuilder<List<Constituency>>(
        future: loadConstituencyList(province),
        builder: (context, snapshot) {
          if (snapshot.hasData) {

            return SingleChildScrollView(
            child: Column(
              children: displayConstituencies(snapshot.data,context),
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          );

            /*
            return ListView.separated(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                      '${snapshot.data[index].constituencyName}'),
                  leading: Icon(Icons.account_balance),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CandidatesRoute(snapshot.data[index])),
                    );
                  },
                );
              },
              padding: EdgeInsets.all(10),
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.grey),
            );*/ //snapshot.data.provinces.forEach((){
            //ListTile(title: Text("Hello"));
            // }));
          } else if (snapshot.hasError) {
            return new Text("${snapshot.error}");
          }
          return Center(child: CircularProgressIndicator()); 
        },
      ),
    );
  }
}

class Constituency {
  final String constituencyId;
  final String constituencyName;
  final String provinceId;

  Constituency({this.constituencyId, this.constituencyName,this.provinceId});

}


Future<List<Constituency>> loadConstituencyList(Province province) async {
  http.Response data =
      await http.get('http://results.eci.gov.in/pc/en/constituencywise/ConstituencywiseU011.htm');
  var html = parse(data.body);
  var input = html.getElementById(province.id);
  var constituenciesString = input.attributes['value'].split(";");
  constituenciesString.removeLast();//empty
  List<Constituency> constituencies=List<Constituency>();
  constituenciesString.forEach((constituencyString){
    var constituency = constituencyString.split(",");
    
    constituencies.add(Constituency(provinceId: province.id,constituencyId: constituency[0],constituencyName: constituency[1]));
  });
  
  return constituencies;
}


