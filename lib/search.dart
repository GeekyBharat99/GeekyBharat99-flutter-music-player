import 'dart:io';
import 'package:fetchlocalsongs/colors.dart';
import 'package:fetchlocalsongs/playingNow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:gradient_widgets/gradient_widgets.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final FlutterAudioQuery audioQuery = FlutterAudioQuery();
  String query = "";
  var songslist;

  searchsong(q) async {
    List<SongInfo> songs = await audioQuery.searchSongs(query: q);
    setState(() {
      songslist = songs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: GradientText(
          "Search songs",
          shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
          style: TextStyle(
            color: accent,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        children: [
          Center(
            child: TextField(
              onChanged: (value) {
                query = value.trim();
                if (query != "") {
                  searchsong(query);
                }
              },
              decoration: InputDecoration(
                hintText: "search a song...",
              ),
            ),
          ),
          if (songslist == null)
            Center(
              child: Text(
                "Search a song..",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          if (songslist != null)
            for (var song in songslist)
              ListTile(
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
                      ),
                    ),
                  );
                },
                leading: CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.black,
                  backgroundImage: song.albumArtwork == null
                      ? AssetImage("assets/pic.jpg")
                      : FileImage(File(song.albumArtwork)),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
              )
        ],
      ),
    );
  }
}
