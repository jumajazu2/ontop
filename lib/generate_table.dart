import 'package:flutter/material.dart';
import 'package:ontop/main.dart';
import 'package:ontop/entities.dart';
import 'package:ontop/icons.dart';

class GenerateTable extends StatelessWidget {
  final List listResults;

  // List<dynamic> listResults = [    ["test", "test", "test", "test", "test"],  ];

  const GenerateTable({super.key, required this.listResults});

  @override
  Widget build(BuildContext context) {
    // Helper function to chunk a list into sublists of a specific size (e.g., 5 columns per row)
    print("at the entry to GenerateTable: $listResults");
    print(listResults[0].length);
    List<List> chunkList(List list, int chunkSize) {
      List<List> chunks = [];
      for (int i = 0; i < list.length; i += chunkSize) {
        chunks.add(
          list.sublist(
            i,
            i + chunkSize > list.length ? list.length : i + chunkSize,
          ),
        );
      }
      return chunks;
    }

    return Table(
      columnWidths: {0: FlexColumnWidth(), 1: FlexColumnWidth()},
      children:
          listResults.asMap().entries.expand((entry) {
            int index = entry.key; // The index of the main list
            List sublist = entry.value;
            int itemsRow = jsonSettings["settings"][0]["items_row"] ?? 4;
            // Split the sublist into chunks of X items each
            List<List> chunkedSublist = chunkList(sublist, itemsRow);

            // Return a list of TableRow widgets for each chunk
            return chunkedSublist.map((chunk) {
              // Ensure each chunk has 5 items by adding empty widgets
              while (chunk.length < itemsRow) {
                chunk.add(["", "", "", "", ""]);
              }

              return TableRow(
                children:
                    chunk.map((item) {
                      // Iterate over the chunk (which will have at most 5 items)
                      print("Index: $index, Item: $item");

                      // Trim item[1] to remove any leading/trailing spaces
                      String iconKey =
                          item[1]?.toString().trim().toLowerCase() ?? '';
                      String iconCol =
                          item[4]?.toString().trim().toLowerCase() ?? '';
                      String tooltipText = item[0]?.trim() ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Tooltip(
                          message: tooltipText, // Tooltip text
                          child: Row(
                            children: [
                              // Display the icon if item[1] is not "noicon"
                              (item[1] != "noicon")
                                  ? Icon(
                                    iconMap.containsKey(iconKey)
                                        ? iconMap[iconKey]
                                        : null, // Fallback to warning icon if not found
                                    color: iconColor[iconCol],
                                  )
                                  : Text(
                                    item[0], // Display name if no icon is specified
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber,
                                    ),
                                  ),
                              SizedBox(
                                width: 4.0,
                              ), // Space between icon and text
                              // Display the value from item[2]
                              Text(
                                item[2]
                                    .toString(), // Display value (from item[2])
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                width: 2.0,
                              ), // Space between value and unit
                              // Display the unit from item[3]
                              Text(
                                item[3]
                                    .toString(), // Display unit (from item[3])
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              );
            }).toList();
          }).toList(),
    );
  }
}
