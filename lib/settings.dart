import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ontop/main.dart';
import 'package:ontop/file_handling.dart';
import 'package:ontop/ha_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'dart:convert';
import 'package:ontop/icons.dart'; // Adjust the path as needed
import 'package:ontop/entities_editor.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:ontop/playVLC.dart';
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

List<Map<String, dynamic>> tempConfig = [];

// Global state for settings (using Provider)
class SettingsProvider extends ChangeNotifier {
  bool enableFeature = false;
  double opacityValue =
      jsonSettings["settings"][0]["opacity"] * 100 ?? 90.0; // Default value
  String setupUrl = jsonData["API"][0]["baseURL"] ?? '';
  List<Map<String, dynamic>> tempConfig = [];
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
void showSettingsPopup(BuildContext context, VoidCallback onClose) async {
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

                                          // ConfigEditor(), // ConfigE
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

                                  SizedBox(height: 250, child: ConfigEditor()),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Transparency: ${settings.opacityValue.toInt()} %",
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
                            // Pass the tempConfig to ConfigEditor
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
          SizedBox(height: 20),
          TextButton(
            child: const Text("Open VLC"),
            onPressed: () {
              print("opening VLC");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RtspPlayerScreen()),
              );
            },
          ),
        ],
      );
    },
  );
}

class ConfigEditor extends StatefulWidget {
  @override
  _ConfigEditorState createState() => _ConfigEditorState();
}

class _ConfigEditorState extends State<ConfigEditor> {
  List<dynamic> tempConfig = []; // Temporary storage for entities

  List<dynamic> loadConfig() {
    if (jsonSettings["settings"] != null &&
        jsonSettings["settings"].isNotEmpty) {
      tempConfig =
          jsonSettings["settings"]; //List<Map<String, dynamic>>.from(jsonDecode(jsonEncode(jsonSettings["settings"])),
      //);
      return tempConfig;
    } else {
      //settings missing
      tempConfig = [
        {
          "settings": [
            {
              "bg_color": "00000000",
              "text_color": "ffffff",
              "text_size": 16,
              "opacity": 1.0,
              "ontop": "true",
              "items_row": 3,
            },
          ],
        },
      ];
      return tempConfig; // Provide default values if settings are missing
    }
  }

  @override
  void initState() {
    super.initState();
    //loadConfig();
  } //

