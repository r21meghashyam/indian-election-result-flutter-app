import 'package:flutter/material.dart';
import 'package:indian_election_2019/candidates.dart';
import 'constituencies.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class ProvincesRoute extends StatefulWidget {
  ProvincesRoute();

  @override
  ProvincesRouteState createState() => ProvincesRouteState();
}

class ProvincesRouteState extends State<ProvincesRoute> {
  List<Card> displayProvinces(List<Province> provinces) {
    return provinces
        .map((province) => Card(
            child: InkWell(
              child: Container(
                child: Row(children: [
                  
                  Container(child:Icon(Icons.account_balance,size: 50,color: Colors.grey,),alignment: Alignment.centerLeft,),
                  Expanded(child:Container(child: Text(
                    province.name,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 17),
                    
                  ),alignment: Alignment.center,)
                  ,),
                  Text( province.id.startsWith("S")
                          ? "State"
                          : "Union Teritory", style: TextStyle(fontSize: 10)),
                ]),
                padding: EdgeInsets.all(20),
                color: Color.fromRGBO(239, 240, 241, 1)
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          province.id.startsWith("S")
                              ? ConstituencyRoute(province)
                              : CandidatesRoute(Constituency(
                                  constituencyId: "1",
                                  constituencyName: province.name,
                                  provinceId: province.id))),
                );
              },
            ),
            margin: EdgeInsets.only(top: 5, bottom: 5)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Province>>(
      future: loadProvinceList(0),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              children: displayProvinces(snapshot.data),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              
            ),
          );

          /*
            return ListView.separated(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                      '${snapshot.data[index].name.replaceAll("&amp;", "&")}'),
                  leading: Icon(Icons.account_balance),
                  trailing: Text(
                      snapshot.data[index].id.startsWith("S")
                          ? "State"
                          : "Union Teritory"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              snapshot.data[index].id.startsWith("S")
                                  ? ConstituencyRoute(
                                      snapshot.data[index])
                                  : CandidatesRoute(Constituency(
                                      constituencyId: "1",
                                      constituencyName:
                                          snapshot.data[index].name,
                                      provinceId:
                                          snapshot.data[index].id))),
                    );
                  },
                );
              },
              padding: EdgeInsets.all(10),
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.grey),
            ); //snapshot.data.provinces.forEach((){
            //ListTile(title: Text("Hello"));
            // }));*/
        } else if (snapshot.hasError) {
          return new Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class Province {
  final String id;
  final String name;

  Province({this.id, this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return new Province(
      id: json['province_id'],
      name: json['province_name'],
    );
  }
}

Future<List<Province>> loadProvinceList(int i) async {
  http.Response data = await http.get(
      'http://results.eci.gov.in/pc/en/constituencywise/ConstituencywiseU011.htm');
  var html = parse(data.body);
  var options = html.getElementById("ddlState").getElementsByTagName("option");
  options.removeAt(0); //select placeholder
  List<Province> provinces = options.map((option) {
    return Province(id: option.attributes['value'], name: option.text);
  }).toList();

  return provinces;
}
