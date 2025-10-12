# Minha Saúde Frontend

## Necessidades para build/debug

-   [Android Keystore](https://docs.flutter.dev/deployment/android#sign-the-app)
-   [Google Cloud - OAuth Client e Server](https://developer.android.com/identity/sign-in/credential-manager-siwg#set-google)
    -   ClientID e ServerId devem ser definidos em `.env`
    -   [Como gerar a chave SHA-1](https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-react-native-android-native-app)
-   Antes de iniciar, execute o comando `dart run build_runner build` ou `dart run build_runner watch`
-   Para iniciar o ambiente, utilize `flutter run --dart-define-from-file=.env`

## Para fazer

-   [ ] Tela de lixeira de documentos
-   [ ] Ao excluir documento, atualizar lista de documents (invalidar cache do repositório)
-   [ ] Refatorar ShareRepository para usar interface e consumir ApiClient
-   [ ] Refatorar tela de compartilhamento
-   [ ] Tratativa de erro caso o backend se torne não-responsivo
-   [ ] Deletar conta requisitar login novamente (ver se consegue fazer isso a nivel API)
-   [ ] Realizar teste exploratório para tela de lado ou areas em que se esqueceu do SafeArea
-   [ ] SE tiver tempo, considerar fazer a organização dos documentos ocorrer no backend via API para evitar um array com todos os documentos na memoria RAM (permitirá paginação). Requer repensar a arquitetura dos documentos
-   [ ] Trazer opções prontas para tipos de exame (ainda permitir usuário escolher customizado)
