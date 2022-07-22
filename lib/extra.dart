import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'downloading_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'const.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';

String Search2 = "";

class videoscreen extends StatefulWidget {
  var thubmnail;
  var videoid;
  var name;
  String Search1;
  videoscreen(this.videoid, this.thubmnail, this.name, this.Search1);

  @override
  State<videoscreen> createState() => _videoscreenState();
}

class _videoscreenState extends State<videoscreen> {
  late final PodPlayerController controller;
  void initState() {
    this.Searchvideo();
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.youtube('${widget.videoid}'),
    )..initialise();
    super.initState();
    Search2 = widget.Search1;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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

  Searchvideo() async {
    setState(() {
      isloading = true;
    });

    var response = await http.get(Uri.parse(
        'https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelType=any&maxResults=30&q=${widget.Search1}&type=video&videoType=any&key=$apikey'));
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

  MethodChannel platform = new MethodChannel('backgroundservice');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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
            SizedBox(
              height: 15,
            ),
            Container(
              color: Colors.white,
              child: PodVideoPlayer(
                controller: PodPlayerController(
                  playVideoFrom: PlayVideoFrom.youtube('${widget.videoid}'),
                  podPlayerConfig: const PodPlayerConfig(
                    autoPlay: false,
                    isLooping: true,
                    initialVideoQuality: 360,
                  ),
                )..initialise(),
                videoThumbnail: DecorationImage(
                  /// load from asset: AssetImage('asset_path')
                  image: NetworkImage(
                    '${widget.thubmnail}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                '${widget.name}',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 20,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: MaterialButton(
                  child: Text("Download"),
                  color: Color(0xffFF000F),
                  textColor: Colors.white,
                  onPressed: () async {
                    final status = await Permission.storage.request();

                    if (status.isGranted) {
                      showDialog(
                        context: context,
                        builder: (context) => const DownloadingDialog(),
                      );
                    } else {
                      print("Permission deined");
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              height: 3,
            ),
            Flexible(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
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
        ),
      ),
    );
  }

  Widget getcard(itemname, itemthumb, id) {
    String fullName = itemname;
    String videoid = id;
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
                      videoscreen(id, itemthumb, fullName, Search2)),
            );
          },
        ),
      ),
    );
  }
}
