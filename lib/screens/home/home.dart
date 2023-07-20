import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:document_saver_app/models/file_card.dart';
import 'package:document_saver_app/routes/routes.dart';
import 'package:document_saver_app/screens/home/widgets/file_card.dart';
import 'package:document_saver_app/screens/home/widgets/home_app_bar.dart';
import 'package:document_saver_app/widgets/custom_floating_action_button.dart';
import 'package:document_saver_app/widgets/gradient_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? searchValue;
  int filesCount = 0;
  double dataStorageUsed = 0;
  String? username; // Store the username

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  void fetchUsername() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      String? fetchedUsername = 'Unknown User';
      if (snapshot.exists) {
        dynamic data = snapshot.data();
        if (data != null && data is Map<String, dynamic>) {
          fetchedUsername = data['username'] as String?;
        }
      }

      setState(() {
        username = fetchedUsername;
      });
    } catch (error) {
      print('Error fetching username: $error');
      // Handle the error, e.g., show an error message
    }
  }

  Stream<DatabaseEvent> getStream() {
    return FirebaseDatabase.instance
        .ref()
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("files_info")
        .orderByChild("title")
        .startAt(searchValue)
        .endAt("$searchValue\uf8ff")
        .onValue;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(
        context, loginPageRoute, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: HomeAppBar(
          username: username ?? '', // Display the retrieved username
          onSearch: (value) {
            setState(() {
              searchValue = value;
            });
          },
          onLogout: signOut,
        ),
        floatingActionButton: CustomFloatingActionButton(
          onTap: () {
            Navigator.pushNamed(context, addDocumentPageRoute);
          },
          icon: Icons.add,
          label: 'Add File',
        ),
        body: GradientBackground(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<DatabaseEvent>(
              stream: getStream(),
              builder: (context, snapshot) {
                List<FileCardModel> list = [];
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
                      .forEach(
                    (key, e) => list.add(
                      FileCardModel.fromJson(e, key),
                    ),
                  );
                }

                // Update files count and data storage used
                filesCount = list.length;
                dataStorageUsed = list.fold<double>(
                  0,
                  (sum, file) => sum + file.fileSize,
                );

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  return ListView(
                    children: list
                        .map(
                          (e) => FileCard(
                            fileCard: FileCardModel(
                              id: e.id,
                              title: e.title,
                              description: e.description,
                              dateAdded: e.dateAdded,
                              fileName: e.fileName,
                              fileType: e.fileType,
                              fileUrl: e.fileUrl,
                              fileSize: e.fileSize,
                            ),
                          ),
                        )
                        .toList(),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/empty.png",
                        height: 100,
                      ),
                      const Text(
                        "No Files found",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  );
                }
              },
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Files Count: $filesCount',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Data Storage Used: ${dataStorageUsed.toStringAsFixed(2)} MB',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
