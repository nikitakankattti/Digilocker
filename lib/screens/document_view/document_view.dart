import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentView extends StatelessWidget {
  const DocumentView({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    print(args);
    return Scaffold(
      appBar: AppBar(
        title: Text(args["title"]),
      ),
      body: SfPdfViewer.network(args["fileUrl"]),
    );
  }
}

getDocumentData(String url, String fileName, String fileType) async {
  final response = await get(Uri.parse(url));

  final directory = await getApplicationDocumentsDirectory();

  final file = File('${directory.path}/$fileName./$fileType');

  await file.writeAsBytes(response.bodyBytes);

  return file.path;
}
