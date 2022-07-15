import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pod_player/pod_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background/flutter_background.dart';

class videoscreen extends StatelessWidget {
  var thubmnail;
  var videoid;
  videoscreen(this.videoid, this.thubmnail);
  late final PodPlayerController controller;
  void initState() {
    bgser();
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      ),
    )..initialise();
  }

  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "flutter_background example app",
    notificationText:
        "Background notification for keeping the example app running in the background",
    notificationImportance: AndroidNotificationImportance.Default,
    notificationIcon: AndroidResource(
        name: 'background_icon',
        defType: 'drawable'), // Default is ic_launcher from folder mipmap
  );

  void bgser() {
    FlutterBackground.initialize(androidConfig: androidConfig);
    FlutterBackground.hasPermissions;
    FlutterBackground.enableBackgroundExecution();
    FlutterBackground.isBackgroundExecutionEnabled;
  }

  @override
  void dispose() {
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Container(
        height: 500,
        width: 500,
        color: Colors.white,
        child: PodVideoPlayer(
          controller: PodPlayerController(
            playVideoFrom: PlayVideoFrom.youtube('$videoid'),
            podPlayerConfig: const PodPlayerConfig(
              autoPlay: false,
              isLooping: false,
              initialVideoQuality: 360,
            ),
          )..initialise(),
          videoThumbnail: const DecorationImage(
            /// load from asset: AssetImage('asset_path')
            image: NetworkImage(
              'https://images.unsplash.com/photo-1569317002804-ab77bcf1bce4?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dW5zcGxhc2h8ZW58MHx8MHx8&w=1000&q=80',
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
