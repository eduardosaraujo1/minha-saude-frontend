import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/session/session_repository.dart';
import '../domain/actions/auth/logout_action.dart';
import '../domain/actions/auth/register_action.dart';
import '../ui/core/widgets/scaffold_with_navbar.dart';
import '../ui/documents/view_models/metadata/document_edit_view_model.dart';
import '../ui/documents/view_models/metadata/document_metadata_view_model.dart';
import '../ui/documents/widgets/metadata/document_metadata_screen.dart';
import '../ui/settings/view_models/settings_view_model.dart';
import '../ui/settings/widgets/settings_tab_view.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/document/document_repository.dart';
// import '../data/repositories/document_upload_repository.dart';
// import '../data/repositories/profile_repository.dart';
import '../domain/actions/auth/login_with_google.dart';
import '../ui/auth/view_models/login_view_model.dart';
import '../ui/auth/view_models/register_view_model.dart';
import '../ui/auth/view_models/tos_view_model.dart';
import '../ui/auth/widgets/login_view.dart';
import '../ui/auth/widgets/register_view.dart';
import '../ui/auth/widgets/tos_view.dart';
import '../ui/core/widgets/not_found.dart';
import '../ui/documents/view_models/document_view_model.dart';
import '../ui/documents/view_models/index/document_list_view_model.dart';
import '../ui/documents/view_models/upload/document_upload_view_model.dart';
import '../ui/documents/widgets/document_view.dart';
import '../ui/documents/widgets/index/document_list_screen.dart';
import '../ui/documents/widgets/metadata/document_edit_screen.dart';
import '../ui/documents/widgets/upload/document_upload_view.dart';
import 'routes.dart';

final _getIt = GetIt.I;

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _documentNavigatorKey = GlobalKey<NavigatorState>();

GoRouter router() {
  final sessionRepository = _getIt<SessionRepository>();

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    refreshListenable: sessionRepository,
    redirect: (BuildContext context, GoRouterState state) {
      return _redirectHandler(context, state, sessionRepository);
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
            path: Routes.login,
            builder: (BuildContext context, GoRouterState state) {
              return LoginView(
                LoginViewModel(
                  _getIt<AuthRepository>(),
                  _getIt<LoginWithGoogle>(),
                ),
              );
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
                  return RegisterView(
                    RegisterViewModel(registerAction: _getIt<RegisterAction>()),
                  );
                },
              ),
            ],
          ),
          // Document Upload routes (no bottom navigation)
          GoRoute(
            path: Routes.documentosUpload,
            builder: (BuildContext context, GoRouterState state) {
              return DocumentUploadView(
                DocumentUploadViewModel(
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
                DocumentUploadViewModel(
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
                        DocumentListViewModel(_getIt<DocumentRepository>()),
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (BuildContext context, GoRouterState state) {
                          return DocumentView(
                            DocumentViewModel(
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
                                  documentUuid:
                                      state.pathParameters['id'] ?? '',
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
                                DocumentEditViewModel(
                                  documentUuid:
                                      state.pathParameters['id'] ?? '',
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
              // StatefulShellBranch(
              //   routes: [
              //     GoRoute(
              //       path: Routes.compartilhar,
              //       builder: (BuildContext context, GoRouterState state) {
              //         // return const CompartilharView();
              //         return CodigosCompartilhamento();
              //       },
              //       routes: [
              //         // GoRoute(
              //         //   path: 'create',
              //         //   builder: (context, state) {
              //         //     return const SelecionarDocumentos();
              //         //   },
              //         // ),
              //         // GoRoute(
              //         //   path: ':codigo',
              //         //   builder: (context, state) {
              //         //     return const SelecionarDocumentos();
              //         //   },
              //         // ),
              //       ],
              //     ),
              //   ],
              // ),
              // // Trash branch
              // StatefulShellBranch(
              //   routes: [
              //     GoRoute(
              //       path: Routes.lixeira,
              //       builder: (BuildContext context, GoRouterState state) =>
              //           LixeiraView(LixeiraViewModel(_getIt<DocumentRepository>())),
              //       routes: [
              //         GoRoute(
              //           path: ':id',
              //           builder: (context, state) {
              //             return DeletedDocumentView(
              //               DeletedDocumentViewModel(
              //                 state.pathParameters['id'] ?? '',
              //                 _getIt<DocumentRepository>(),
              //               ),
              //             );
              //           },
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
              // // Settings branch
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: Routes.configuracoes,
                    builder: (BuildContext context, GoRouterState state) {
                      return SettingsTabView(
                        SettingsViewModel(logoutAction: _getIt<LogoutAction>()),
                      );
                    },
                    routes: [
                      // GoRoute(
                      //   path: Routes.editNomeRelative,
                      //   builder: (context, state) {
                      //     return EditNomeView(
                      //       EditNomeViewModel(_getIt<ProfileRepository>()),
                      //     );
                      //   },
                      // ),
                      // GoRoute(
                      //   path: Routes.editTelefoneRelative,
                      //   builder: (context, state) {
                      //     return EditTelefoneView(
                      //       EditTelefoneViewModel(_getIt<ProfileRepository>()),
                      //     );
                      //   },
                      // ),
                      // GoRoute(
                      //   path: Routes.editBirthdateRelative,
                      //   builder: (context, state) {
                      //     return EditBirthdayView(
                      //       EditBirthdayViewModel(_getIt<ProfileRepository>()),
                      //     );
                      //   },
                      // ),
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
}

Future<String?> _redirectHandler(
  BuildContext context,
  GoRouterState state,
  SessionRepository sessionRepository,
) async {
  const authRoutes = <String>{Routes.login, Routes.tos, Routes.register};

  final isAuthed = await sessionRepository.hasAuthToken();
  final isRegistering = sessionRepository.getRegisterToken() != null;
  final requestedRoute = state.fullPath ?? state.matchedLocation;
  final isOnAuthRoute = authRoutes.contains(requestedRoute);

  if (!isAuthed && !isOnAuthRoute) {
    if (isRegistering) {
      return Routes.register;
    }
    return Routes.login;
  }

  if (isAuthed && isOnAuthRoute) {
    return Routes.home;
  }

  return null;
}
