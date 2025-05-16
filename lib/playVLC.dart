import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class RtspPlayerScreen extends StatefulWidget {
  @override
  State<RtspPlayerScreen> createState() => _RtspPlayerScreenState();
}

class _RtspPlayerScreenState extends State<RtspPlayerScreen> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    PlayerConfiguration(osc: false);
    player = Player();

    controller = VideoController(player);
    player.open(
      Media('rtsp://admin:Vojvodova77@192.168.1.27:554/h264Preview_01_main'),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('media_kit RTSP Player')),
      body: Center(
        child: Video(controller: controller, width: 1280, height: 720),
      ),
    );
  }
}

/*

class RtspVlcScreen extends StatefulWidget {
  final String rtspUrl;

  const RtspVlcScreen({Key? key, required this.rtspUrl}) : super(key: key);

  @override
  State<RtspVlcScreen> createState() => _RtspVlcScreenState();
}

class _RtspVlcScreenState extends State<RtspVlcScreen> {
  late final VlcPlayerController _vlcController;

  @override
  void initState() {
    super.initState();

    _vlcController = VlcPlayerController.network(
      widget.rtspUrl,
      autoPlay: true,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _vlcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RTSP VLC Viewer")),
      body: Center(
        child: VlcPlayer(
          controller: _vlcController,
          aspectRatio: 16 / 9,
          placeholder: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

*/
/*
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyAppVideo());
}

class MyAppVideo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RtspVlcScreen());
  }
}

class RtspVlcScreen extends StatefulWidget {
  @override
  _RtspVlcScreenState createState() => _RtspVlcScreenState();
}

class _RtspVlcScreenState extends State<RtspVlcScreen> {
  late VlcPlayerController _vlcViewController;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _vlcViewController = VlcPlayerController.file(
      File("C:/Users/Juraj/Documents/AxpertKing_sounds.mp4"),
    );

    // Add a listener to check for errors
    _vlcViewController.addListener(() {
      if (_vlcViewController.value.isInitialized) {
        print("VLC Player is now initialized.");
      } else if (_vlcViewController.value.hasError) {
        print("VLC Player Error: ${_vlcViewController.value.errorDescription}");
      }
    });
    if (_vlcViewController.value.isInitialized) {
      print("VLC Player is initialized.");
    } else {
      print("VLC Player is not initialized.");
    }
  }

  @override
  void dispose() {
    _vlcViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reolink RTSP in VLC Player")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300, // Set the desired width
            height: 200, // Set the desired height
            child: VlcPlayer(
              controller: _vlcViewController,
              aspectRatio: 16 / 9, // Maintain the aspect ratio
            ),
          ),
          const SizedBox(
            height: 20,
          ), // Add spacing between the player and the button
          // Exit Button
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Navigate back one screen
              }
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }
}
*/
