import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ontop/main.dart';
import 'package:ontop/file_handling.dart';
import 'package:ontop/ha_api.dart';
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

void getWindowInfo() async {
  size = await windowManager.getSize();
  position = await windowManager.getPosition();
}

void setSettingsWindowPositionSize() async {
  await windowManager.setPosition(Offset(300, 300));
  await windowManager.setSize(Size(800, 600));
}

void restoreWindowPositionSize() async {
  await windowManager.setPosition(position);
  await windowManager.setSize(size);
}

class SetupTab extends StatefulWidget {
  @override
  _SetupTabState createState() => _SetupTabState();
}

class _SetupTabState extends State<SetupTab> {
  List<String> allEntities = []; // List of all entities fetched from the API
  List<String> filteredEntities = []; // Filtered list based on search
  List<String> selectedEntities = []; // List of selected entities
  TextEditingController searchController = TextEditingController();
  TextEditingController baseUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    baseUrlController.text =
        jsonData["API"][0]["baseURL"] ?? ''; // Initialize Base URL
    fetchEntities(); // Fetch entities when the widget is initialized
  }

  Future<void> fetchEntities() async {
    try {
      final baseUrl = jsonData["API"][0]["baseURL"];
      var authorization = jsonData["API"][0]["Authorization"];
      var contentType = jsonData["API"][0]["Content-Type"];
      var headers = {
        "Authorization": "$authorization",
        "Content-Type": "$contentType",
      };

      final entities = await fetchHomeAssistantAll(baseUrl, headers);
      setState(() {
        allEntities = entities.cast<String>();
        filteredEntities = allEntities; // Initially, show all entities
      });
    } catch (e) {
      print("Error fetching entities: $e");
    }
  }

  void filterEntities(String query) {
    setState(() {
      filteredEntities =
          allEntities
              .where(
                (entity) => entity.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void toggleEntitySelection(String entity) {
    setState(() {
      if (selectedEntities.contains(entity)) {
        selectedEntities.remove(entity);
      } else {
        selectedEntities.add(entity);
      }
    });
  }

  void addSelectedEntities() {
    for (var entity in selectedEntities) {
      jsonData["entities"].add({
        "entityHA": entity,
        "type": "value",
        "name":
            entity
                .split('.')
                .last, // Use the last part of the entity ID as the name
        "icon": "info", // Default icon
        "icon_color": "blue", // Default color
        "unit": "", // Default unit
      });
    }
    writeConfigToFile(jsonData); // Save updated entities to the config file
    print("Selected entities added: $selectedEntities");
  }

  void updateBaseUrl(String url) {
    setState(() {
      jsonData["API"][0]["baseURL"] = url; // Update the base URL in jsonData
    });
    writeConfigToFile(jsonData); // Save the updated base URL to the config file
    print("Base URL updated: $url");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Setup", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        // Base URL TextField
        TextField(
          controller: baseUrlController,
          decoration: const InputDecoration(
            labelText: "Base URL",
            border: OutlineInputBorder(),
          ),
          onChanged: updateBaseUrl,
        ),
        const SizedBox(height: 10),
        // Search Entities TextField
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: "Search Entities",
            border: OutlineInputBorder(),
          ),
          onChanged: filterEntities,
        ),
        const SizedBox(height: 10),
        // Entities List with Checkboxes
        Expanded(
          child: ListView.builder(
            itemCount: filteredEntities.length,
            itemBuilder: (context, index) {
              final entity = filteredEntities[index];
              return CheckboxListTile(
                title: Text(entity),
                value: selectedEntities.contains(entity),
                onChanged: (bool? value) {
                  toggleEntitySelection(entity);
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Add Selected Entities Button
        ElevatedButton(
          onPressed: addSelectedEntities,
          child: const Text("Add Selected Entities"),
        ),
      ],
    );
  }
}

// Function to show the settings popup with tabs
void showSettingsPopup(BuildContext context) {
  getWindowInfo();
  setSettingsWindowPositionSize();
  print("for settings: jsonSettings: $jsonSettings");
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Settings & Setup"),
        content: SizedBox(
          width: 500, // Set a fixed width for the dialog
          height: 400, // Set a fixed height for the dialog
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
                              Row(
                                children: [
                                  Checkbox(
                                    value: settings.enableFeature,
                                    onChanged: (bool? value) {
                                      settings.toggleFeature(value!);
                                    },
                                  ),
                                  const Text("Enable Feature"),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
              restoreWindowPositionSize();
            },
          ),
        ],
      );
    },
  );
}
