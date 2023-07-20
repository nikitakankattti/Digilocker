import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:document_saver_app/utils/helpers/snack_bar.dart';
import 'package:document_saver_app/widgets/custom_floating_action_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddDocument extends StatefulWidget {
  const AddDocument({Key? key}) : super(key: key);

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  PlatformFile? _selectedFile;

  int storageUsed = 0;
  int fileCount = 0;

  @override
  void initState() {
    super.initState();
    // Load the initial storage usage and file count from the database
    _loadStorageUsageAndFileCount();
  }

  void _loadStorageUsageAndFileCount() async {
    DatabaseReference filesInfoRef = _firebaseDatabase
        .reference()
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("files_info");

    filesInfoRef.onValue.listen((event) {
      // Calculate the storage usage and file count from the retrieved data
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? filesData =
          snapshot.value as Map<dynamic, dynamic>?;

      if (filesData != null) {
        int totalSize = 0;
        int totalCount = filesData.length;

        filesData.forEach((key, value) {
          if (value != null && value["fileSize"] != null) {
            totalSize += int.parse(value["fileSize"].toString());
          }
        });

        setState(() {
          storageUsed = totalSize;
          fileCount = totalCount;
        });
      }
    });
  }

  void _updateStorageUsageAndFileCount(int fileSize) {
    setState(() {
      storageUsed += fileSize;
      fileCount++;
    });
  }

  void _removeFileFromStorageAndDatabase(String fileId, int fileSize) async {
    try {
      Reference fileRef = _firebaseStorage
          .ref()
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("files")
          .child(fileId);

      await fileRef.delete();

      DatabaseReference fileInfoRef = _firebaseDatabase
          .reference()
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child("files_info")
          .child(fileId);

      await fileInfoRef.remove();

      setState(() {
        storageUsed -= fileSize;
        fileCount--;
      });

      SnackBarHelper.showSuccessMessage(
        context: context,
        message: "File deleted successfully",
      );
    } catch (e) {
      SnackBarHelper.showErrorMessage(
        context: context,
        message: "Error deleting file: ${e.toString()}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(65.0),
          child: Text("Add Document"),
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            if (_selectedFile!.size! > 500 * 1024 * 1024) {
              SnackBarHelper.showErrorMessage(
                context: context,
                message: "File size exceeds the limit of 500MB",
              );
              return;
            }

            try {
              TaskSnapshot snapshot = await _firebaseStorage
                  .ref()
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child("files")
                  .child(_selectedFile!.name!)
                  .putData(_selectedFile!.bytes!);
              String fileUrl = await snapshot.ref.getDownloadURL();

              DatabaseReference fileInfoRef = _firebaseDatabase
                  .reference()
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child("files_info")
                  .push();

              await fileInfoRef.set(
                {
                  "title": titleController.text,
                  "description": descriptionController.text,
                  "fileUrl": fileUrl,
                  "dateAdded": DateTime.now().toString(),
                  "fileName": _selectedFile!.name!,
                  "fileType": _selectedFile!.name!.split(".")[1],
                  "fileSize": _selectedFile!.size!,
                },
              );

              String fileId = fileInfoRef.key!;
              _updateStorageUsageAndFileCount(_selectedFile!.size!);

              SnackBarHelper.showSuccessMessage(
                context: context,
                message: "File uploaded successfully",
              );
              Navigator.pop(context);
            } on FirebaseException catch (e) {
              SnackBarHelper.showErrorMessage(
                context: context,
                message: e.message!,
              );
            }
          }
        },
        icon: Icons.check,
        label: 'Upload File',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return "Please enter your file name";
                  }
                  return null;
                },
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter the file name",
                  labelText: "File name",
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _selectedFile = result.files.first;
                    });
                  }
                },
                child: DottedBorder(
                  dashPattern: const [6, 4],
                  strokeWidth: 2,
                  radius: const Radius.circular(100),
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Image.asset(
                          "lib/assets/upload.png",
                          height: 100,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Browse files",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_selectedFile != null) ...[
                          Text(_selectedFile!.name!),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Simulate file deletion by removing the latest uploaded file
                  if (_selectedFile != null) {
                    _removeFileFromStorageAndDatabase(
                      _selectedFile!.name!,
                      _selectedFile!.size!,
                    );
                    setState(() {
                      _selectedFile = null;
                    });
                  }
                },
                child: const Text('Delete File'),
              ),
              const SizedBox(height: 20),
              Text('Storage Used: ${storageUsed.toString()}'),
              Text('File Count: ${fileCount.toString()}'),
            ],
          ),
        ),
      ),
    );
  }
}
