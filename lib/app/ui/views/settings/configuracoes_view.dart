import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile_repository.dart';
import 'package:minha_saude_frontend/app/ui/view_models/settings/conta_view_model.dart';
import 'package:minha_saude_frontend/app/ui/view_models/settings/general_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/settings/tabs/conta_view.dart';
import 'package:minha_saude_frontend/app/ui/views/settings/tabs/general_view.dart';
import 'package:minha_saude_frontend/app/ui/views/settings/tabs/suporte_view.dart';
import 'package:minha_saude_frontend/app/ui/widgets/app/brand_app_bar.dart';
import 'package:minha_saude_frontend/di/get_it.dart';

class ConfiguracoesView extends StatefulWidget {
  const ConfiguracoesView({super.key});

  @override
  State<ConfiguracoesView> createState() => _ConfiguracoesViewState();
}

class _ConfiguracoesViewState extends State<ConfiguracoesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(title: const Text('Configurações')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).primaryColor,
            indicatorWeight: 3,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            labelStyle: Theme.of(context).textTheme.labelLarge,
            tabs: const [
              Tab(text: 'Geral'),
              Tab(text: 'Conta'),
              Tab(text: 'Suporte'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GeneralView(GeneralViewModel(getIt<ProfileRepository>())),
                ContaView(ContaViewModel(getIt<AuthRepository>())),
                SuporteView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
