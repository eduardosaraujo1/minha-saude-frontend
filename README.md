# Minha Saúde Frontend

## Necessidades para build/debug

-   [Android Keystore](https://docs.flutter.dev/deployment/android#sign-the-app)
-   [Google Cloud - OAuth Client e Server](https://developer.android.com/identity/sign-in/credential-manager-siwg#set-google)
    -   ClientID e ServerId devem ser definidos em `.env`
    -   [Como gerar a chave SHA-1](https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-react-native-android-native-app)
-   Antes de iniciar, execute o comando `dart run build_runner build` ou `dart run build_runner watch`
-   Para iniciar o ambiente, utilize `flutter run --dart-define-from-file=.env`

## Para fazer

-   Escrever testes para google_auth_service (Test-Driven Development)
-   Refatorar google_auth_client para google_auth_service, simplificando-o para o mínimo necessário
-   Escrever testes para SessionService, AuthRepository, LoginViewModel e LoginView
    -   Lembrar que ViewModels normalmente são ChangeNotifier
-   Implementar SessionService, AuthRepository, LoginViewModel e LoginScreen
