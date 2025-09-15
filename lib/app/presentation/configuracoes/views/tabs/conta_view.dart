import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/view_models/conta_view_model.dart';
import 'package:watch_it/watch_it.dart';

class ContaView extends WatchingStatefulWidget {
  final ContaViewModel viewModel;
  const ContaView(this.viewModel, {super.key});

  @override
  State<ContaView> createState() => _ContaViewState();
}

class _ContaViewState extends State<ContaView> {
  ContaViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    final contaGoogleVinculada = watch(viewModel.googleVinculado).value;
    final isLinkingInProgress = watch(viewModel.isLinkingContaGoogle).value;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Minha conta",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _buildSecaoContaGoogle(contaGoogleVinculada, isLinkingInProgress),
              SizedBox(height: 16),
              Text('Ações', style: Theme.of(context).textTheme.titleMedium),
              _buildBotoesAcoes(),
            ],
          ),
        ),
      ],
    );
  }

  // --- Container da conta Google ---
  Widget _buildSecaoContaGoogle(
    bool contaGoogleVinculada,
    bool isLinkingInProgress,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          // Logo Google
          SvgPicture.asset(
            'assets/brand/google/logo.svg',
            width: 44,
            height: 44,
          ),
          const SizedBox(width: 12),
          // Texto no centro, com wrapping se necessário
          Expanded(
            child: Text(
              contaGoogleVinculada
                  ? 'Sua conta Google está vinculada.'
                  : 'Você não tem uma conta Google vinculada.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
            ),
          ),
          // Botão de ação à direita
          if (!contaGoogleVinculada)
            TextButton.icon(
              onPressed: () {
                if (!contaGoogleVinculada) {
                  _mostrarDialogoVincularGoogle(context);
                }
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.link,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              label: Text(
                'Vincular',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Botões Encerrar Sessão e Excluir Conta ---
  Widget _buildBotoesAcoes() {
    return Row(
      spacing: 8,
      children: [
        FilledButton.icon(
          label: Text("Encerrar Sessão"),
          onPressed: () {
            _mostrarDialogoEncerrarSessao(context);
          },
          icon: Icon(Icons.exit_to_app),
        ),
        FilledButton.icon(
          label: Text("Excluir Conta"),
          icon: Icon(Icons.warning_rounded),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () {
            _mostrarDialogoExcluirConta(context);
          },
        ),
      ],
    );
  }

  // --- Diálogo Encerrar Sessão ---
  void _mostrarDialogoEncerrarSessao(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Encerrar Sessão'),
          content: Text(
            'Tem certeza que deseja encerrar a sessão? Você terá que fazer login novamente caso faça isso.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                viewModel.signout();
                context.go('/login');
              },
              child: Text(
                'Encerrar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Diálogo Excluir Conta ---
  void _mostrarDialogoExcluirConta(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error,
            size: 40,
          ),
          title: Text('Excluir Conta'),
          content: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      'Ao confirmar a exclusão da sua conta, ocorrerá o seguinte:\n\n',
                ),
                TextSpan(
                  text:
                      'Sua conta será imediatamente desativada e não poderá mais ser acessada.\n'
                      'Todos os seus dados, documentos e configurações serão marcados para exclusão permanente.\n'
                      'Você terá até 30 dias para reativar sua conta. Após esse prazo, a exclusão será irreversível.\n'
                      'Para reativar sua conta, entre em contato com nossa equipe de suporte.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                viewModel
                    .signout(); // Enquanto não há backend para realizar exclusão
              },
              child: Text(
                'Excluir Conta',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Diálogo Vincular Google ---
  void _mostrarDialogoVincularGoogle(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Vincular Google'),
          content: Text(
            'Você tem certeza que deseja vincular sua conta Google. Essa ação não pode ser desfeita.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                viewModel.linkGoogleAccount();
                Navigator.pop(context);
              },
              child: Text(
                'Vincular',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
