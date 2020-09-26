import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:audio_manager/audio_manager.dart';
import 'package:fetchlocalsongs/colors.dart';
import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'homepage.dart';

class PlayingNow extends StatefulWidget {
  final currentSongPathToPlay;
  final title;
  final displayname;
  final artwork;
  final artist;
  PlayingNow(
      {this.currentSongPathToPlay,
      this.title,
      this.displayname,
      this.artwork,
      this.artist});
  @override
  _PlayingNowState createState() => _PlayingNowState();
}

class _PlayingNowState extends State<PlayingNow> {
  @override
  void initState() {
    super.initState();
    setupAudio();
  }

  var jkhsh = Random;

  playCurrentSongAndStopOther() {
    audioManagerInstance
        .start(
      "file://${widget.currentSongPathToPlay}",
      widget.title,
      desc: widget.displayname,
      auto: true,
      cover: "assets/pic.jpg",
    )
        .then((err) {
      print(err);
    });
  }

  void setupAudio() {
    audioManagerInstance.onEvents((events, args) {
      switch (events) {
        case AudioManagerEvents.start:
          slider = 0;
          break;
        case AudioManagerEvents.seekComplete:
          slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          setState(() {});
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = audioManagerInstance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          audioManagerInstance.updateLrc(args["position"].toString());
          setState(() {});
          break;

        default:
          break;
      }
    });
    playCurrentSongAndStopOther();
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget songProgress(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Text(
            _formatDuration(audioManagerInstance.position),
            style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbColor: Colors.green[50],
                    overlayColor: accent,
                    thumbShape: RoundSliderThumbShape(
                      disabledThumbRadius: 5,
                      enabledThumbRadius: 5,
                    ),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: 10,
                    ),
                    activeTrackColor: accent,
                    inactiveTrackColor: Colors.green[50],
                  ),
                  child: Slider(
                    value: slider ?? 0,
                    onChanged: (value) {
                      setState(() {
                        slider = value;
                      });
                    },
                    onChangeEnd: (value) {
                      if (audioManagerInstance.duration != null) {
                        Duration msec = Duration(
                            milliseconds:
                                (audioManagerInstance.duration.inMilliseconds *
                                        value)
                                    .round());
                        audioManagerInstance.seekTo(msec);
                      }
                    },
                  )),
            ),
          ),
          Text(
            _formatDuration(audioManagerInstance.duration),
            style: TextStyle(fontSize: 18.0, color: Colors.green[50]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: GradientText(
          "Now Playing",
          shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
          style: TextStyle(
            color: accent,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: widget.artwork == null
                ? AssetImage("assets/pic.jpg")
                : FileImage(
                    File(widget.artwork),
                  ),
            fit: BoxFit.fill,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
            child: ListView(
              padding: EdgeInsets.all(8.0),
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 12.0,
                  ),
                ),
                Center(
                  child: Image(
                    image: widget.artwork == null
                        ? AssetImage("assets/pic.jpg")
                        : FileImage(
                            File(widget.artwork),
                          ),
                    width: 240,
                    height: 240,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
                  child: Column(
                    children: <Widget>[
                      GradientText(
                        widget.title,
                        shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
                        textScaleFactor: 2.5,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          widget.artist,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                songProgress(context),
                Padding(
                  padding: EdgeInsets.all(2.0),
                  child: Center(
                    child: IconButton(
                        iconSize: 50.0,
                        color: Colors.green[50],
                        icon: audioManagerInstance.isPlaying
                            ? Icon(Icons.pause_circle_outline)
                            : Icon(Icons.play_circle_outline),
                        onPressed: () {
                          audioManagerInstance.playOrPause();
                        }),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
