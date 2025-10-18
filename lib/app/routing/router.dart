import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:minha_saude_frontend/app/data/repositories/auth/auth_repository.dart';

// Alt + Shift + O -> organize imports
import '../data/repositories/document/document_repository.dart';
import '../data/repositories/profile/profile_repository.dart';
import '../data/repositories/session/session_repository.dart';
import '../data/repositories/trash/trash_repository.dart';
import '../domain/actions/auth/get_tos_action.dart';
import '../domain/actions/auth/logout_action.dart';
import '../domain/actions/auth/process_login_result_action.dart';
import '../domain/actions/auth/register_action.dart';
import '../domain/actions/settings/delete_user_action.dart';
import '../domain/actions/settings/request_export_action.dart';
import '../ui/auth/view_models/email_auth_view_model.dart';
import '../ui/auth/view_models/login_view_model.dart';
import '../ui/auth/view_models/register_view_model.dart';
import '../ui/auth/widgets/email/email_auth_view.dart';
import '../ui/auth/widgets/login_view.dart';
import '../ui/auth/widgets/register/register_navigator.dart';
import '../ui/core/widgets/not_found.dart';
import '../ui/core/widgets/scaffold_with_navbar.dart';
import '../ui/core/widgets/under_construction_screen.dart';
import '../ui/documents/view_models/document_view_model.dart';
import '../ui/documents/view_models/index/document_list_view_model.dart';
import '../ui/documents/view_models/metadata/document_edit_view_model.dart';
import '../ui/documents/view_models/metadata/document_metadata_view_model.dart';
import '../ui/documents/view_models/upload/document_upload_view_model.dart';
import '../ui/documents/widgets/document_view.dart';
import '../ui/documents/widgets/index/document_list_screen.dart';
import '../ui/documents/widgets/metadata/document_edit_screen.dart';
import '../ui/documents/widgets/metadata/document_metadata_screen.dart';
import '../ui/documents/widgets/upload/document_upload_view.dart';
import '../ui/settings/view_models/settings_edit_view_model.dart';
import '../ui/settings/view_models/settings_view_model.dart';
import '../ui/settings/widgets/edit/settings_edit_birthdate.dart';
import '../ui/settings/widgets/edit/settings_edit_name.dart';
import '../ui/settings/widgets/edit/settings_edit_phone.dart';
import '../ui/settings/widgets/settings_tab_view.dart';
import '../ui/trash/view_models/deleted_document_view_model.dart';
import '../ui/trash/view_models/trash_index_view_model.dart';
import '../ui/trash/widgets/deleted_document_view.dart';
import '../ui/trash/widgets/trash_index_view.dart';
import 'routes.dart';

final _documentNavigatorKey = GlobalKey<NavigatorState>();

