// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:logging/logging.dart';
// import 'package:minha_saude_frontend/app/routing/routes.dart';
// import 'package:minha_saude_frontend/app/ui/documents/widgets/upload/old/document_upload_preview.dart';
// import 'package:pdfx/pdfx.dart';

// import '../../../view_models/upload/document_info_form_model.dart';
// import '../../../view_models/upload/document_upload_view_model.dart';
// import 'document_info_form.dart';

// class DocumentUploadView extends StatefulWidget {
//   final DocumentUploadViewModel Function() viewModelFactory;
//   const DocumentUploadView(this.viewModelFactory, {super.key});

//   @override
//   State<DocumentUploadView> createState() => _DocumentUploadViewState();
// }

// class _DocumentUploadViewState extends State<DocumentUploadView> {
//   final Logger _logger = Logger('DocumentUploadView');

//   late final DocumentUploadViewModel viewModel = widget.viewModelFactory();

//   @override
//   void initState() {
//     super.initState();

//     viewModel.loadDocument.addListener(_onLoadUpdate);
//     viewModel.uploadDocument.addListener(_onUploadUpdate);

//     viewModel.loadDocument.execute();
//   }

//   @override
//   void dispose() {
//     viewModel.dispose();
//     viewModel.loadDocument.removeListener(_onLoadUpdate);
//     viewModel.uploadDocument.removeListener(_onUploadUpdate);
//     super.dispose();
//   }

//   void _onLoadUpdate() {
//     final result = viewModel.loadDocument.value;

//     if (result == null) {
//       // Initial state, do nothing
//       return;
//     }

//     if (result.isError()) {
//       _logger.warning('Document load cancelled or failed');

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Operação cancelada.")));
//       context.go(Routes.home);
//       return;
//     }
//   }

//   void _onUploadUpdate() {
//     final result = viewModel.uploadDocument.value;

//     if (result == null) {
//       // Initial state, do nothing
//       return;
//     }

//     if (result.isError()) {
//       final error = result.tryGetError();
//       _logger.severe('Error uploading document: $error', error);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text("Ocorreu um erro ao fazer upload"),
//           backgroundColor: Theme.of(context).colorScheme.error,
//         ),
//       );
//       context.go(Routes.home);
//       return;
//     }
//     if (result.isSuccess() && result.getOrThrow() != null) {
//       _logger.info('Document uploaded successfully');
//       context.go(Routes.home);
//       return;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: viewModel.loadDocument.isExecuting,
//       builder: (context, bool isLoadExecuting, _) {
//         return ValueListenableBuilder(
//           valueListenable: viewModel.uploadDocument.isExecuting,
//           builder: (context, bool isUploadExecuting, _) {
//             final loadCommand = viewModel.loadDocument;
//             final uploadCommand = viewModel.uploadDocument;

//             // Show loading indicator if is loading, uploading, initial state or error
//             final isInitialState = loadCommand.value == null;
//             final isLoadingError = loadCommand.value?.isError() ?? false;
//             final isUploadError = uploadCommand.value?.isError() ?? false;
//             if (isInitialState ||
//                 isLoadExecuting ||
//                 isUploadExecuting ||
//                 isLoadingError ||
//                 isUploadError) {
//               return const Scaffold(
//                 body: Center(child: CircularProgressIndicator()),
//               );
//             }

//             // At this point, we have a successfully loaded file
//             final file = loadCommand.value!.getOrThrow();

//             // Inner ListenableBuilder: Listen to currentStep for navigation
//             return ValueListenableBuilder(
//               valueListenable: viewModel.currentStep,
//               builder: (context, val, _) {
//                 // Show preview or form based on current step
//                 return switch (val) {
//                   UploadStep.preview => DocumentUploadPreview(
//                     document: PdfDocument.openFile(file.path),
//                     onCancel: () => context.go(Routes.home),
//                     onConfirm: viewModel.goToForm,
//                   ),
//                   UploadStep.form => DocumentInfoFormView(
//                     DocumentInfoFormViewModel(
//                       onFormSubmit: viewModel.handleFormSubmit,
//                     ),
//                     onBack: viewModel.goBackToPreview,
//                   ),
//                 };
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
