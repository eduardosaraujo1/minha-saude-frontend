# Minha Saúde Frontend

## Necessidades para build/debug

-   [Android Keystore](https://docs.flutter.dev/deployment/android#sign-the-app)
-   [Google Cloud - OAuth Client e Server](https://developer.android.com/identity/sign-in/credential-manager-siwg#set-google)
    -   ClientID e ServerId devem ser definidos em `.env`
    -   [Como gerar a chave SHA-1](https://stackoverflow.com/questions/51845559/generate-sha-1-for-flutter-react-native-android-native-app)
-   Antes de iniciar, execute o comando `dart run build_runner build` ou `dart run build_runner watch`
-   Para iniciar o ambiente, utilize `flutter run --dart-define-from-file=.env`

## Para fazer

-   Transformar estrutura de projetos em [feature-centric](docs/project_structure.md)
-   Inspirando-se na arquitetura de Providers do Riverpod, crie funções que registram no getIt, e leia esses arquivos do `state/get_it.dart`. A única diferença do Riverpod é que dai não tá acoplado no widget tree
-   Corrigir estrutura de temas
-   Criar inicial de lista de documentos
-   Fazer lógica de login com Google (criar um mock do componente que se comunica com o backend)
-   Fazer rota ´/´ direcionar para documentos ou login dependendo do estado de login do usuário
-   Fazer navbar e appbar
-   Fazer tela (display only) de compartilhar, lixeira e configurações de usuário
-   Fazer lógica de organização de documentos (frontend support)
-   Fazer lógica de organização de documentos (backend mock)
-   Fazer lógica de lixeira de documentos (frontend support)
-   Fazer lógica de lixeira de documentos (backend mock)
-   Fazer lógica de compartilhar documentos (frontend support)
-   Fazer lógica de compartilhar documentos (backend mock)
