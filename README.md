# Minha Saúde Frontend

## Necessidades para build/debug

-   [Android Keystore](https://docs.flutter.dev/deployment/android#sign-the-app)
-   [Google Cloud - OAuth Client e Server](https://developer.android.com/identity/sign-in/credential-manager-siwg#set-google)
    -   ClientID e ServerId devem ser definidos em `.env`
    -   [Como gerar a chave SHA-1](https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-react-native-android-native-app)
-   Para iniciar o ambiente, utilize `flutter run --dart-define-from-file=.env`

## Para fazer

-   Escrever testes para google_auth_service (Test-Driven Development)
-   Refatorar google_auth_client para google_auth_service, simplificando-o para o mínimo necessário
-   Escrever testes para SessionService, AuthRepository, LoginViewModel e LoginView
    -   Lembrar que ViewModels normalmente são ChangeNotifier
-   Implementar SessionService, AuthRepository, LoginViewModel e LoginScreen
-   Utilizar command_it e watch_it, com o auxílio do listen_it
