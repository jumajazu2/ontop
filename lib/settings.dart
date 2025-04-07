import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ontop/main.dart';
import 'package:ontop/file_handling.dart';
import 'package:shared_preferences/shared_preferences.dart';



Future<void> savePreference(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
  print("Preference saved: $key = $value");
}

Future<String?> getPreference(String key) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString(key);
  print("Preference retrieved: $key = $value");
  return value;
}

Future<void> removePreference(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
  print("Preference removed: $key");
}

// Global state for settings (using Provider)
class SettingsProvider extends ChangeNotifier {
  bool enableFeature = false;
  double opacityValue =
      jsonSettings["settings"][0]["opacity"] * 100 ?? 90.0; // Default value

  void toggleFeature(bool value) {
    enableFeature = value;
    notifyListeners();
  }

  void updateOpacityValue(double value) {
    opacityValue = value;

    if (opacityValue > 20) {
      windowManager.setOpacity(opacityValue / 100);
    }
    jsonSettings["settings"][0]["opacity"] =
        opacityValue / 100; //update JSON data with new opacity value
    //write new JSON data to file so that it loads next time at startup

    notifyListeners();
  }
}

Size size = Size(100, 100);
Offset position = Offset(400, 300);

void getWindowInfo() async {
  // Get the current window size
  size = await windowManager.getSize();
  print("Window Size: ${size.width} x ${size.height}");

  // Get the current window position
  position = await windowManager.getPosition();
  print("Window Position: ${position.dx}, ${position.dy}");
}

void resizeWindow() async {
  await windowManager.setSize(const Size(800, 500));
}

void setSettingsWindowPositionSize() async {
  await windowManager.setPosition(Offset(300, 300));
  await windowManager.setSize(Size(800, 600));
}

void restoreWindowPositionSize() async {
  await windowManager.setPosition(position);
  await windowManager.setSize(size);
}

// Function to show the settings popup
void showSettingsPopup(BuildContext context) {
  getWindowInfo();

  setSettingsWindowPositionSize();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Settings"),
        content: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Checkbox setting
                Row(
                  children: [
                    Checkbox(
                      value: settings.enableFeature,
                      onChanged: (bool? value) {
                        settings.toggleFeature(value!);
                      },
                    ),
                    Text("Enable Feature"),
                  ],
                ),
                // Slider for numeric value
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Transparency: ${settings.opacityValue.toInt()}"),
                    Slider(
                      min: 20,
                      max: 100,
                      value: settings.opacityValue,
                      onChanged: (value) {
                        settings.updateOpacityValue(value);
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            child: Text("Close"),
            onPressed: () {
              writeSettingsToFile(jsonSettings);
              Navigator.of(context).pop();
              restoreWindowPositionSize();
            },
          ),
        ],
      );
    },
  );
}
/*
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Popup Example', home: HomeScreen());
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings Popup Example")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showSettingsPopup(context);
          },
          child: Text("Open Settings"),
        ),
      ),
    );
  }
}



/*
prevent window to jump to another screen

import 'package:window_manager/window_manager.dart';

void centerWindow() async {
  // Get current window size
  Rect bounds = await windowManager.getBounds();

  // Get screen information
  List<Display> displays = await windowManager.getAllDisplays();
  
  // Find which screen the window is currently on
  Display currentDisplay = displays.firstWhere(
    (display) =>
        bounds.left >= display.bounds.left &&
        bounds.right <= display.bounds.right &&
        bounds.top >= display.bounds.top &&
        bounds.bottom <= display.bounds.bottom,
    orElse: () => displays.first, // Default to primary display if not found
  );

  // Calculate center position
  int newX = currentDisplay.bounds.left +
      ((currentDisplay.bounds.width - bounds.width) ~/ 2);
  int newY = currentDisplay.bounds.top +
      ((currentDisplay.bounds.height - bounds.height) ~/ 2);

  // Move window to the centered position
  await windowManager.setPosition(Offset(newX.toDouble(), newY.toDouble()));
}



*/*/