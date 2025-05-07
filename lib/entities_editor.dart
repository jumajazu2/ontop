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
  List<Map<String, dynamic>> tempEntities =
      []; // Temporary storage for entities
  List<String> allEntities = []; // List of all available entities for dropdown
  List<String> filteredEntities = []; // Filtered list for dropdown search
  Map<String, List<String>> entityAttributes = {}; // Map of entity attributes
  TextEditingController searchController = TextEditingController();
  List<String> attributesEntity =
      []; // List of attributes for each entity, with its index corresponding to JSON entities

  @override
  void initState() {
    super.initState();
    loadEntitiesFromConfig(); // Load entities from config.json
    fetchAvailableEntities(); // Fetch all available entities for dropdown
  }

  Future<void> loadEntitiesFromConfig() async {
    // Load entities from config.json into the temporary variable
    setState(() {
      tempEntities = List<Map<String, dynamic>>.from(
        jsonDecode(jsonEncode(jsonData["entities"])),
      );
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
      print("fetchedEntities: $fetchedEntities");
      setState(() {
        allEntities = fetchedEntities.cast<String>();
        filteredEntities = allEntities; // Initially show all entities
      });
    } catch (e) {
      print("Error fetching available entities: $e");
    }
  }

  Future<void> fetchAttributesForEntity(String entityHA) async {
    print("Base URL: $baseUrl, EntityHA: $entityHA, Headers: $headers");

    try {
      // Simulate fetching attributes for the selected entity
      print("trying to fetch attributes for $entityHA");
      var _attributes = await fetchHomeAssistantStates(
        entityHA,
        baseUrl,
        headers,
      );

      var attributes = _attributes[2].keys.toList();
      print("AttributesXXX for $entityHA: $attributes");
      setState(() {
        entityAttributes[entityHA] = attributes.cast<String>();
        print("entity attibutes for $entityHA: $attributes");
      });
    } catch (e) {
      print("Error fetching attributes for $entityHA: $e");
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
      tempEntities.add({
        "entityHA": "",
        "attribute": "",
        "type": "",
        "name": "Enter Name",
        "icon": "",
        "icon_color": "",
        "unit": "Enter Unit",
      });
    });
  }

  void addNewEntityAt(int position) {
    setState(() {
      tempEntities.insert(position, {
        "entityHA": "",
        "attribute": "",
        "type": "",
        "name": "Enter Name",
        "icon": "",
        "icon_color": "",
        "unit": "Enter Unit",
      });
    });
  }

  void saveEntitiesToFile() async {
    for (int i = 0; i < tempEntities.length; i++) {
      final entity = tempEntities[i];

      // Check if the "entityHA" dropdown is empty
      if (entity["entityHA"] == null || entity["entityHA"]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Entity ID cannot be empty for entity at position ${i + 1}.",
            ),
          ),
        );
        return; // Stop the save operation
      }
    }

    // Show confirmation dialog
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Save"),
          content: const Text(
            "Do you really want to save changes to the configuration?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancels
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirms
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    // If the user confirms, proceed with saving
    if (shouldSave == true) {
      jsonData["entities"] = tempEntities;
      await writeConfigToFile(jsonData);
      print("Entities saved to config.json");

      // Optional: Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Configuration saved successfully!")),
      );
    }

    if (shouldSave == false) {
      // Optional: Show a cancellation message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Save cancelled.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entity/Attribute Editor"),
        leading: SizedBox.shrink(),
        actions: [
          Tooltip(
            message: "Click to Save Entities", // Text to display as the tooltip
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: saveEntitiesToFile, // Save entities to file
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tempEntities.length,
              itemBuilder: (context, index) {
                final entity = tempEntities[index];
                final attributes =
                    entityAttributes[entity["entityHA"]] ??
                    []; //available attributes for the selected entity
                final setattribute = entity["attribute"] ?? "";
                if (!attributes.contains(setattribute)) {
                  attributes.add(
                    setattribute,
                  ); //set the first attribute as default
                }

                //currenty selected attribute to show instead of the state for the entity
                //attributes.add(
                //  setattribute,
                //); //add the selected attribute to the list of attributes for the dropdown
                print(
                  "attributesZZZ: $attributes, setattr $setattribute entity: $entity",
                );
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
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          (entity["entityHA"] == null ||
                                                  entity["entityHA"]!.isEmpty)
                                              ? Colors.red
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value:
                                          filteredEntities.contains(
                                                entity["entityHA"],
                                              )
                                              ? entity["entityHA"]
                                              : null,
                                      items:
                                          filteredEntities.map((entityHA) {
                                            return DropdownMenuItem<String>(
                                              value: entityHA,
                                              child: Text(entityHA),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          tempEntities[index]["entityHA"] =
                                              value ?? "";
                                          tempEntities[index]["attribute"] =
                                              ""; // Reset attribute
                                        });

                                        fetchAttributesForEntity(value!);
                                      },
                                      decoration: const InputDecoration(
                                        labelText: "Select Entity",
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Dropdown for Attributes
                        DropdownButtonFormField<String>(
                          value:
                              /*   attributes.contains(
                                    setattribute,
                                  ) //display set from JSON
                                  ? setattribute
                                  : null, // Ensure the value is in the list or set to null*/
                              setattribute,
                          items:
                              attributes.map((attribute) {
                                return DropdownMenuItem<String>(
                                  value: attribute,
                                  child: Text(attribute),
                                );
                              }).toList(),
                          onChanged: (value) {
                            //fetchAttributesForEntity(value!); does not work as value does not hold the correct entity
                            if (value != setattribute) {
                              setState(() {
                                tempEntities[index]["attribute"] = value;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            labelText:
                                "Selected Attribute, to show all available attributes, re-select the entity above",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Editable fields for other properties
                        TextFormField(
                          initialValue: entity["name"],
                          decoration: const InputDecoration(
                            labelText: "Name",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              tempEntities[index]["name"] = value;
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
                              tempEntities[index]["icon"] = value ?? "";
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
                            //setState(() {
                            tempEntities[index]["icon_color"] = value ?? "";
                            //});
                          },
                          decoration: const InputDecoration(
                            labelText: "Select Icon Color",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          initialValue: entity["unit"],
                          decoration: const InputDecoration(
                            labelText: "Unit",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              tempEntities[index]["unit"] = value;
                            });
                          },
                        ),
                        const SizedBox(height: 10),

                        // Delete button
                        Align(
                          alignment: Alignment.centerRight,

                          child: Tooltip(
                            message: "Delete this entity",
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),

                              onPressed: () async {
                                final confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm Deletion"),
                                      content: const Text(
                                        "Are you sure you want to delete this entity?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop(false); // User cancels
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop(true); // User confirms
                                          },
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  setState(() {
                                    tempEntities.removeAt(
                                      index,
                                    ); // Remove the entity
                                  });

                                  // Optional: Show a success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Entity deleted successfully!",
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: () => addNewEntityAt(index + 1),
                            icon: const Icon(Icons.add),
                            label: const Text("Add New Entity Below"),
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
