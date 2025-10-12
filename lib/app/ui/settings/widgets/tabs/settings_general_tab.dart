import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minha_saude_frontend/app/routing/routes.dart';
import 'package:minha_saude_frontend/app/ui/core/theme_provider.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';

class SettingsGeneralTab extends StatefulWidget {
  const SettingsGeneralTab({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  State<SettingsGeneralTab> createState() => _SettingsGeneralTabState();
}

class _SettingsGeneralTabState extends State<SettingsGeneralTab> {
  late final SettingsViewModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = widget.viewModel;
    viewModel.loadProfile.addListener(_handleLoadUpdate);
    viewModel.requestExportCommand.addListener(_handleExportRequest);

    viewModel.loadProfile.execute();
  }

  @override
  void dispose() {
    viewModel.loadProfile.removeListener(_handleLoadUpdate);
    viewModel.requestExportCommand.removeListener(_handleExportRequest);
    super.dispose();
  }

  void _handleLoadUpdate() {
    var result = viewModel.loadProfile.value;
    if (result == null) return;

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ocorreu um erro ao carregar dados do perfil.")),
      );
    }
  }

  void _handleExportRequest() {
    final result = viewModel.requestExportCommand.value;
    if (result == null) return;

    if (result.isError()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Ocorreu um erro ao solicitar a exportação dos dados. Contate-nos via suporte!",
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Solicitação de exportação enviada! Você receberá um e-mail com os dados em breve.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      key: ValueKey("scrollableColumn"),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informações', style: theme.textTheme.titleMedium),
        ValueListenableBuilder(
          valueListenable: viewModel.loadProfile.results,
          builder: (context, value, child) {
            if (value.isExecuting || value.data == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                ),
              );
            }

            final editFields = _getUserInfoFields(context);
            return ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: editFields.length,
              itemBuilder: (context, index) {
                return editFields[index];
              },
              separatorBuilder: (context, index) => const Divider(),
            );
          },
        ),
        _pageDivider(padTop: 4, padBottom: 6),
        Text('Dados e Privacidade', style: theme.textTheme.titleMedium),
        ...ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              key: ValueKey("btnExportData"),
              visualDensity: VisualDensity.compact,
              leading: Icon(Icons.mail_outlined),
              title: const Text('Exportar meus dados'),
              trailing: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                widget.viewModel.requestExportCommand.execute();
              },
            ),
          ],
        ),
        _pageDivider(padTop: 4, padBottom: 6),
        Text('Aparência', style: theme.textTheme.titleMedium),
        // Dark theme toggle (text on left, switch on right)
        SwitchListTile(
          key: ValueKey("darkThemeSwitch"),
          contentPadding: EdgeInsets.zero,
          title: const Text('Tema escuro'),
          value: theme.brightness == Brightness.dark,
          onChanged: (value) {
            ThemeProvider.of(context).toggleTheme();
          },
        ),
      ],
    );
  }

  List<_UserInfoTile> _getUserInfoFields(BuildContext context) {
    final source = viewModel.loadProfile.value;
    final profile = source?.tryGetSuccess();

    return [
      _UserInfoTile(label: 'CPF', value: profile?.cpf),
      _UserInfoTile(label: 'E-mail', value: profile?.email),
      _UserInfoTile(
        label: 'Nome',
        value: profile?.nome,
        editKey: ValueKey('btnEditName'),
        onEdit: () {
          context.go(Routes.editNome);
        },
      ),
      _UserInfoTile(
        label: 'Data de nascimento',
        value: profile?.dataNascimento == null
            ? null
            : DateFormat("dd/MM/yyyy").format(profile!.dataNascimento),
        editKey: ValueKey('btnEditBirthdate'),
        onEdit: () {
          context.go(Routes.editBirthdate);
        },
      ),
      _UserInfoTile(
        label: 'Telefone',
        value: profile?.telefone,
        editKey: ValueKey('btnEditPhone'),
        onEdit: () {
          context.go(Routes.editTelefone);
        },
      ),
    ];
  }

  Widget _pageDivider({required double padTop, required double padBottom}) {
    return Column(
      children: [
        SizedBox(height: padTop),
        Divider(thickness: 1.5),
        SizedBox(height: padBottom),
      ],
    );
  }
}

class _UserInfoTile extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback? onEdit;
  final Key? editKey;

  const _UserInfoTile({
    required this.label,
    required this.value,
    this.onEdit,
    this.editKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isInvalid = value == null || (value?.isEmpty ?? true);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      visualDensity: VisualDensity.compact,
      title: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      subtitle: Text(
        isInvalid ? 'Não encontrado' : value!,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isInvalid ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      trailing: (onEdit != null)
          ? InkWell(
              key: editKey,
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Editar",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
