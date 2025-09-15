import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/view_models/general_view_model.dart';
import 'package:watch_it/watch_it.dart';

class GeneralView extends WatchingStatefulWidget {
  final GeneralViewModel viewModel;
  const GeneralView(this.viewModel, {super.key});

  @override
  State<GeneralView> createState() => _GeneralViewState();
}

class _GeneralViewState extends State<GeneralView> {
  GeneralViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    final user = watch(viewModel.user).value;
    final isLoading = user == null;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informações'),
          const SizedBox(height: 16),
          _buildUserInfoSection(user),
          const SizedBox(height: 16),
          _buildSectionTitle('Dados e Privacidade'),
          _buildExportDataButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
    );
  }

  Widget _buildUserInfoSection(user) {
    return Column(
      children: [
        _UserInfoField(label: 'CPF', value: user.cpf),
        _UserInfoField(label: 'E-mail', value: user.email),
        _UserInfoField(
          label: 'Nome completo',
          value: user.name,
          onEdit: () => _showComingSoonSnackBar('Edição de nome'),
        ),
        _UserInfoField(
          label: 'Data de nascimento',
          value: user.birthDate,
          onEdit: () => _showComingSoonSnackBar('Edição de data de nascimento'),
        ),
        _UserInfoField(
          label: 'Telefone',
          value: user.telefone,
          onEdit: () => _showComingSoonSnackBar('Edição de telefone'),
        ),
      ],
    );
  }

  Widget _buildExportDataButton() {
    return SizedBox(
      child: FilledButton.icon(
        onPressed: _showExportDialog,
        icon: const Icon(Icons.email_outlined, size: 20),
        label: const Text('Exportar Dados'),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => _ExportDataDialog(
        onConfirm: () {
          Navigator.pop(context);
          _showExportSuccessSnackBar();
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showComingSoonSnackBar(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature em breve'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showExportSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Seus dados serão enviados por e-mail dentro de 24 horas",
        ),
        showCloseIcon: true,
      ),
    );
  }
}

class _UserInfoField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;

  const _UserInfoField({required this.label, required this.value, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFieldContent(context),
        _buildDivider(context),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildFieldContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildFieldInfo(context)),
          if (onEdit != null) _buildEditButton(context),
        ],
      ),
    );
  }

  Widget _buildFieldInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context),
        const SizedBox(height: 4),
        _buildFieldValue(context),
      ],
    );
  }

  Widget _buildFieldLabel(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildFieldValue(BuildContext context) {
    final isEmpty = value.isEmpty;
    return Text(
      isEmpty ? 'Não informado' : value,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isEmpty
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSurface,
        fontStyle: isEmpty ? FontStyle.italic : null,
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: InkWell(
        onTap: onEdit,
        child: Row(
          children: [
            _buildEditText(context),
            const SizedBox(width: 4),
            _buildEditIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEditText(BuildContext context) {
    return Text('Editar', style: Theme.of(context).textTheme.bodyMedium);
  }

  Widget _buildEditIcon(BuildContext context) {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 16,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
    );
  }
}

class _ExportDataDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ExportDataDialog({required this.onConfirm, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.email_outlined,
            size: 40,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 16),
          Text(
            'Exportar Dados',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '• Seus dados de conta e documentos serão incluídos na exportação.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Os dados serão enviados para o seu e-mail cadastrado em um arquivo para download.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• O link para download expirará 24 horas após o recebimento. O processo pode levar algum tempo.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '• Você receberá um e-mail quando estiver pronto.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Para continuar, clique em "Confirmar Exportar" abaixo.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        FilledButton(
          onPressed: onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar Exportar'),
        ),
      ],
    );
  }
}
