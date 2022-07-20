import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:path_provider/path_provider.dart';

import 'package:youvideo/const.dart';
import 'package:http/http.dart' as http;
import 'package:youvideo/videoscreen.dart';

String Search = "";
void main() async {
  runApp(
    MaterialApp(home: myapp()),
  );
}

class myapp extends StatefulWidget {
  @override
  _myappState createState() => _myappState();
}

class _myappState extends State<myapp> {
  Constant data = Constant();
  String apikey = Constant.apikey;

  var videonames = "";
  var videoid = "";
  var videothumb = "";
  List listofnames = [];
  List listofid = [];
  List listofthumb = [];

  bool isloading = false;

  @override
  void initState() {
    this.Searchvideo();
  }

  Searchvideo() async {
    setState(() {
      isloading = true;
    });

    var response = await http.get(Uri.parse(
        'https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelType=any&maxResults=30&q=$Search&type=video&videoType=any&key=$apikey'));
    String finaldata = response.body;
    //   print(response.body);

    if (response.statusCode == 200) {
      isloading = false;
      listofnames = [];
      listofthumb = [];
      listofid = [];

      for (var i = 0; i <= 29; i++) {
        videonames = jsonDecode(finaldata)['items'][i]['snippet']['title'];
        videothumb = jsonDecode(finaldata)['items'][i]['snippet']['thumbnails']
            ['medium']['url'];
        videoid = jsonDecode(finaldata)['items'][i]['id']['videoId'];

        // print(videonames);
        setState(() {
          listofnames.add(videonames);
          listofid.add(videoid);
          listofthumb.add(videothumb);
        });
      }
    } else {
      print("Error");
      isloading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "YouVideo",
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 300,
                        child: TextField(
                          onChanged: (value) {
                            Search = value;
                          },
                          keyboardType: TextInputType.name,
                          style: TextStyle(color: Color(0xff7a8c99)),
                          textAlign: TextAlign.left,
                          decoration: kTextFieldDecoration.copyWith(
                              contentPadding: EdgeInsets.only(left: 20),
                              hintText: "Search Video"),
                        ),
                      ),
                      ButtonTheme(
                        child: Center(
                          child: MaterialButton(
                            onPressed: () {
                              Searchvideo();
                            },
                            height: 42,
                            minWidth: 40,
                            elevation: 0,
                            hoverElevation: 0,
                            focusElevation: 0,
                            highlightElevation: 0,
                            color: Colors.black12,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Flexible(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height / 1.3,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: listofnames.length,
                          itemBuilder: (context, index) {
                            return getcard(
                                listofnames[index],
                                listofthumb[index],
                                listofid[
                                    index]); /*Text(
                              "$index",
                              style: TextStyle(color: Colors.white),
                            );*/
                          })),
                ),
              ],
            )));
  }

  Widget getcard(itemname, itemthumb, id) {
    String fullName = itemname;
    String videoid = id;
    // var desc = itemdesc;
    String profileUrl = itemthumb;
    return Card(
      color: Color(0xfff1f0f0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Row(
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60 / 2),
                    image: DecorationImage(
                        fit: BoxFit.cover, image: NetworkImage(profileUrl))),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                      width: MediaQuery.of(context).size.width - 140,
                      child: Text(
                        fullName,
                        style: TextStyle(fontSize: 17),
                      )),

                  /*Text(
                    desc.toString(),
                    style: TextStyle(color: Colors.grey),
                  )*/
                ],
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      videoscreen(id, itemthumb, fullName, Search)),
            );
          },
        ),
      ),
    );
  }
}
//
