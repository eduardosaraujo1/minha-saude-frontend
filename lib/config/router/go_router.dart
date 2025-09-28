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
import 'package:minha_saude_frontend/config/di/service_locator.dart';
import 'package:minha_saude_frontend/config/router/middleware/middleware_handler.dart';

import 'middleware/auth_middleware.dart';

// Global key for the shell navigator
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final middlewareHandler = MiddlewareHandler([
      AuthMiddleware(['/login', '/tos', '/register']),
    ]);

    final middlewareResponse = await middlewareHandler.run(context, state);

    if (middlewareResponse != null) {
      return middlewareResponse;
    }

    return null;
  },
  errorBuilder: (context, state) => NotFoundView(state.fullPath ?? ''),
  routes: [
    // Main app routes with bottom navigation
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
              path: '/',
              builder: (BuildContext context, GoRouterState state) =>
                  DocumentListView(
                    DocumentListViewModel(
                      ServiceLocator.I<DocumentRepository>(),
                    ),
                  ),
              routes: [
                GoRoute(
                  path: 'documentos/upload',
                  builder: (BuildContext context, GoRouterState state) {
                    return DocumentScanView(
                      DocumentScanViewModel(
                        DocumentCreateType.upload,
                        ServiceLocator.I<DocumentUploadRepository>(),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'documentos/scan',
                  builder: (BuildContext context, GoRouterState state) {
                    return DocumentScanView(
                      DocumentScanViewModel(
                        DocumentCreateType.scan,
                        ServiceLocator.I<DocumentUploadRepository>(),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'documentos/create',
                  builder: (BuildContext context, GoRouterState state) {
                    return DocumentCreateView(DocumentCreateViewModel());
                  },
                ),
                GoRoute(
                  path: 'documentos/:id',
                  builder: (BuildContext context, GoRouterState state) {
                    return DocumentView(
                      DocumentViewModel(
                        state.pathParameters['id'] ?? '',
                        ServiceLocator.I<DocumentRepository>(),
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
              path: '/compartilhar',
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
              path: '/lixeira',
              builder: (BuildContext context, GoRouterState state) =>
                  LixeiraView(
                    LixeiraViewModel(ServiceLocator.I<DocumentRepository>()),
                  ),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    return DeletedDocumentView(
                      DeletedDocumentViewModel(
                        state.pathParameters['id'] ?? '',
                        ServiceLocator.I<DocumentRepository>(),
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
              path: '/configuracoes',
              builder: (BuildContext context, GoRouterState state) =>
                  const ConfiguracoesView(),
              routes: [
                GoRoute(
                  path: 'edit/nome',
                  builder: (context, state) {
                    return EditNomeView(
                      EditNomeViewModel(ServiceLocator.I<ProfileRepository>()),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit/telefone',
                  builder: (context, state) {
                    return EditTelefoneView(
                      EditTelefoneViewModel(
                        ServiceLocator.I<ProfileRepository>(),
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit/birthdate',
                  builder: (context, state) {
                    return EditBirthdayView(
                      EditBirthdayViewModel(
                        ServiceLocator.I<ProfileRepository>(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // Auth Routes (without bottom navigation)
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return LoginView(LoginViewModel(ServiceLocator.I<AuthRepository>()));
      },
    ),
    GoRoute(
      path: '/tos',
      builder: (BuildContext context, GoRouterState state) {
        return TosView(TosViewModel());
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return RegisterView(
          RegisterViewModel(ServiceLocator.I<AuthRepository>()),
        );
      },
    ),
  ],
);
