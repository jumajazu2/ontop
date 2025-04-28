import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart';
import 'package:ontop/main.dart';
import 'package:ontop/logger.dart';

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
    return 'c:/Users/Juraj/Documents/IT/Flutter/ontop/ontop/lib/$filename';
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

Future<void>
loadSettingsFromFile() async //loads JSON from config.json file to the global variable jsonSettings
{
  try {
    // Read the JSON file
    final file = File(getFilePath('settings.json'));
    final jsonString = await file.readAsString();

    // Decode the JSON
    jsonSettings = jsonDecode(jsonString);
    myHomePageKey.currentState?.dataError("Settings loaded successfully");
    print("JSON Settings loaded successfully: $jsonSettings");
  } catch (e) {
    myHomePageKey.currentState?.dataError("Error loading JSON Settings: $e");
    print("Error loading JSON Settings: $e");
  }
}

Future<void> writeSettingsToFile(Map<String, dynamic> newJsonData) async {
  try {
    // Get the writable settings file
    final file = File(getFilePath('settings.json'));

    // Encode the JSON with indentation for readability
    final jsonString = const JsonEncoder.withIndent('  ').convert(newJsonData);
    await file.writeAsString(jsonString);

    myHomePageKey.currentState?.dataError(
      "Settings saved successfully",
      color: Colors.green,
    );
    print("Settings JSON written successfully:\n$jsonString");
  } catch (e) {
    myHomePageKey.currentState?.dataError("Settings save failed");
    print("Error writing Settings JSON: $e");
  }
}

Future<void> writeConfigToFile(Map<String, dynamic> newJsonData) async {
  try {
    // Get the writable config file
    final file = File(getFilePath('config.json'));

    // Encode the JSON with indentation for readability
    final jsonString = const JsonEncoder.withIndent('  ').convert(newJsonData);
    await file.writeAsString(jsonString);

    myHomePageKey.currentState?.dataError("Config saved successfully");
    print("Config JSON written successfully:\n$jsonString");
  } catch (e) {
    myHomePageKey.currentState?.dataError("Config save failed");
    print("Error writing Config JSON: $e");
  }
}

Future<void> debugToFile(Map<String, dynamic> newJsonData) async {
  try {
    // Get the writable config file
    final file = File(getFilePath('debug.json'));

    // Encode the JSON with indentation for readability
    final jsonString = const JsonEncoder.withIndent('  ').convert(newJsonData);
    await file.writeAsString(jsonString);

    myHomePageKey.currentState?.dataError("Debug Log saved successfully");
    print("Debug Log written successfully:\n$jsonString");
  } catch (e) {
    myHomePageKey.currentState?.dataError("Debug Log save failed");
    print("Error writing Debug Log: $e");
  }
}
