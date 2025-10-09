import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class DocumentPdfViewer extends StatefulWidget {
  const DocumentPdfViewer({
    required this.document,
    this.onPageChanged,
    this.onDocumentLoaded,
    super.key,
  });
  final void Function(int page)? onPageChanged;
  final void Function(PdfDocument doc)? onDocumentLoaded;

  final Future<PdfDocument> document;

  @override
  State<DocumentPdfViewer> createState() => _DocumentPdfViewerState();
}

class _DocumentPdfViewerState extends State<DocumentPdfViewer> {
  static bool supportsPinchView = Platform.isAndroid || Platform.isIOS;
  late final dynamic _pdfController;

  @override
  void initState() {
    super.initState();
    _pdfController = supportsPinchView
        ? PdfControllerPinch(document: widget.document)
        : PdfController(document: widget.document);
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pdfController is PdfControllerPinch) {
      return PdfViewPinch(
        controller: _pdfController,
        scrollDirection: Axis.vertical,
        onPageChanged: widget.onPageChanged,
        onDocumentLoaded: widget.onDocumentLoaded,
      );
    } else if (_pdfController is PdfController) {
      return PdfView(
        controller: _pdfController,
        scrollDirection: Axis.vertical,
        pageSnapping: false,
      );
    } else {
      return Center(
        child: Text(
          'Visualização de PDF não suportada nesta plataforma.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
  }
}
