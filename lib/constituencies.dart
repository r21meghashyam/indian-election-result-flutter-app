import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'provinces.dart';
import 'candidates.dart';


class ConstituencyRoute extends StatelessWidget {
  final Province province;
  ConstituencyRoute(this.province);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(province.name.replaceAll("&amp;", "&")),
      ),
      body: FutureBuilder<ConstituencyList>(
        future: loadConstituencyList(province),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data.constituencies.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                      '${snapshot.data.constituencies[index].constituencyName}'),
                  leading: Icon(Icons.account_balance),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CandidatesRoute(snapshot.data.constituencies[index])),
                    );
                  },
                );
              },
              padding: EdgeInsets.all(10),
              separatorBuilder: (BuildContext context, int index) =>
                  Divider(color: Colors.grey),
            ); //snapshot.data.provinces.forEach((){
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

  factory Constituency.fromJson(Map<String, dynamic> json) {
    return new Constituency(
      constituencyId: json['constituency_id'].toString(),
      constituencyName: json['constituency_name'].replaceAll("&amp;", "&"),
      provinceId: json['province_id']
    );
  }
}

class ConstituencyList {
  List<Constituency> constituencies = [];
  ConstituencyList({
    this.constituencies,
  });
  factory ConstituencyList.fromJson(List<dynamic> parsedJson, Province province) {
    List<Constituency> constituencies = new List<Constituency>();
    parsedJson.removeWhere( (test) => test["province_id"]!=province.id);
    constituencies = parsedJson.map((i) => Constituency.fromJson(i)).toList();
    constituencies.sort((first,second){
      return first.constituencyName.compareTo(second.constituencyName);
    });
    return new ConstituencyList(constituencies: constituencies);
  }
}

Future<String> _loadAConstituencyAsset() async {
  return await rootBundle.loadString('assets/constituencies.json');
}

Future<ConstituencyList> loadConstituencyList(Province province) async {
  String jsonString = await _loadAConstituencyAsset();
  dynamic jsonResponse = await json.decode(jsonString); 
  return new ConstituencyList.fromJson(jsonResponse,province);
}


