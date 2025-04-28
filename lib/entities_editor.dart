import 'package:flutter/material.dart';
import 'package:ontop/icons.dart'; // Import the icon and color mappings
import 'package:ontop/logger.dart';
import 'package:ontop/file_handling.dart'; // Import file handling functions
import 'dart:convert'; // Import for JSON encoding/decoding
import 'package:ontop/main.dart';
import 'package:ontop/ha_api.dart';

class EntityEditor extends StatefulWidget {
  @override
  _EntityEditorState createState() => _EntityEditorState();
}

class _EntityEditorState extends State<EntityEditor> {
  List<Map<String, dynamic>> entities = []; // Temporary storage for entities
  List<String> allEntities = []; // List of all available entities for dropdown
  List<String> filteredEntities = []; // Filtered list for dropdown search
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEntitiesFromConfig(); // Load entities from config.json
    fetchAvailableEntities(); // Fetch all available entities for dropdown
  }

  Future<void> loadEntitiesFromConfig() async {
    // Load entities from config.json into the temporary variable
    setState(() {
      entities = List<Map<String, dynamic>>.from(jsonData["entities"]);
    });
  }

  Future<void> fetchAvailableEntities() async {
    try {
      final baseUrl = jsonData["API"][0]["baseURL"];
      var authorization = jsonData["API"][0]["Authorization"];
      var contentType = jsonData["API"][0]["Content-Type"];
      var headers = {
        "Authorization": "$authorization",
        "Content-Type": "$contentType",
      };

      final fetchedEntities = await fetchHomeAssistantAll(baseUrl, headers);
      setState(() {
        allEntities = fetchedEntities.cast<String>();
        filteredEntities = allEntities; // Initially show all entities
      });
    } catch (e) {
      print("Error fetching available entities: $e");
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

  void addNewEntity() {
    setState(() {
      entities.add({
        "entityHA": "",
        "type": "value",
        "name": "",
        "icon": "",
        "icon_color": "",
        "unit": "",
      });
    });
  }

  void saveEntitiesToFile() async {
    // Save the updated entities to config.json
    jsonData["entities"] = entities;
    await writeConfigToFile(jsonData);
    print("Entities saved to config.json");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entity Editor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveEntitiesToFile, // Save entities to file
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: entities.length,
              itemBuilder: (context, index) {
                final entity = entities[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filterable Dropdown for Entity ID
                        Row(
                          children: [
                            const Text("Entity ID: "),
                            Expanded(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: searchController,
                                    decoration: const InputDecoration(
                                      labelText: "Search Entity",
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      filterEntities(value);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value:
                                        filteredEntities.contains(
                                              entity["entityHA"],
                                            )
                                            ? entity["entityHA"]
                                            : null, // Ensure the value is in the list or set to null
                                    items:
                                        filteredEntities.map((entityHA) {
                                          return DropdownMenuItem<String>(
                                            value: entityHA,
                                            child: Text(entityHA),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        entities[index]["entityHA"] =
                                            value ?? "";
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      labelText: "Select Entity",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Editable fields for other properties
                        TextFormField(
                          initialValue: entity["name"],
                          decoration: const InputDecoration(labelText: "Name"),
                          onChanged: (value) {
                            setState(() {
                              entities[index]["name"] = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        // Dropdown for Icon
                        DropdownButtonFormField<String>(
                          value:
                              entity["icon"].isNotEmpty ? entity["icon"] : null,
                          items:
                              iconMap.keys.map((iconKey) {
                                return DropdownMenuItem<String>(
                                  value: iconKey,
                                  child: Row(
                                    children: [
                                      Icon(iconMap[iconKey]),
                                      const SizedBox(width: 8),
                                      Text(iconKey),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              entities[index]["icon"] = value ?? "";
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Select Icon",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Dropdown for Icon Color
                        DropdownButtonFormField<String>(
                          value:
                              entity["icon_color"].isNotEmpty
                                  ? entity["icon_color"]
                                  : null,
                          items:
                              iconColor.keys.map((colorKey) {
                                return DropdownMenuItem<String>(
                                  value: colorKey,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        color: iconColor[colorKey],
                                      ),
                                      const SizedBox(width: 8),
                                      Text(colorKey),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              entities[index]["icon_color"] = value ?? "";
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: "Select Icon Color",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: entity["unit"],
                          decoration: const InputDecoration(labelText: "Unit"),
                          onChanged: (value) {
                            setState(() {
                              entities[index]["unit"] = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        // Delete button
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                entities.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Add New Entity Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: addNewEntity,
              icon: const Icon(Icons.add),
              label: const Text("Add New Entity"),
            ),
          ),
        ],
      ),
    );
  }
}
