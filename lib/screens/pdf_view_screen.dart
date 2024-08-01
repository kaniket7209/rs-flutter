import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class PdfViewScreen extends StatefulWidget {
  final String pdfUrl;

  const PdfViewScreen({required this.pdfUrl});

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    downloadAndSavePdf();
  }

  Future<void> downloadAndSavePdf() async {
    final url = widget.pdfUrl;
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/temp.pdf');

    await file.writeAsBytes(bytes, flush: true);
    setState(() {
      localFilePath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View PDF'),
      ),
      body: localFilePath != null
          ? PDFView(
              filePath: localFilePath!,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}