import 'package:flutter/material.dart';
import 'package:ontop/main.dart';
import 'package:ontop/entities.dart';
import 'package:ontop/icons.dart';
import 'package:ontop/logger.dart';

class GenerateTable extends StatelessWidget {
  final List listResults;

  // List<dynamic> listResults = [    ["test", "test", "test", "test", "test"],  ];

  const GenerateTable({super.key, required this.listResults});

  @override
  Widget build(BuildContext context) {
    // Helper function to chunk a list into sublists of a specific size (e.g., 5 columns per row)
    print("at the entry to GenerateTable: $listResults");
    if (resultsOut == null || numberEntities != resultsOut.length) {
      print("Condition not met: Quitting GenerateTable without changes.");
      LogManager logger = LogManager();
      logger.log("{$TimeOfDay.now()} Data error: ${resultsOut.toString()}");

      return const SizedBox(); // Return an empty widget to quit execution
    }

    // print(listResults[0].length);
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
            List sublist = entry.value ?? [];
            if (sublist.isEmpty) {
              print("Sublist at index $index is empty. Skipping.");
              return <TableRow>[];
            }

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
                      if (item[0] == null) {
                        item[0] = " ";
                      } // Handle null values in item[0]
                      if (item[1] == null) {
                        item[1] = "noicon";
                      } // Handle null values in item[1]
                      if (item[2] == null) {
                        item[2] = " ";
                      } // Handle null values in item[2]
                      if (item[3] == null) {
                        item[3] = " ";
                      } // Handle null values in item[3]
                      if (item[4] == null) {
                        item[4] = " ";
                      } // Handle null values in item[4]
                      ;
                      // Handle null values in item[5]

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
