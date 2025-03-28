import 'dart:convert';
import 'package:ontop/ha_api.dart';
import 'package:ontop/main.dart';
import 'package:flutter/widgets.dart';

//manually defined JSON of entities to show, as nested list, format:, add possibility to format(line break, color, alarm-flashing/red
//HA_entity
//type - value, swtich, indicator
//name - plain lannguage text description
//icon - https://api.flutter.dev/flutter/material/Icons-class.html OR noicon
//unit - as string
//
String jsonEntities = '''
  {
    "entities": [
      {"entityHA": "sensor.axking_get_status_ac_output_active_power", "type": "value", "name": "Load", "icon":"bolt", "unit": "W"},
      {"entityHA": "sensor.axking_get_status_pv_input_power", "type": "value", "name": "PV", "icon":"solar_power", "unit": "W"},
      {"entityHA": "sensor.axking_get_status_battery_voltage", "type": "value", "name": "Batt", "icon":"battery_3_bar", "unit": "V"},
      {"entityHA": "sensor.battery_current", "type": "value", "name": "Current", "icon":"battery_charging_full", "unit": "A"},
      {"entityHA": "sensor.shellygas_3c6105f65548_gas_concentration", "type": "value", "name": "Gas", "icon":"report_problem_outlined", "unit": "ppm"},
      {"entityHA": "sensor.esphome_web_499a10_sht40_temperature", "type": "value", "name": "DHW", "icon":"device_thermostat", "unit": "C"},
      {"entityHA": "sensor.axking_get_status_inverter_charge_status", "type": "value", "name": "SCC", "icon":"solar_power_outlined", "unit": ""},
      {"entityHA": "switch.tapo_plug_2", "type": "switch", "name": "Extractor", "icon":"solar_power_outlined", "unit": ""}
    ]
  }
  ''';

Map<String, dynamic> jsonData = jsonDecode(jsonEntities);
//List<TextSpan> spanResults = [];
//List<Padding> paddingResults = [];
List<dynamic> listResults = [];

Future<String> createTextSpan(
  jsonData,
) async //create textspan with current values to be displayed
{
  var output = "";
  //print(jsonData);
  var numberEntities = jsonData["entities"].length;

  print("Number of entities is $numberEntities");
  //print(jsonData["entities"][2]);

  for (var index = 0; index < numberEntities; index++) {
    var readentity =
        jsonData["entities"][index]["entityHA"]; //read entity for each iteration by index
    var readFromApi = await fetchHomeAssistantStates(
      readentity,
    ); //read value from API
    var name = jsonData["entities"][index]["name"];
    var unit = jsonData["entities"][index]["unit"];
    var icon = jsonData["entities"][index]["icon"];

    //contruct result

    output = output + " " + name + " " + readFromApi[1] + " " + unit + " | ";

    listResults.add(
      [name, icon, readFromApi[1], unit],
    ); // each reported entity has a sublist with items in this order: name, icon, value, unit, type, (alert)

    //spanResults.add(TextSpan())
    //spanResults.add(WidgetSpan(child: Icon(Icons.star, size: 18, color: Colors.amber);

    //1. add icon to tableResult
    //paddingResults.add(Padding(padding: EdgeInsets.all(8.0), child: Icon(Icons.icon, color: Colors.green)));
  }
  //print(output);
  displayValues = output;
  print(displayValues);
  print(listResults);
  return displayValues;
}

void launch() {
  createTextSpan(jsonData);
}

//List<dynamic> users = jsonData["users"];

List<List<dynamic>> entities = [
  [""],
  [""],
  [""],
];
