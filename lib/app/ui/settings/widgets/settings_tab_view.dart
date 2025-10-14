import 'package:flutter/material.dart';
import 'package:minha_saude_frontend/app/ui/settings/widgets/tabs/settings_account_tab.dart';

import '../../core/widgets/brand_app_bar.dart';
import '../view_models/settings_view_model.dart';
import 'tabs/settings_general_tab.dart';
import 'tabs/settings_support_tab.dart';

class SettingsTabView extends StatefulWidget {
  final SettingsViewModel Function() viewModelFactory;

  const SettingsTabView(this.viewModelFactory, {super.key});

  @override
  State<SettingsTabView> createState() => _SettingsTabViewState();
}

class _SettingsTabViewState extends State<SettingsTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SettingsViewModel viewModel = widget.viewModelFactory();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorscheme = theme.colorScheme;

    return Scaffold(
      appBar: BrandAppBar(title: const Text('Configurações')),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: colorscheme.primary,
            indicatorWeight: 3,
            labelColor: colorscheme.primary,
            unselectedLabelColor: colorscheme.secondary,
            labelStyle: theme.textTheme.labelLarge,
            tabs: const [
              Tab(text: 'Geral'),
              Tab(text: 'Conta'),
              Tab(text: 'Suporte'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  [
                        SettingsGeneralTab(viewModel: viewModel),
                        SettingsAccountTab(viewModel: viewModel),
                        SettingsSupportTab(viewModel: viewModel),
                      ]
                      .map(
                        (e) => RefreshIndicator(
                          onRefresh: () async {
                            viewModel.loadProfile.execute();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            child: e,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
