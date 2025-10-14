import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/document/document.dart';
import '../../../routing/routes.dart';
import '../../../../config/asset.dart';
import '../../core/widgets/brand_app_bar.dart';
import '../view_models/trash_index_view_model.dart';

class TrashIndexView extends StatefulWidget {
  const TrashIndexView({required this.viewModelFactory, super.key});

  final TrashIndexViewModel Function() viewModelFactory;

  @override
  State<TrashIndexView> createState() => _TrashIndexViewState();
}

class _TrashIndexViewState extends State<TrashIndexView> {
  late final TrashIndexViewModel viewModel = widget.viewModelFactory();

  @override
  void initState() {
    super.initState();

    viewModel.loadDocuments.addListener(_onLoadUpdate);
    viewModel.loadDocuments.execute(false);
  }

  @override
  void dispose() {
    viewModel.loadDocuments.removeListener(_onLoadUpdate);
    viewModel.dispose();

    super.dispose();
  }

  void _onLoadUpdate() {
    if (!mounted) return;

    final state = viewModel.loadDocuments.value;
    if (state == null) {
      return;
    }
    if (state.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocorreu um erro ao carregar os documentos. ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: BrandAppBar(title: const Text('Lixeira')),
      body: ValueListenableBuilder(
        valueListenable: viewModel.loadDocuments.results,
        builder: (context, value, child) {
          final isLoading = value.isExecuting;
          final loadResult = value.data;
          final isError = loadResult?.isError() ?? false;

          if (isLoading || loadResult == null) {
            return Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              viewModel.loadDocuments.execute(true);
            },
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Builder(
                  builder: (context) {
                    if (isError) {
                      return Center(
                        child: Text(
                          'Ocorreu um erro ao carregar os documentos.',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                      );
                    }
                    final documents = loadResult.getOrThrow();

                    if (documents.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhum documento na lixeira.',
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final document = documents[index];

                        return _DocumentTile(
                          document: document,
                          onTap: () {
                            context.go(Routes.lixeiraWithId(document.uuid));
                          },
                        );
                      },
                      separatorBuilder: (_, _) {
                        return Divider();
                      },
                      itemCount: documents.length,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({
    required this.document,
    required this.onTap,
    // super.key,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  final Document document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lore =
        """
Paciente: ${_coalesceNullOrEmpty(document.paciente, 'Indefinido')}
Data: ${document.dataDocumento != null ? _formatDate(document.dataDocumento!) : 'Indefinida'} """;

    return ListTile(
      // tileColor: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      leading: AspectRatio(
        aspectRatio: 1,
        child: SvgPicture.asset(Asset.documentIcon),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        document.titulo ?? 'Documento sem título',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(lore),
      onTap: onTap,
    );
  }

  String _coalesceNullOrEmpty(String? val, String fallback) {
    if (val == null || val.isEmpty) {
      return fallback;
    }
    return val;
  }
}
