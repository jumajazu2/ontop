//import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:ontop/generate_table.dart';
import 'package:window_manager/window_manager.dart';
//import 'package:http/http.dart' as http;
import 'package:ontop/file_handling.dart';
import 'package:ontop/entities.dart';
import 'package:ontop/settings.dart';
import 'package:ontop/logger.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

List<dynamic> resultsOut = [
  [" ", " ", " ", " ", " "],
  [" ", " ", " ", " ", " "],
];
List<dynamic> listResults = [
  [" ", " ", " ", " ", " "],
  [" ", " ", " ", " ", " "],
];
Offset newPositionFinal = Offset.zero;
void main() async {
  // Initialize window manager
  MediaKit.ensureInitialized();
  await WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await loadJsonFromFile(); // Load JSON config from file
  await loadSettingsFromFile();

  // Configure the window properties
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitleBarStyle(
      TitleBarStyle.hidden, // Remove the title bar
      windowButtonVisibility: false, // Hide window buttons
    );
    await windowManager.setResizable(true);
    await windowManager.setTitle('ontop');
    await windowManager.setSize(const Size(500, 200));
    await windowManager.setAlwaysOnTop(true); // Set the window to stay on top
    await windowManager.setOpacity(
      jsonSettings["settings"][0]["opacity"] ?? 0.9,
    );
    await windowManager.setBackgroundColor(Colors.blue);
    //await windowManager.setBackgroundColor(Colors.blue);
    //await windowManager.setAsFrameless();
    await windowManager.show();
    //await windowManager.setTitleBarStyle(TitleBarStyle.hidden,  windowButtonVisibility: true, );
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ontop – lightweight Home Assistant viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(title: 'ontop', key: myHomePageKey),
    );
  }
}

DateTime? _lastSnackBarTime;

final GlobalKey<_MyHomePageState> myHomePageKey =
    GlobalKey<
      _MyHomePageState
    >(); //global key to display error messages in the main widget

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/*
List? resultsOut = [
  [" ", " ", " ", " ", " "],
  [" ", " ", " ", " ", " "],
];
*/
List? resultsOutPrevious = [
  [" ", " ", " ", " ", " "],
  [" ", " ", " ", " ", " "],
];

Map<String, dynamic> jsonData = {};
Map<String, dynamic> jsonSettings = {};

class _MyHomePageState extends State<MyHomePage> {
  Offset _initialWindowOffset =
      Offset.zero; // Cache the initial window position
  Offset _dragStartOffset = Offset.zero; // Cache the drag start position
  Timer? _dragUpdateTimer; // Timer to throttle position updates
  bool _isDragging = false; // Track if the window is being dragged

  List? fromAPI = [" ", " ", " ", " ", " "];
  DateTime? lastBuildTime; // Store the last build time
  void resizeWindow() async {
    await windowManager.setSize(const Size(800, 500));
  }

  int secondsSinceLastBuild() {
    if (lastBuildTime == null) return -1; // No previous build

    return DateTime.now().difference(lastBuildTime!).inSeconds;
  }

  void dataError(String message, {Color color = Colors.red}) async {
    LogManager logger = LogManager();

    await logger.log("$message  ${resultsOut.toString()}");
    print("Error logged: $message, listResults = $listResults");

    final now = DateTime.now();

    // Optional: check how much time passed since last SnackBar
    if (_lastSnackBarTime != null) {
      final difference = now.difference(_lastSnackBarTime!).inMilliseconds;
      print("Time since last SnackBar: ${difference}ms");

      // Example: don't show if less than 1000ms have passed
      if (difference < 3000) return;
    }

    // Show the SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(milliseconds: 3000),
      ),
    );

    // Update the time
    _lastSnackBarTime = now;
  }

  @override
  void initState() {
    super.initState();
    //loadJsonFromFile(); // Load JSON data from file
    Future.delayed(const Duration(milliseconds: 1000));
    _readAPI(); // Start fetching API data as soon as the widget loads
  }

  void _readAPI() async {
    while (true) {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // ⏳ Wait for 0.5 second

      listResults.clear; // Clear the list before adding new data
      resultsOut.clear;
      launch(context);

      var sinceLastBuild = secondsSinceLastBuild();

      if (sinceLastBuild > 10) {
        dataError("Data has not updated for more than $sinceLastBuild s");
      }

      //print("Previous $resultsOutPrevious");
      //print("New $resultsOut");

      final listEquals = const DeepCollectionEquality().equals;

      if (!listEquals(resultsOutPrevious, resultsOut)) {
        lastBuildTime = DateTime.now();
        resultsOutPrevious = List.from(resultsOut ?? []); // Make a copy
        print("List updated at $lastBuildTime");
        sinceLastBuild = 0;
      } // Update the last build time
      setState(
        () {},
      ); //rebuild Widget build, seems to rebuild even without this
      /*
      
      setState(() {
        // This call to setState tells the Flutter framework that something has
        // changed in this State, which causes it to rerun the build method below
        // so that the display can reflect the updated values. If we changed
        // _counter without calling setState(), then the build method would not be
        // called again, and so nothing would appear to happen.
        //_counter++;
        //fromAPI = ["", displayValues];

        //fromAPI = dataAPI1 + dataAPI2;
        //launch();
        //print("displayValues = $displayValues, fromAPI 0 $fromAPI");
      }); */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // No app bar to match frameless window
      backgroundColor: Color(
        int.parse(
          "FF${jsonSettings["settings"][0]["bg_color"]}", // Prepend "FF" for full opacity
          radix: 16,
        ),
      ), //background color of the main window
      body: GestureDetector(
        behavior:
            HitTestBehavior.opaque, // Ensure GestureDetector captures events
        onPanStart: (details) async {
          try {
            // Cache the initial window position and drag start position
            _initialWindowOffset = await windowManager.getPosition();
            _dragStartOffset = details.globalPosition;
            _isDragging = true; // Start dragging
            print(
              "Window pan start detected at $_initialWindowOffset, $_dragStartOffset",
            );
          } catch (e) {
            print("Error in onPanStart: $e");
          }
        },
        onPanUpdate: (details) async {
          if (!_isDragging) return;

          // Calculate the new position based on the drag delta
          final Offset dragDelta = details.globalPosition - _dragStartOffset;
          final Offset newPosition = _initialWindowOffset + dragDelta;

          // Update the window position
          if (dragDelta.distance > 10) {
            _dragUpdateTimer?.cancel(); // Cancel any existing timer
            _dragUpdateTimer = Timer(
              const Duration(milliseconds: 100),
              () async {
                print("window - dragDetla.distance = $dragDelta.distance");
                // windowManager.setPosition(newPosition);
                newPositionFinal = newPosition; // Update the final position

                print("Window position updated to $newPositionFinal}");
              },
            );
          }
          //await windowManager.setPosition(newPosition);
        },
        onPanEnd: (details) {
          // Stop dragging when the gesture ends
          _isDragging = false;
          print("Window pan ended");
          windowManager.setPosition(newPositionFinal);
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                (jsonData["entities"]?.length == resultsOut.length)
                    ? <Widget>[
                      GenerateTable(listResults: [resultsOut]),
                    ]
                    : [],
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 15,
        height: 15,
        child: FloatingActionButton(
          onPressed: () {
            showSettingsPopup(context, () {
              setState(() {
                // Trigger a rebuild of the main program's UI
                print("Settings dialog closed. Returning to main program.");
              });
            });
          },
          tooltip: 'Settings',
          child: const Icon(Icons.settings, size: 15),
        ),
      ),
    );
  }
}
