import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youvideo/apiservice.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:youvideo/const.dart';
import 'package:http/http.dart' as http;
import 'package:youvideo/videoscreen.dart';

void main() {
  runApp(MaterialApp(home: myapp()));
}

class myapp extends StatefulWidget {
  @override
  _myappState createState() => _myappState();
}

class _myappState extends State<myapp> {
  Constant data = Constant();
  String apikey = Constant.apikey;
  String Search = "";
  var videonames = "";
  var videoid = "";
  var videothumb = "";
  List listofnames = [];
  List listofid = [];
  List listofthumb = [];

  bool isloading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
            backgroundColor: Colors.black87,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                    MaterialButton(
                      onPressed: () {
                        Searchvideo();
                      },
                      color: Colors.white,
                      child: Text("Search"),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                    height: 500,
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
              ],
            )));
  }

  Widget getcard(itemname, itemthumb, id) {
    String fullName = itemname;
    String videoid = id;
    // var desc = itemdesc;
    String profileUrl = itemthumb;
    return Card(
      elevation: 1.5,
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
                  builder: (context) => videoscreen(id, itemthumb)),
            );
          },
        ),
      ),
    );
  }
}
