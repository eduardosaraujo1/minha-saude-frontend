import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/core/theme_provider.dart';
import 'package:minha_saude_frontend/app/ui/settings/view_models/settings_view_model.dart';

class SettingsGeneralTab extends StatelessWidget {
  const SettingsGeneralTab({super.key, required this.viewModel});

  final SettingsViewModel viewModel;

  void triggerExportData() {
    // viewModel.exportData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final editFields = _getUserInfoFields(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informações', style: theme.textTheme.titleMedium),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: editFields.length,
          itemBuilder: (context, index) {
            return editFields[index];
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
        _pageDivider(padTop: 4, padBottom: 6),
        Text('Dados e Privacidade', style: theme.textTheme.titleMedium),
        ...ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: Icon(Icons.mail_outlined),
              title: const Text('Exportar dados'),
              trailing: Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                triggerExportData();
              },
            ),
          ],
        ),
        _pageDivider(padTop: 4, padBottom: 6),
        Text('Aparência', style: theme.textTheme.titleMedium),
        // Dark theme toggle (text on left, switch on right)
        SwitchListTile(
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
    return [
      _UserInfoTile(label: 'CPF', value: "Lorem"),
      _UserInfoTile(label: 'E-mail', value: "Lorem"),
      _UserInfoTile(
        label: 'Nome completo',
        value: "Lorem",
        onEdit: () {
          // context.go('/configuracoes/edit/nome');
        },
      ),
      _UserInfoTile(
        label: 'Data de nascimento',
        value: "Lorem",
        onEdit: () {
          // context.go('/configuracoes/edit/birthdate');
        },
      ),
      _UserInfoTile(
        label: 'Telefone',
        value: "Lorem",
        onEdit: () {
          // context.go('/configuracoes/edit/telefone');
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
  final String value;
  final VoidCallback? onEdit;

  const _UserInfoTile({required this.label, required this.value, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEmpty = value.isEmpty;

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
        isEmpty ? 'Não encontrado' : value,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isEmpty ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      trailing: (onEdit != null)
          ? InkWell(
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
      // onEdit != null ? _buildEditButton(context) : null,
    );
  }
}
