import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/auth/repositories/auth_repository.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_repository.dart';
import 'package:minha_saude_frontend/app/data/document/repositories/document_upload_repository.dart';
import 'package:minha_saude_frontend/app/data/profile/repositories/profile_repository.dart';
import 'package:minha_saude_frontend/app/data/shared/repositories/token_repository.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/register_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/view_models/edit_nome_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/view_models/edit_birthday_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/view_models/edit_telefone_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/views/edit_nome_view.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/views/edit_birthday_view.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/views/edit_telefone_view.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_create_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_scan_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/views/document_create_view.dart';
import 'package:minha_saude_frontend/app/presentation/document/views/document_scan_view.dart';
import 'package:minha_saude_frontend/app/presentation/document/views/document_view.dart';
import 'package:minha_saude_frontend/di/get_it.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/login_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/view_models/tos_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/login_view.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/register_view.dart';
import 'package:minha_saude_frontend/app/presentation/auth/views/tos_view.dart';
import 'package:minha_saude_frontend/app/presentation/compartilhar/views/compartilhar_view.dart';
import 'package:minha_saude_frontend/app/presentation/configuracoes/views/configuracoes_view.dart';
import 'package:minha_saude_frontend/app/presentation/document/view_models/document_list_view_model.dart';
import 'package:minha_saude_frontend/app/presentation/document/views/document_list_view.dart';
import 'package:minha_saude_frontend/app/presentation/lixeira/views/lixeira_view.dart';
import 'package:minha_saude_frontend/app/presentation/shared/views/app_view.dart';
import 'package:minha_saude_frontend/app/presentation/shared/views/not_found.dart';

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
              builder: (BuildContext context, GoRouterState state) =>
                  const CompartilharView(),
            ),
          ],
        ),
        // Trash branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/lixeira',
              builder: (BuildContext context, GoRouterState state) =>
                  const LixeiraView(),
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
