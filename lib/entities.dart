import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ontop/ha_api.dart';
import 'package:ontop/main.dart';
import 'dart:io';
import 'package:ontop/logger.dart';
import 'package:ontop/playVLC.dart';
import 'package:ontop/settings.dart';

//
int numberEntities = 0;
bool isRtspPlayerScreenOpen = false;
Future createTextSpan(
  BuildContext context,
  jsonData,
) async //create textspan with current values to be displayed
{
  //listResults!.clear();
  listResults = [];
  //resultsOut = [];
  numberEntities = jsonData["entities"].length;

  listResults = List.filled(numberEntities, []);

  print("Number of entities is $numberEntities");
  //print(jsonData["entities"]);
  print(
    "at the start of the for cycle: listResults = $listResults, resultsOut = $resultsOut",
  );
  //print(jsonData["entities"][2]);

  for (var index = 0; index < numberEntities; index++) {
    var readentity =
        jsonData["entities"][index]["entityHA"]; //read entity for each iteration by index

    var authorization = jsonData["API"][0]["Authorization"];
    var contentType = jsonData["API"][0]["Content-Type"];
    var headers = {
      "Authorization": "$authorization",
      "Content-Type": "$contentType",
    };

    var readFromApi = await fetchHomeAssistantStates(
      readentity,
      jsonData["API"][0]["baseURL"],
      headers,
    ); //read value from API

    //check if video trigger, if true, launch live video stream
    if (jsonData["entities"][index]["type"] == "video stream trigger" &&
        readFromApi[1] == "on") {
      //to check if RtspPlayerScreen is already open nto to open it repeatedly

      if (!isRtspPlayerScreenOpen) {
        isRtspPlayerScreenOpen = true;
        getWindowInfo();
        setSettingsWindowPositionSize();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RtspPlayerScreen()),
        ).then((_) {
          isRtspPlayerScreenOpen = false;
          restoreWindowPositionSize();
        });
      }
      // Create an instance of the player screen

      print("Video trigger detected, launching video stream");
      //launchVideoStream(jsonData["entities"][index]["entityHA"]);
      //launchVLCPlayer(jsonData["entities"][index]["entityHA"]);
      //launchVLCPlayer(jsonData["entities"][index]["entityHA"]);
    }

    String name = jsonData["entities"][index]["name"];
    String unit = jsonData["entities"][index]["unit"];
    String icon = jsonData["entities"][index]["icon"];
    int rounding = (jsonData["entities"][index]["rounding"]) ?? 0;

    if (jsonData["entities"][index]["attribute"] == "") {
      listResults[index] = [
        name,
        icon,
        readFromApi[1], //.toStringAsFixed(x)
        unit,
        jsonData["entities"][index]["icon_color"],
      ];
    } else {
      listResults[index] = [
        name,
        icon,
        readFromApi[2][jsonData["entities"][index]["attribute"]] ?? "",
        unit,
        jsonData["entities"][index]["icon_color"],
      ];
    }
    print("value write at position $index: ${listResults[index]}");

    listResults[index][2] = roundValue(
      listResults[index][2],
      rounding,
    ); //round the value to x decimal places

    //log the value written to the list
    /*
    listResults.add([
      name,
      icon,
      readFromApi[1],
      unit,
      jsonData["entities"][index]["icon_color"],
    ]);
    */
    // each reported entity has a sublist with items in this order: name, icon, value, unit, type, (alert)

    //spanResults.add(TextSpan())
    //spanResults.add(WidgetSpan(child: Icon(Icons.star, size: 18, color: Colors.amber);

    //1. add icon to tableResult
    //paddingResults.add(Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.icon, color: Colors.green)));
  }
  //print(output);
  //displayValues = output;
  print("------------------------------");
  print("Entities requested: $numberEntities, received ${resultsOut.length}");

  resultsOut = listResults;
  //print(displayValues);
  // print(
  //   "at the end of the for cycle: listResults = $listResults, resultsOut = $resultsOut",
  // );

  if (numberEntities != resultsOut!.length) {
    myHomePageKey.currentState?.dataError(
      "Data Length Error, expected $numberEntities, received ${resultsOut!.length}",
    ); //if the number of items in JSON and the resultant list do not match, replace with a default list
    List _listResults = [];
    for (var index = 0; index < numberEntities; index++) {
      _listResults.add(["", "", "", "", ""]);
      print(_listResults);
    }
    int resultsOutLength = resultsOut!.length;
    print(
      "default empty list created due to data length mismatch --- listResults = $listResults, resultsOut = $resultsOut", //the variable is local, does not affect listResults
    );
    print(resultsOutLength);
    print(numberEntities);
    listResults = _listResults;
    resultsOut = listResults;
  }

  return resultsOut;
}

String roundValue(dynamic value, int decimalPlaces) {
  if (value is num) {
    return value.toDouble().toStringAsFixed(decimalPlaces);
  } else if (value is String) {
    double? parsedValue = double.tryParse(value);
    if (parsedValue != null) {
      return parsedValue.toStringAsFixed(decimalPlaces);
    }
  }
  return value; // Fallback for non-numeric values
}

Future? launch(BuildContext context) async {
  await createTextSpan(context, jsonData);
}

//List<dynamic> users = jsonData["users"];

/*List<List<dynamic>> entities = [
  [""],
  [""],
  [""],
];*/