final _getIt = GetIt.I;
final _sessionRepository = _getIt<SessionRepository>();
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.home,
  refreshListenable: Listenable.merge([_sessionRepository]),
  redirect: (BuildContext context, GoRouterState state) {
    return _redirectHandler(context, state, _sessionRepository);
  },
  routes: [
    GoRoute(
      path: Routes.home,
      redirect: (context, state) {
        if (state.fullPath == Routes.home) {
          return Routes.documentos;
        }
        return null;
      },
      routes: [
        // Auth Routes (without bottom navigation)
        GoRoute(
          path: Routes.auth,
          builder: (BuildContext context, GoRouterState state) {
            final loginViewModel = LoginViewModel(
              authRepository: _getIt(),
              processLoginAction: _getIt<ProcessLoginResultAction>(),
            );
            return LoginView(() => loginViewModel);
          },
          routes: [
            GoRoute(
              path: Routes.emailAuthRelative,
              builder: (context, state) {
                final viewModel = EmailAuthViewModel(
                  authRepository: _getIt<AuthRepository>(),
                  processLoginResultAction: _getIt<ProcessLoginResultAction>(),
                );
                return EmailAuthView(viewModelFactory: () => viewModel);
              },
            ),
            GoRoute(
              path: Routes.registerRelative,
              builder: (BuildContext context, GoRouterState state) {
                final viewModel = RegisterViewModel(
                  registerAction: _getIt<RegisterAction>(),
                  getTosAction: _getIt<GetTosAction>(),
                );

                return RegisterNavigator(viewModelFactory: () => viewModel);
              },
            ),
          ],
        ),
        // Document Upload routes (no bottom navigation)
        GoRoute(
          path: Routes.documentosUpload,
          builder: (BuildContext context, GoRouterState state) {
            return DocumentUploadView(
              () => DocumentUploadViewModel(
                DocumentUploadMethod.upload,
                _getIt<DocumentRepository>(),
              ),
            );
          },
        ),
        GoRoute(
          path: Routes.documentosScan,
          builder: (BuildContext context, GoRouterState state) {
            return DocumentUploadView(
              () => DocumentUploadViewModel(
                DocumentUploadMethod.scan,
                _getIt<DocumentRepository>(),
              ),
            );
          },
        ),
        StatefulShellRoute.indexedStack(
          builder:
              (
                BuildContext context,
                GoRouterState state,
                StatefulNavigationShell navigationShell,
              ) {
                return ScaffoldWithNavbar(navigationShell: navigationShell);
              },
          branches: [
            // Documents branch
            StatefulShellBranch(
              navigatorKey: _documentNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.documentosRelative,
                  builder: (context, state) {
                    return DocumentListScreen(
                      () => DocumentListViewModel(
                        documentRepository: _getIt<DocumentRepository>(),
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: ':id',
                      builder: (BuildContext context, GoRouterState state) {
                        return DocumentView(
                          () => DocumentViewModel(
                            documentUuid: state.pathParameters['id'] ?? '',
                            documentRepository: _getIt<DocumentRepository>(),
                          ),
                        );
                      },
                      routes: [
                        GoRoute(
                          path: Routes.documentosInfoRelative,
                          builder: (context, state) {
                            return DocumentMetadataView(
                              viewModel: DocumentMetadataViewModel(
                                documentUuid: state.pathParameters['id'] ?? '',
                                documentRepository:
                                    _getIt<DocumentRepository>(),
                              ),
                            );
                          },
                        ),
                        GoRoute(
                          path: Routes.documentosEditRelative,
                          builder: (context, state) {
                            return DocumentEditScreen(
                              () => DocumentEditViewModel(
                                documentUuid: state.pathParameters['id'] ?? '',
                                documentRepository:
                                    _getIt<DocumentRepository>(),
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
            // Share branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.compartilhar,
                  builder: (BuildContext context, GoRouterState state) {
                    // return const CompartilharView();
                    // return CodigosCompartilhamento();
                    return UnderConstructionScreen();
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
                  builder: (BuildContext context, GoRouterState state) {
                    return TrashIndexView(
                      viewModelFactory: () => TrashIndexViewModel(
                        trashRepository: _getIt<TrashRepository>(),
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: ':id',
                      redirect: (context, state) {
                        if (state.pathParameters['id'] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Documento não encontrado'),
                            ),
                          );
                          return Routes.lixeira;
                        }
                        return null;
                      },
                      builder: (context, state) {
                        return DeletedDocumentView(
                          viewModelFactory: () => DeletedDocumentViewModel(
                            documentUuid: state.pathParameters['id']!,
                            trashRepository: _getIt<TrashRepository>(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // // Settings branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.configuracoes,
                  builder: (BuildContext context, GoRouterState state) {
                    return SettingsTabView(
                      () => SettingsViewModel(
                        profileRepository: _getIt<ProfileRepository>(),
                        deleteUserAction: _getIt<DeleteUserAction>(),
                        requestExportAction: _getIt<RequestExportAction>(),
                        logoutAction: _getIt<LogoutAction>(),
                      ),
                    );
                  },
                  routes: [
                    GoRoute(
                      path: Routes.editNomeRelative,
                      builder: (context, state) {
                        return SettingsEditName(
                          viewModelFactory: () => SettingsEditViewModel(
                            fieldType: SettingsEditField.name,
                            profileRepository: _getIt<ProfileRepository>(),
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: Routes.editTelefoneRelative,
                      builder: (context, state) {
                        return SettingsEditPhone(
                          viewModelFactory: () => SettingsEditViewModel(
                            fieldType: SettingsEditField.phone,
                            profileRepository: _getIt<ProfileRepository>(),
                          ),
                        );
                      },
                    ),
                    GoRoute(
                      path: Routes.editBirthdateRelative,
                      builder: (context, state) {
                        return SettingsEditBirthdate(
                          viewModelFactory: () => SettingsEditViewModel(
                            fieldType: SettingsEditField.birthdate,
                            profileRepository: _getIt<ProfileRepository>(),
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
      ],
    ),
  ],
  errorBuilder: (context, state) => NotFoundView(state.fullPath ?? ''),
  // Main app routes with bottom navigation
);

// Cache the router instance to preserve navigation state across rebuilds
GoRouter router() => _router;

Future<String?> _redirectHandler(
  BuildContext context,
  GoRouterState state,
  SessionRepository sessionRepository,
) async {
  final isAuthed = await sessionRepository.hasAuthToken();
  final isRegistering = sessionRepository.getRegisterToken() != null;
  final requestedRoute = state.fullPath ?? state.matchedLocation;
  final isOnAuthRoute = requestedRoute.startsWith(Routes.auth);

  if (!isAuthed && !isOnAuthRoute) {
    if (isRegistering) {
      return Routes.register;
    }
    return Routes.auth;
  }

  if (isAuthed && isOnAuthRoute) {
    return Routes.home;
  }

  return null;
}
