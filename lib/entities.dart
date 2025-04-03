import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:ontop/ha_api.dart';
import 'package:ontop/main.dart';
//import 'package:flutter/widgets.dart';

//manually defined JSON of entities to show, as nested list, format:, add possibility to format(line break, color, alarm-flashing/red
//HA_entity
//type - value, swtich, indicator
//name - plain lannguage text description
//icon - https://api.flutter.dev/flutter/material/Icons-class.html OR noicon
//icon_color - icon color or default
//unit - as string
//
String jsonEntities = '''
  {
    "entities": [
      {"entityHA": "sensor.axking_get_status_ac_output_active_power", "type": "value", "name": "Load", "icon":"bolt", "icon_color":"red", "unit": "W"},
      {"entityHA": "sensor.axking_get_status_pv_input_power", "type": "value", "name": "PV", "icon":"solar_power", "icon_color":"yellow", "unit": "W"},
      {"entityHA": "sensor.axking_get_status_battery_voltage", "type": "value", "name": "Batt", "icon":"battery_3_bar", "icon_color":"blue", "unit": "V"},
      {"entityHA": "sensor.battery_current", "type": "value", "name": "Current", "icon":"battery_charging_full", "icon_color":"blue", "unit": "A"},
      {"entityHA": "sensor.shellygas_3c6105f65548_gas_concentration", "type": "value", "name": "Gas", "icon":"report_problem_outlined", "icon_color":"orange", "unit": "ppm"},
      {"entityHA": "sensor.esphome_web_499a10_sht40_temperature", "type": "value", "name": "DHW", "icon":"device_thermostat", "icon_color":"red", "unit": "C"},
      {"entityHA": "sensor.axking_get_status_inverter_charge_status", "type": "value", "name": "SCC", "icon":"solar_power_outlined", "icon_color":"white", "unit": ""},
      {"entityHA": "switch.tapo_plug_2", "type": "switch", "name": "Extractor", "icon":"fan", "icon_color":"orange", "unit": ""}
    ],
    "settings": [{"bg_color": "default", "text_color": "white", "text_size": "16"}]
  }
  ''';

Map<String, dynamic> jsonData = jsonDecode(jsonEntities);
//List<TextSpan> spanResults = [];
//List<Padding> paddingResults = [];
List<dynamic>? listResults = [];

Future createTextSpan(
  jsonData,
) async //create textspan with current values to be displayed
{
  //ar output = "";

  listResults = [];
  //print(jsonData);
  var numberEntities = jsonData["entities"].length;

  print("Number of entities is $numberEntities");
  //print(jsonData["entities"]);
  print("at the start of the for cycle: $listResults");
  //print(jsonData["entities"][2]);

  for (var index = 0; index < numberEntities; index++) {
    var readentity =
        jsonData["entities"][index]["entityHA"]; //read entity for each iteration by index
    var readFromApi = await fetchHomeAssistantStates(
      readentity,
    ); //read value from API
    String name = jsonData["entities"][index]["name"];
    String unit = jsonData["entities"][index]["unit"];
    String icon = jsonData["entities"][index]["icon"];

    //contruct result

    //output = output + " " + name + " " + readFromApi[1] + " " + unit + " | ";

    listResults?.add(
      [
        name,
        icon,
        readFromApi[1],
        unit,
        jsonData["entities"][index]["icon_color"],
      ],
    ); // each reported entity has a sublist with items in this order: name, icon, value, unit, type, (alert)

    //spanResults.add(TextSpan())
    //spanResults.add(WidgetSpan(child: Icon(Icons.star, size: 18, color: Colors.amber);

    //1. add icon to tableResult
    //paddingResults.add(Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.icon, color: Colors.green)));
  }
  //print(output);
  //displayValues = output;
  resultsOut = listResults;
  //print(displayValues);
  print("at the end of the for cycle: $listResults");

  if (numberEntities != resultsOut!.length) {
    myHomePageKey.currentState?.dataError(
      "Data Lenght Error",
    ); //if the number of items in JSON and the resultant list do not match, replace with a default list
    List _listResults = [];
    for (var index = 0; index < numberEntities; index++) {
      _listResults.add(["", "", "", "", ""]);
      print(_listResults);
    }
    int resultsOutLength = resultsOut!.length;
    print(
      "default empty list created due to data lenght mismatch --- $listResults", //the variable is local, does not affect listResults
    );
    print(resultsOutLength);
    print(numberEntities);
    listResults = _listResults;
    resultsOut = listResults;
  }

  return resultsOut;
}

void launch() {
  createTextSpan(jsonData);
}

//List<dynamic> users = jsonData["users"];

/*List<List<dynamic>> entities = [
  [""],
  [""],
  [""],
];*/
