import 'dart:io';
import 'package:audio_manager/audio_manager.dart';
import 'package:fetchlocalsongs/playingNow.dart';
import 'package:fetchlocalsongs/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

var audioManagerInstance = AudioManager.instance;
PlayMode playMode = audioManagerInstance.playMode;
bool isPlaying = false;
double slider;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  var songslist;

  fetchsongs() async {
    /// getting all songs available on device storage
    List<SongInfo> songs = await audioQuery.getSongs();
    setState(() {
      songslist = songs;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchsongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GradientText(
          "Techsim+ Music",
          shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
          gradient: LinearGradient(colors: [
            Color(0xffde3a5e),
            Color(0xfff2821c),
          ]),
          style: TextStyle(
            color: Color(0xff04152d),
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xffe04357),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (conext) => Search()));
        },
        child: Icon(
          Icons.search_sharp,
          color: Colors.green[50],
        ),
      ),
      body: songslist != null
          ? ListView.builder(
              itemCount: songslist.length,
              itemBuilder: (context, index) {
                SongInfo song = songslist[index];
                return ListTile(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlayingNow(
                                  artwork: song.albumArtwork,
                                  currentSongPathToPlay: song.filePath,
                                  displayname: song.displayName,
                                  title: song.title,
                                  artist: song.artist,
                                )));
                  },
                  leading: CircleAvatar(
                    radius: 25.0,
                    backgroundColor: Colors.black,
                    backgroundImage: song.albumArtwork == null
                        ? AssetImage("assets/pic.jpg")
                        : FileImage(File(song.albumArtwork)),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    song.artist,
                    style: TextStyle(color: Colors.green[50]),
                  ),
                );
              })
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  static String parseToMinutesSeconds(int ms) {
    String data;
    Duration duration = Duration(milliseconds: ms);

    int minutes = duration.inMinutes;
    int seconds = (duration.inSeconds) - (minutes * 60);

    data = minutes.toString() + ":";
    if (seconds <= 9) data += "0";

    data += seconds.toString();
    return data;
  }
}
