import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:indian_election_2019/candidates.dart';
import 'dart:convert';
import 'constituencies.dart';


class ProvincesRoute extends StatefulWidget {
  ProvincesRoute();

  @override
  ProvincesRouteState createState() => ProvincesRouteState();
}

class ProvincesRouteState extends State<ProvincesRoute> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProvinceList>(
      
        future: loadProvinceList(0),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data.provinces.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                      '${snapshot.data.provinces[index].name.replaceAll("&amp;", "&")}'),
                  leading: Icon(Icons.account_balance),
                  trailing: Text(
                      snapshot.data.provinces[index].id.startsWith("S")
                          ? "State"
                          : "Union Teritory"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              snapshot.data.provinces[index].id.startsWith("S")
                                  ? ConstituencyRoute(
                                      snapshot.data.provinces[index])
                                  : CandidatesRoute(Constituency(
                                      constituencyId: "1",
                                      constituencyName:
                                          snapshot.data.provinces[index].name,
                                      provinceId:
                                          snapshot.data.provinces[index].id))),
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
      );
  }
}

class ProvinceList {
  final List<Province> provinces;

  ProvinceList({
    this.provinces,
  });

  factory ProvinceList.fromJson(List<dynamic> parsedJson) {
    List<Province> provinces = new List<Province>();
    provinces = parsedJson.map((i) => Province.fromJson(i)).toList();
    provinces.sort((first, second) {
      return first.name.compareTo(second.name);
    });
    return new ProvinceList(provinces: provinces);
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

Future<String> _loadAProvinceAsset() async {
  return await rootBundle.loadString('assets/provinces.json');
}

Future<ProvinceList> loadProvinceList(int i) async {
  String jsonString = await _loadAProvinceAsset();
  final jsonResponse = json.decode(jsonString);

  return new ProvinceList.fromJson(jsonResponse);
}
