import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ontop/main.dart';
import 'package:ontop/file_handling.dart';
import 'package:ontop/ha_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:ontop/entities_editor.dart'; // Adjust the path as needed
// Import the EntityEditor widget

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
  String setupUrl = jsonData["API"][0]["baseURL"] ?? '';

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
        opacityValue / 100; // Update JSON data with new opacity value
    notifyListeners();
  }

  void updateSetupUrl(String url) {
    setupUrl = url;
    jsonData["API"][0]["baseURL"] = url; // Update JSON data with new URL
    notifyListeners();
  }
}

Size size = Size(100, 100);
Offset position = Offset(400, 300);

Future getWindowInfo() async {
  size = await windowManager.getSize();
  print("window size: $size");
  position = await windowManager.getPosition();
  print("window position: $position");
}

void setSettingsWindowPositionSize() async {
  await windowManager.maximize();
  //await windowManager.setPosition(Offset(300, 300));
  //await windowManager.setSize(Size(1000, 1000));
}

void restoreWindowPositionSize() async {
  print("window position for restore: $position");

  await windowManager.unmaximize();
  /*
  final screens = await screenRetriever.getAllDisplays();
  final primaryScreen = await screenRetriever.getPrimaryDisplay();

  // Default to the primary screen if no screens are found
  Rect screenBounds = Rect.fromLTWH(
    primaryScreen.visiblePosition?.dx ?? 0.0,
    primaryScreen.visiblePosition?.dy ?? 0.0,
    primaryScreen.visibleSize?.width ?? 0.0,
    primaryScreen.visibleSize?.height ?? 0.0,
  );
  print(
    "window: $screens, primary: $primaryScreen, screenBounds: $screenBounds",
  );
  // Check if the position is within any screen's bounds
  for (var screen in screens) {
    final screenRect = Rect.fromLTWH(
      screen.visiblePosition?.dx ?? 0.0,
      screen.visiblePosition?.dy ?? 0.0,
      screen.visibleSize?.width ?? 0.0,
      screen.visibleSize?.height ?? 0.0,
    );

    if (screenRect.contains(position)) {
      screenBounds = screenRect;
      break;
    }
  }
  print("window screenBounds: $screenBounds");
  // Adjust the position if it's outside the screen bounds
  double adjustedX = position.dx;
  double adjustedY = position.dy;

  if (position.dx < screenBounds.left) {
    adjustedX = screenBounds.left;
  } else if (position.dx > screenBounds.right - size.width) {
    adjustedX = screenBounds.right - size.width;
  }

  if (position.dy < screenBounds.top) {
    adjustedY = screenBounds.top;
  } else if (position.dy > screenBounds.bottom - size.height) {
    adjustedY = screenBounds.bottom - size.height;
  }

  final adjustedPosition = Offset(adjustedX, adjustedY);
*/
  // Restore the window position and size
  await windowManager.setPosition(position);
  await windowManager.setSize(size);

  print("Restored window position: $position, size: $size");
}

class SetupTab extends StatefulWidget {
  @override
  _SetupTabState createState() => _SetupTabState();
}

class _SetupTabState extends State<SetupTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Setup", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // Add the EntityEditor widget here
        Expanded(
          child: EntityEditor(), // Reference to the EntityEditor widget
        ),
      ],
    );
  }
}

// Function to show the settings popup with tabs
void showSettingsPopup(BuildContext context) async {
  await getWindowInfo();
  setSettingsWindowPositionSize();
  print("for settings: jsonSettings: $jsonSettings");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Settings & Setup"),
        content: SizedBox(
          width: 900, // Set a fixed width for the dialog
          height: 900, // Set a fixed height for the dialog
          child: DefaultTabController(
            length: 2, // Two tabs: Settings and Setup
            child: Column(
              children: [
                const TabBar(tabs: [Tab(text: "Settings"), Tab(text: "Setup")]),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Settings Tab
                      Consumer<SettingsProvider>(
                        builder: (context, settings, child) {
                          return Column(
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  // Editable fields for other properties
                                  StatefulBuilder(
                                    builder: (
                                      BuildContext context,
                                      StateSetter setState,
                                    ) {
                                      return Column(
                                        children: [
                                          TextFormField(
                                            initialValue:
                                                jsonData["API"][0]["baseURL"],
                                            decoration: InputDecoration(
                                              labelText:
                                                  "Base API URL", // Label text
                                              labelStyle: const TextStyle(
                                                fontSize: 14,
                                              ), // Optional: Adjust label font size
                                              border:
                                                  const OutlineInputBorder(), // Rectangle border
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ), // Adjust padding inside the box
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                jsonData["API"][0]["baseURL"] =
                                                    value;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 20),
                                          // Editable fields for other properties
                                          TextFormField(
                                            initialValue:
                                                jsonData["API"][0]["NabuCasaURL"],
                                            decoration: InputDecoration(
                                              labelText:
                                                  "NabuCasa URL", // Label text
                                              labelStyle: const TextStyle(
                                                fontSize: 14,
                                              ), // Optional: Adjust label font size
                                              border:
                                                  const OutlineInputBorder(), // Rectangle border
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 8,
                                                  ), // Adjust padding inside the box
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                jsonData["API"][0]["NabuCasaURL"] =
                                                    value;
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 30),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Transparency: ${settings.opacityValue.toInt()}",
                                      ),
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
                              ),
                            ],
                          );
                        },
                      ),
                      // Setup Tab
                      SetupTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Close"),
            onPressed: () {
              writeSettingsToFile(jsonSettings);
              Navigator.of(context).pop();
              print("window position on Close: $position");
              restoreWindowPositionSize();
            },
          ),
        ],
      );
    },
  );
}
