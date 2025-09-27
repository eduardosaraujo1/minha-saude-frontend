import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/document_upload_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/repositories/token_repository.dart';
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
import 'package:minha_saude_frontend/di/get_it.dart';
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

// Global key for the shell navigator
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final authRepository = getIt<AuthRepository>();
    final tokenRepository = getIt<TokenRepository>();

    // Check authentication state
    final hasSessionToken = await tokenRepository.hasToken();
    final hasRegisterToken = authRepository.hasValidRegisterToken;

    final authRoutes = ['/login', '/tos', '/register'];
    final isOnAuthRoute = authRoutes.contains(state.fullPath);

    // If user has session token (fully authenticated), redirect away from auth routes
    if (hasSessionToken && isOnAuthRoute) {
      return '/';
    }

    // If user has register token but not session token (needs to complete registration)
    if (hasRegisterToken && !hasSessionToken) {
      if (state.fullPath != '/tos' && state.fullPath != '/register') {
        return '/tos'; // Start registration flow
      }
      return null; // Allow TOS and register routes
    }

    // If user has no valid tokens and not on auth route, go to login
    if (!hasSessionToken && !hasRegisterToken && !isOnAuthRoute) {
      return '/login';
    }

    // If user has session token, allow access to main app
    if (hasSessionToken && !isOnAuthRoute) {
      return null;
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
                    DocumentListViewModel(getIt<DocumentRepository>()),
                  ),
              routes: [
                GoRoute(
                  path: 'documentos/upload',
                  builder: (BuildContext context, GoRouterState state) {
                    return DocumentScanView(
                      DocumentScanViewModel(
                        DocumentCreateType.upload,
                        getIt<DocumentUploadRepository>(),
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
                        getIt<DocumentUploadRepository>(),
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
                        getIt<DocumentRepository>(),
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
                  LixeiraView(LixeiraViewModel(getIt<DocumentRepository>())),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    return DeletedDocumentView(
                      DeletedDocumentViewModel(
                        state.pathParameters['id'] ?? '',
                        getIt<DocumentRepository>(),
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
                      EditNomeViewModel(getIt<ProfileRepository>()),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit/telefone',
                  builder: (context, state) {
                    return EditTelefoneView(
                      EditTelefoneViewModel(getIt<ProfileRepository>()),
                    );
                  },
                ),
                GoRoute(
                  path: 'edit/birthdate',
                  builder: (context, state) {
                    return EditBirthdayView(
                      EditBirthdayViewModel(getIt<ProfileRepository>()),
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
        return LoginView(
          LoginViewModel(getIt<AuthRepository>(), getIt<TokenRepository>()),
        );
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
          RegisterViewModel(getIt<AuthRepository>(), getIt<TokenRepository>()),
        );
      },
    ),
  ],
);
