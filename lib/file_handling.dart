import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:ontop/main.dart';

String getExecutableDir() {
  return File(Platform.resolvedExecutable).parent.path;
}

String getFilePath(String filename) {
  if (kReleaseMode) {
    // In release mode, use the executable directory
    final exeDir = getExecutableDir();
    return p.join(exeDir, filename);
  } else {
    // In debug mode, use a relative path
    print("Debug mode detected. Using relative path.");
    return 'c:/Users/Juraj/Documents/IT/Flutter/ontop/ontop/lib/config.json';
  }
}

Future<void>
loadJsonFromFile() async //loads JSON from config.json file to the global variable jsonData
{
  try {
    // Read the JSON file
    final file = File(getFilePath('config.json'));
    final jsonString = await file.readAsString();

    // Decode the JSON
    jsonData = jsonDecode(jsonString);
    myHomePageKey.currentState?.dataError("Config loaded successfully");
    print("JSON loaded successfully: $jsonData");
  } catch (e) {
    myHomePageKey.currentState?.dataError("Error loading JSON: $e");
    print("Error loading JSON: $e");
  }
}

Future<void> writeJsonToFile(Map<String, dynamic> newJsonData) async {
  try {
    // Get the writable config file
    final file = File(getFilePath('config.json'));

    // Encode the JSON and write it to the file
    final jsonString = jsonEncode(newJsonData);
    await file.writeAsString(jsonString);

    myHomePageKey.currentState?.dataError("Config saved successfully");
    print("JSON written successfully: $jsonString");
  } catch (e) {
    myHomePageKey.currentState?.dataError("Config save failed");
    print("Error writing JSON: $e");
  }
}
