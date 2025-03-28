import 'dart:convert';
import 'package:http/http.dart' as http;

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
