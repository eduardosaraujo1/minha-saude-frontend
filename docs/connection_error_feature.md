# Funcionalidade de Erro de Conexão no Startup

## Visão Geral

Esta funcionalidade detecta quando o app não consegue se comunicar com o backend durante o startup (especificamente na chamada `auth/status`) e exibe uma tela dedicada para o usuário tentar reconectar ou continuar offline.

## Como Funciona

### 1. Detecção de Erro de Conexão

-   Durante o startup do app, o `AuthRepository` tenta verificar o status de autenticação com o servidor via `getAuthStatus()`
-   Se uma `ConnectionException` for lançada, ela é capturada no `setupLocator()`
-   O erro é registrado no `AppStateManager` global
-   Um `AuthRepository` offline é criado para manter a funcionalidade local

### 2. Redirecionamento Automático

-   O `GoRouter` verifica o estado de conexão antes de qualquer navegação
-   Se houver um erro de startup, redireciona automaticamente para `/connection-error`
-   Esta verificação tem prioridade sobre as verificações de autenticação normais

### 3. Tela de Erro de Conexão

A `ConnectionErrorView` oferece duas opções ao usuário:

#### Tentar Novamente

-   Recarrega o cache do `AuthRepository`
-   Limpa o erro de startup no `AppStateManager`
-   Navega para a tela apropriada baseada no estado de autenticação

#### Continuar Offline

-   Limpa o erro de startup
-   Navega diretamente para a tela de login
-   Permite uso offline limitado

## Arquivos Modificados/Criados

### Novos Arquivos

-   `lib/app/data/shared/exceptions/connection_exception.dart` - Exceção específica para erros de conexão
-   `lib/app/data/shared/managers/app_state_manager.dart` - Gerenciador de estado global da aplicação
-   `lib/app/presentation/shared/views/connection_error_view.dart` - Tela de erro de conexão

### Arquivos Modificados

-   `lib/app/data/auth/services/auth_remote_service.dart` - Agora lança `ConnectionException`
-   `lib/app/data/auth/repositories/auth_repository.dart` - Propaga erros de conexão durante startup
-   `lib/app/di/get_it.dart` - Captura `ConnectionException` e configura estado offline
-   `lib/app/router/go_router.dart` - Verifica estado de conexão e redireciona

## Como Testar

### Testar Erro de Conexão

No arquivo `auth_remote_service.dart`, mantenha o código atual que retorna erro:

```dart
return Future.delayed(
  Duration(seconds: 2),
  () => Result.error(ConnectionException("Não foi possível conectar ao servidor")),
);
```

### Testar Sucesso

No arquivo `auth_remote_service.dart`, comente as linhas de erro e descomente:

```dart
final result = AuthStatusResponse(isRegistered: false);
return Future.delayed(Duration(seconds: 1), () => Result.success(result));
```

## Comportamento Esperado

### Cenário 1: Erro de Conexão no Startup

1. App inicia
2. Tenta verificar status de auth com servidor
3. Falha na conexão
4. Usuário é redirecionado para tela de erro de conexão
5. Usuário pode tentar novamente ou continuar offline

### Cenário 2: Conexão Bem-sucedida

1. App inicia
2. Verifica status de auth com servidor
3. Conecta com sucesso
4. Usuário é redirecionado para tela apropriada (login/tos/home)

## Notas Importantes

-   Esta funcionalidade só é ativada no startup do app
-   Erros de conexão durante uso normal não disparam esta tela (conforme solicitado)
-   O estado offline é temporário - ao tentar novamente, o app volta ao modo online
-   A funcionalidade é retrocompatível e não afeta fluxos existentes
