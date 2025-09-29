import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_upload_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile_repository.dart';
import 'package:minha_saude_frontend/app/ui/view_models/auth/register_view_model.dart';
import 'package:minha_saude_frontend/app/ui/old/compartilhar/codigos_compartilhamento.dart';
import 'package:minha_saude_frontend/app/ui/view_models/settings/edit_nome_view_model.dart';
import 'package:minha_saude_frontend/app/ui/view_models/settings/edit_birthday_view_model.dart';
import 'package:minha_saude_frontend/app/ui/view_models/settings/edit_telefone_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/profile/edit_nome_view.dart';
import 'package:minha_saude_frontend/app/ui/views/profile/edit_birthday_view.dart';
import 'package:minha_saude_frontend/app/ui/views/profile/edit_telefone_view.dart';
import 'package:minha_saude_frontend/app/ui/view_models/document/document_create_view_model.dart';
import 'package:minha_saude_frontend/app/ui/view_models/document/document_scan_view_model.dart';
import 'package:minha_saude_frontend/app/ui/view_models/document/document_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/document/document_create_view.dart';
import 'package:minha_saude_frontend/app/ui/views/document/document_scan_view.dart';
import 'package:minha_saude_frontend/app/ui/views/document/document_view.dart';
import 'package:minha_saude_frontend/app/ui/view_models/lixeira/deleted_document_view_model.dart';
import 'package:minha_saude_frontend/app/ui/view_models/lixeira/lixeira_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/lixeira/deleted_document_view.dart';
import 'package:minha_saude_frontend/app/ui/view_models/auth/login_view_model.dart';
import 'package:minha_saude_frontend/app/ui/view_models/auth/tos_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/auth/login_view.dart';
import 'package:minha_saude_frontend/app/ui/views/auth/register_view.dart';
import 'package:minha_saude_frontend/app/ui/views/auth/tos_view.dart';
import 'package:minha_saude_frontend/app/ui/views/settings/configuracoes_view.dart';
import 'package:minha_saude_frontend/app/ui/view_models/document/document_list_view_model.dart';
import 'package:minha_saude_frontend/app/ui/views/document/document_list_view.dart';
import 'package:minha_saude_frontend/app/ui/views/lixeira/lixeira_view.dart';
import 'package:minha_saude_frontend/app/ui/views/shared/app_view.dart';
import 'package:minha_saude_frontend/app/ui/views/shared/not_found.dart';
import 'package:minha_saude_frontend/config/router/redirect_handler.dart';
import 'package:minha_saude_frontend/config/router/routes.dart';

class AppRouter {
  AppRouter(
    this._authRepository,
    this._documentRepository,
    this._uploadRepository,
    this._profileRepository,
  );

  final AuthRepository _authRepository;
  final DocumentRepository _documentRepository;
  final DocumentUploadRepository _uploadRepository;
  final ProfileRepository _profileRepository;

  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  GoRouter router() {
    return GoRouter(
      initialLocation: Routes.home,
      redirect: RedirectHandler.redirect,
      routes: [
        // Auth Routes (without bottom navigation)
        GoRoute(
          path: Routes.login,
          builder: (BuildContext context, GoRouterState state) {
            return LoginView(LoginViewModel(_authRepository));
          },
        ),
        GoRoute(
          path: Routes.tos,
          builder: (BuildContext context, GoRouterState state) {
            return TosView(TosViewModel());
          },
          routes: [
            GoRoute(
              path: Routes.registerRelative,
              builder: (BuildContext context, GoRouterState state) {
                return RegisterView(RegisterViewModel(_authRepository));
              },
            ),
          ],
        ),
        StatefulShellRoute.indexedStack(
          builder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return AppView(navigationShell: navigationShell);
              },
          branches: [
            // Documents branch
            StatefulShellBranch(
              navigatorKey: _shellNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.home,
                  builder: (BuildContext context, GoRouterState state) {
                    return DocumentListView(
                      DocumentListViewModel(_documentRepository),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: Routes.documentosUploadRelative,
                      builder: (BuildContext context, GoRouterState state) {
                        return DocumentScanView(
                          DocumentScanViewModel(
                            DocumentCreateType.upload,
                            _uploadRepository,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: Routes.documentosScanRelative,
                      builder: (BuildContext context, GoRouterState state) {
                        return DocumentScanView(
                          DocumentScanViewModel(
                            DocumentCreateType.scan,
                            _uploadRepository,
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: Routes.documentosCreateRelative,
                      builder: (BuildContext context, GoRouterState state) {
                        return DocumentCreateView(DocumentCreateViewModel());
                      },
                    ),
                    GoRoute(
                      path: '${Routes.documentosRelative}/:id',
                      builder: (BuildContext context, GoRouterState state) {
                        return DocumentView(
                          DocumentViewModel(
                            state.pathParameters['id'] ?? '',
                            _documentRepository,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Share branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.compartilhar,
                  builder: (BuildContext context, GoRouterState state) {
                    // return const CompartilharView();
                    return CodigosCompartilhamento();
                  },
                  routes: [
                    // GoRoute(
                    //   path: 'create',
                    //   builder: (context, state) {
                    //     return const SelecionarDocumentos();
                    //   },
                    // ),
                    // GoRoute(
                    //   path: ':codigo',
                    //   builder: (context, state) {
                    //     return const SelecionarDocumentos();
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
            // Trash branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.lixeira,
                  builder: (BuildContext context, GoRouterState state) =>
                      LixeiraView(LixeiraViewModel(_documentRepository)),
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (context, state) {
                        return DeletedDocumentView(
                          DeletedDocumentViewModel(
                            state.pathParameters['id'] ?? '',
                            _documentRepository,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // Settings branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.configuracoes,
                  builder: (BuildContext context, GoRouterState state) =>
                      const ConfiguracoesView(),
                  routes: [
                    GoRoute(
                      path: Routes.editNomeRelative,
                      builder: (context, state) {
                        return EditNomeView(
                          EditNomeViewModel(_profileRepository),
                        );
                      },
                    ),
                    GoRoute(
                      path: Routes.editTelefoneRelative,
                      builder: (context, state) {
                        return EditTelefoneView(
                          EditTelefoneViewModel(_profileRepository),
                        );
                      },
                    ),
                    GoRoute(
                      path: Routes.editBirthdateRelative,
                      builder: (context, state) {
                        return EditBirthdayView(
                          EditBirthdayViewModel(_profileRepository),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) => NotFoundView(state.fullPath ?? ''),
      // Main app routes with bottom navigation
    );
  }
}

// Global key for the shell navigator
