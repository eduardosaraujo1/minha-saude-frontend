import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth/auth_repository.dart';
import '../../data/repositories/document_repository.dart';
import '../../data/repositories/document_upload_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../ui/router/middleware/auth_middleware.dart';
import '../view_models/auth/register_view_model.dart';
import '../old/compartilhar/codigos_compartilhamento.dart';
import '../view_models/settings/edit_nome_view_model.dart';
import '../view_models/settings/edit_birthday_view_model.dart';
import '../view_models/settings/edit_telefone_view_model.dart';
import '../views/profile/edit_nome_view.dart';
import '../views/profile/edit_birthday_view.dart';
import '../views/profile/edit_telefone_view.dart';
import '../view_models/document/document_create_view_model.dart';
import '../view_models/document/document_scan_view_model.dart';
import '../view_models/document/document_view_model.dart';
import '../views/document/document_create_view.dart';
import '../views/document/document_scan_view.dart';
import '../views/document/document_view.dart';
import '../view_models/lixeira/deleted_document_view_model.dart';
import '../view_models/lixeira/lixeira_view_model.dart';
import '../views/lixeira/deleted_document_view.dart';
import '../view_models/auth/login_view_model.dart';
import '../view_models/auth/tos_view_model.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/tos_view.dart';
import '../views/settings/configuracoes_view.dart';
import '../view_models/document/document_list_view_model.dart';
import '../views/document/document_list_view.dart';
import '../views/lixeira/lixeira_view.dart';
import '../views/shared/app_view.dart';
import '../views/shared/not_found.dart';
import '../router/utils/middleware_handler.dart';
import '../router/routes.dart';

final _getIt = GetIt.I;

final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter router() {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: _getIt<AuthRepository>(),
    redirect: (BuildContext context, GoRouterState state) async {
      final middlewareHandler = MiddlewareHandler([
        AuthMiddleware([
          Routes.login,
          Routes.tos,
          Routes.register,
        ], _getIt<AuthRepository>()),
      ]);
      final String? redirectUrl = await middlewareHandler.run(context, state);

      if (redirectUrl != null) {
        return redirectUrl;
      }

      return null;
    },
    routes: [
      // Auth Routes (without bottom navigation)
      GoRoute(
        path: Routes.login,
        builder: (BuildContext context, GoRouterState state) {
          return LoginView(LoginViewModel(_getIt<AuthRepository>()));
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
              return RegisterView(RegisterViewModel(_getIt<AuthRepository>()));
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
                    DocumentListViewModel(_getIt<DocumentRepository>()),
                  );
                },
                routes: [
                  GoRoute(
                    path: Routes.documentosUploadRelative,
                    builder: (BuildContext context, GoRouterState state) {
                      return DocumentScanView(
                        DocumentScanViewModel(
                          DocumentCreateType.upload,
                          _getIt<DocumentUploadRepository>(),
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
                          _getIt<DocumentUploadRepository>(),
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
                          _getIt<DocumentRepository>(),
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
                    LixeiraView(LixeiraViewModel(_getIt<DocumentRepository>())),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      return DeletedDocumentView(
                        DeletedDocumentViewModel(
                          state.pathParameters['id'] ?? '',
                          _getIt<DocumentRepository>(),
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
                        EditNomeViewModel(_getIt<ProfileRepository>()),
                      );
                    },
                  ),
                  GoRoute(
                    path: Routes.editTelefoneRelative,
                    builder: (context, state) {
                      return EditTelefoneView(
                        EditTelefoneViewModel(_getIt<ProfileRepository>()),
                      );
                    },
                  ),
                  GoRoute(
                    path: Routes.editBirthdateRelative,
                    builder: (context, state) {
                      return EditBirthdayView(
                        EditBirthdayViewModel(_getIt<ProfileRepository>()),
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
