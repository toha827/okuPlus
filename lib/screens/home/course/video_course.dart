import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoCourse extends StatefulWidget {
  String link;


  VideoCourse(this.link);

  @override
  _VideoCourseState createState() => _VideoCourseState(link);
}

class _VideoCourseState extends State<VideoCourse> {

  String videoURL = "https://www.youtube.com/watch?v=n8X9_MgEdCg";

  YoutubePlayerController _controller;

  _VideoCourseState(this.videoURL);

  @override
  void initState() {

    _controller = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(videoURL)
    );

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("First Lesson"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[

              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
              ),

            ],
          ),
        ),
      ),
    );
  }
}