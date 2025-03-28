import 'package:flutter/material.dart';
import 'package:ontop/ha_api.dart';
import 'package:ontop/entities.dart';

class GenerateTable extends StatelessWidget {
  List<String> listResults;

  GenerateTable({required this.listResults});

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
      children:
          listResults.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(iconMap[item[1]], color: Colors.green), // Icon
                      SizedBox(width: 8.0), // Space between icon and text
                      Text(
                        "$item - Index: $index", // Display item and its index
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue), // Another icon
                      SizedBox(width: 8.0), // Space between icon and text
                      Text(
                        "Value: $item", // You can format or change the value here
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}

//IconData iconToDisplay(iconName) {var iconPrepared = Icons.iconName;}


// Map of icon names (strings) to IconData
final Map<String, IconData> iconMap = {
  'check_circle': Icons.check_circle,
  'warning': Icons.warning,
  'info': Icons.info,
  'star': Icons.star,
  'home': Icons.home,
  'settings': Icons.settings,
  // Add more icons as needed
};

