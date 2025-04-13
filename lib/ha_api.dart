import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:ontop/main.dart';

final String url = "http://homeassistant.local:8123/api/states/";

final String baseUrl = "192.168.1.28:8123";

final Map<String, String> headers = {
  "Authorization":
      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiMjY5NzU1ZTQyMDc0ZjAwOGYyMzdkZGJkZTAwMzcxNCIsImlhdCI6MTczMDg4NzMzNywiZXhwIjoyMDQ2MjQ3MzM3fQ.HhnvhyCZLG-HqtW8-KhoHrZkpmNq292hRjNli5D5qAY",
  "Content-Type": "application/json",
};
/*
Future<List<dynamic>> fetchHomeAssistantStates(String state) async {
  //final String url = "http://homeassistant.local:8123/api/states";
  // sensor.axking_get_status_ac_output_active_power
  //sensor.axking_get_status_pv_input_power
  final String url = "http://homeassistant.local:8123/api/states/$state";
  final Map<String, String> headers = {
    "Authorization":
        "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJiMjY5NzU1ZTQyMDc0ZjAwOGYyMzdkZGJkZTAwMzcxNCIsImlhdCI6MTczMDg4NzMzNywiZXhwIjoyMDQ2MjQ3MzM3fQ.HhnvhyCZLG-HqtW8-KhoHrZkpmNq292hRjNli5D5qAY",
    "Content-Type": "application/json",
  };

  try {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      List returnedValue = [
        json.decode(response.body)["entity_id"],
        json.decode(response.body)["state"],
      ];

      return returnedValue; // Return decoded JSON data
    } else {
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}


*/

Future<List<dynamic>> fetchHomeAssistantStates(
  String state,
  String baseUrl,
  Map<String, String> headers,
) async {
  final String url = '$baseUrl/api/states/$state';

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return [data["entity_id"] ?? '', data["state"] ?? ''];
    } else {
      myHomePageKey.currentState?.dataError(
        "Failed to fetch data: ${response.statusCode}",
      );
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  } on FormatException catch (e) {
    myHomePageKey.currentState?.dataError("Response format error: $e");
    throw Exception('Response format error: $e');
  } on SocketException catch (e) {
    myHomePageKey.currentState?.dataError("Network error: $e");
    throw Exception('Network error: $e');
  } catch (e) {
    myHomePageKey.currentState?.dataError("Unexpected error: $e");
    throw Exception('Unexpected error: $e');
  }
}

Future<List<dynamic>> fetchHomeAssistantAll(
  String baseUrl,
  Map<String, String> headers,
) async {
  final String url = '$baseUrl/api/states';

  try {
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      var resultApiAll =
          data
              .map((item) => item["entity_id"])
              .toList(); // Extract entity_id from each item
      print(resultApiAll);
      return resultApiAll;
    } else {
      myHomePageKey.currentState?.dataError(
        "Failed to fetch data: ${response.statusCode}",
      );
      throw Exception('Failed to fetch data: ${response.statusCode}');
    }
  } on FormatException catch (e) {
    myHomePageKey.currentState?.dataError("Response format error: $e");
    throw Exception('Response format error: $e');
  } on SocketException catch (e) {
    myHomePageKey.currentState?.dataError("Network error: $e");
    throw Exception('Network error: $e');
  } catch (e) {
    myHomePageKey.currentState?.dataError("Unexpected error: $e");
    throw Exception('Unexpected error: $e');
  }
}