  /*
    tempConfig = [
      {
        "bg_color": Colors.red,
        "text_color": Colors.white,
        "text_size": 16.0,
        "opacity": 1.0,
        "ontop": true,
        "items_row": 3,
      },
    ];
  }
*/
  double textSize =
      (jsonSettings["settings"][0]["text_size"] as num)
          .toDouble(); // Default text size
  @override
  Widget build(BuildContext context) {
    Color tempColor = Color(
      int.parse(jsonSettings["settings"][0]["bg_color"], radix: 16),
    );

    print("tempColor - $tempColor");
    return ListView(
      padding: const EdgeInsets.all(16.0),

      children: [
        // Background Color Picker
        Expanded(
          child: ListTile(
            title: Text("Background Color"),

            trailing: Row(
              mainAxisSize:
                  MainAxisSize
                      .min, // Ensures the Row takes up only the necessary space
              children: [
                // Color Circle
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                        "FF${jsonSettings["settings"][0]["bg_color"]}", // Prepend "FF" for full opacity
                        radix: 16,
                      ),
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 400,
                ), // Add spacing between the circle and the button
                // Restore Default Button
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      jsonSettings["settings"][0]["bg_color"] =
                          "ffd1cfcf"; // Default grey color
                      writeSettingsToFile(
                        jsonSettings,
                      ); // Save the updated settings
                    });
                  },
                  child: const Text("Restore Default (Grey)"),
                ),
              ],
            ),

            // Text("Background Color"),
            onTap: () async {
              Color? selectedColor = await showDialog<Color>(
                context: context,
                builder: (BuildContext context) {
                  Color tempColor =
                      Color(
                        int.parse(
                          jsonSettings["settings"][0]["bg_color"],
                          radix: 16,
                        ),
                      ) ??
                      Colors.red;
                  return AlertDialog(
                    title: const Text("Pick a Background Color"),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: tempColor,
                        onColorChanged: (color) {
                          setState(() {
                            tempColor = color;
                            jsonSettings["settings"][0]["bg_color"] = tempColor
                                .toARGB32()
                                .toRadixString(16);
                          });
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      ),
                      TextButton(
                        child: const Text("Select"),
                        onPressed: () {
                          ;
                          Navigator.of(context).pop(tempColor);
                        },
                      ),
                    ],
                  );
                },
              );

              if (selectedColor != null) {
                setState(() {
                  print(
                    "Selected background color: $selectedColor, in jsonSettings: ${jsonSettings["settings"][0]["bg_color"]}]}, $tempConfig",
                  );
                  writeSettingsToFile(jsonSettings);
                });
              }
            },
          ),
        ),

        Expanded(
          child: ListTile(
            title: Text("Text Color"),

            trailing: Row(
              mainAxisSize:
                  MainAxisSize
                      .min, // Ensures the Row takes up only the necessary space
              children: [
                // Color Circle
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                        "FF${jsonSettings["settings"][0]["text_color"]}", // Prepend "FF" for full opacity
                        radix: 16,
                      ),
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 397,
                ), // Add spacing between the circle and the button
                // Restore Default Button
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      jsonSettings["settings"][0]["text_color"] =
                          "ff000000"; // Default black color
                      writeSettingsToFile(
                        jsonSettings,
                      ); // Save the updated settings
                    });
                  },
                  child: const Text("Restore Default (Black)"),
                ),
              ],
            ),

            // Text("Background Color"),
            onTap: () async {
              Color? selectedTextColor = await showDialog<Color>(
                context: context,
                builder: (BuildContext context) {
                  Color tempTextColor =
                      Color(
                        int.parse(
                          jsonSettings["settings"][0]["text_color"],
                          radix: 16,
                        ),
                      ) ??
                      Colors.red;
                  return AlertDialog(
                    title: const Text("Pick a Text Color"),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: tempTextColor,
                        onColorChanged: (color) {
                          setState(() {
                            tempTextColor = color;
                            jsonSettings["settings"][0]["text_color"] =
                                tempTextColor.toARGB32().toRadixString(16);
                          });
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      ),
                      TextButton(
                        child: const Text("Select"),
                        onPressed: () {
                          ;
                          Navigator.of(context).pop(tempColor);
                        },
                      ),
                    ],
                  );
                },
              );

              if (selectedTextColor != null) {
                setState(() {
                  print(
                    "Selected background color: $selectedTextColor, in jsonSettings: ${jsonSettings["settings"][0]["bg_color"]}]}, $tempConfig",
                  );
                  writeSettingsToFile(jsonSettings);
                });
              }
            },
          ),
        ),

        Expanded(
          child: ListTile(
            title: Text("Text Size"),

            trailing: Row(
              mainAxisSize:
                  MainAxisSize
                      .min, // Ensures the Row takes up only the necessary space
              children: [
                Slider(
                  value: textSize,
                  min: 10.0,
                  max: 25.0,
                  divisions: 20, // Number of steps
                  label: textSize.toStringAsFixed(0),
                  onChanged: (double value) {
                    setState(() {
                      textSize = value;
                      jsonSettings["settings"][0]["text_size"] = value.toInt();
                      writeSettingsToFile(
                        jsonSettings,
                      ); // Save the updated text size
                    });
                  },
                ),

                Text(
                  "Sample: ${textSize.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: textSize),
                ),
                const SizedBox(width: 200),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      jsonSettings["settings"][0]["text_size"] = 16;
                      textSize = 16; // Default grey color
                      writeSettingsToFile(
                        jsonSettings,
                      ); // Save the updated settings
                    });
                  },
                  child: const Text("Restore Default (16)"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),
        // Dropdown for Icon Color
        DropdownButtonFormField<String>(
          value: jsonSettings["settings"][0]["items_row"].toString(),
          items:
              ["1", "2", "3", "4", "5", "6", "7", "8", "9"].map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (value) {
            //setState(() {
            jsonSettings["settings"][0]["items_row"] = int.parse(value!);
            //});
          },
          decoration: const InputDecoration(
            labelText: "Select the Number of Items per Row",
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
