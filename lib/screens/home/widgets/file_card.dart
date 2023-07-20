import 'dart:io';

import 'package:document_saver_app/models/file_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FileCard extends StatelessWidget {
  final FileCardModel fileCard;

  const FileCard({Key? key, required this.fileCard});

  Future<void> openFile() async {
    final response = await get(Uri.parse(fileCard.fileUrl));

    final directory = await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/${fileCard.fileName}');

    await file.writeAsBytes(response.bodyBytes);

    await OpenFile.open(file.path);
  }

  Future<void> deleteFile(BuildContext context) async {
    try {
      await FirebaseStorage.instance
          .ref()
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("files")
          .child(fileCard.fileName)
          .delete();

      await FirebaseDatabase.instance
          .reference()
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("files_info")
          .child(fileCard.id)
          .remove();

      Navigator.of(context).pop();
    } catch (error) {
      print("Error deleting file: $error");
      // Handle the error, e.g., show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: kElevationToShadow[3],
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  "lib/assets/pdf_type.png",
                  width: 60,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileCard.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    if (fileCard.description.isNotEmpty) ...[
                      Text(
                        fileCard.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                    Text(
                      DateFormat("dd/MM/yyyy")
                          .format(DateTime.parse(fileCard.dateAdded)),
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                    Text(
                      'Size: ${fileCard.fileSize} MB',
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Delete File"),
                          content: Text(
                            "Are you sure you want to delete ${fileCard.title}?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await deleteFile(context);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    openFile();
                  },
                  child: const Text(
                    "View",
                    style: TextStyle(fontSize: 17, color: Colors.blue),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
