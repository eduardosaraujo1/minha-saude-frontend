# Minha Saúde Frontend

## Necessidades para build/debug

-   [Android Keystore](https://docs.flutter.dev/deployment/android#sign-the-app)
-   [Google Cloud - OAuth Client e Server](https://developer.android.com/identity/sign-in/credential-manager-siwg#set-google)
    -   ClientID e ServerId devem ser definidos em `.env`
    -   [Como gerar a chave SHA-1](https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-react-native-android-native-app)
-   Antes de iniciar, execute o comando `dart run build_runner build` ou `dart run build_runner watch`
-   Para iniciar o ambiente, utilize `flutter run --dart-define-from-file=.env`

## Para fazer

-   [ ] DocumentIcon: fazer a lista de documentos usar Wrap para evitar overflow ou forçar 3 colunas em telas grandes (ensure fixed width)
-   [ ] Corrigir widget de loginDecorator para funcionar em telas Wide
-   [ ] ???
-   [ ] PdfPinchController: não suportado no Windows (ferramenta de teste), se possível verificar com Platform.\* API
-   [ ] Upload pdf via arquivo
-   [ ] Refatorar DocumentRepository para usar interface e consumir ApiClient
-   [ ] Refatorar ProfileRepository para usar interface e consumir ApiClient
-   [ ] Refatorar ShareRepository para usar interface e consumir ApiClient
-   [ ] Refatorar tela de compartilhamento
-   [ ] Escrever casos de teste para avaliar edge cases (especialmente no visualizar documento)
-   [ ] Tratativa de erro caso o backend se torne não-responsivo
-   [ ] Tirar título duplicado da Lixeira
-   [ ] Arrumar temas
