# Minha Saúde Frontend

## Necessidades para build/debug

-   [Android Keystore](https://docs.flutter.dev/deployment/android#sign-the-app)
-   [Google Cloud - OAuth Client e Server](https://developer.android.com/identity/sign-in/credential-manager-siwg#set-google)
    -   ClientID e ServerId devem ser definidos em `.env`
    -   [Como gerar a chave SHA-1](https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-react-native-android-native-app)
-   Antes de iniciar, execute o comando `dart run build_runner build` ou `dart run build_runner watch`
-   Para iniciar o ambiente, utilize `flutter run --dart-define-from-file=.env`

## Para fazer

-   [ ] Refatorar register flow com nested navigator
-   [ ] Testes para business reqs login via e-mail
-   [ ] Tela de upload de documento com 3 etapas
-   [ ] Repensar no que fazer caso server não possa se conectar ao servidor (signout não faz sentido, então se tiver com o session token e a resposta do servidor não for 401 Unauthorized simplesmente exiba os armazenados localmente)
-   [ ] Fazer o form de adicionar documento ter opções padrão (algumas pré-existentes, outras podendo o usuário escolher). API envia a lista de categorias para o cliente e o app usa essas categorias num dropdown, podendo esse ser substituido por um text field normal
-   [ ] Implementar ShareRepository para usar interface e consumir ApiClient
-   [ ] Implementar tela de compartilhamento
-   [ ] Tratativa de erro caso o backend se torne não-responsivo (testar)
-   [ ] Deletar conta requisitar login novamente (ver se consegue fazer isso a nivel API)
-   [ ] Realizar teste exploratório para tela de lado ou areas em que se esqueceu do SafeArea
-   [ ] SE tiver tempo, considerar fazer a organização dos documentos ocorrer no backend via API para evitar um array com todos os documentos na memoria RAM (permitirá paginação). Requer repensar a arquitetura dos documentos
