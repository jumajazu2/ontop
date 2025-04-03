import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

// Global state for settings (using Provider)
class SettingsProvider extends ChangeNotifier {
  bool enableFeature = false;
  double settingValue = 50.0;

  void toggleFeature(bool value) {
    enableFeature = value;
    notifyListeners();
  }

  void updateSettingValue(double value) {
    settingValue = value;
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
                    Text("Setting Value: ${settings.settingValue.toInt()}"),
                    Slider(
                      min: 0,
                      max: 100,
                      value: settings.settingValue,
                      onChanged: (value) {
                        settings.updateSettingValue(value);
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
              Navigator.of(context).pop();
              restoreWindowPositionSize();
            },
          ),
        ],
      );
    },
  );
}

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



*/