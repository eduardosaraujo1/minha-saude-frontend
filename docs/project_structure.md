# Estrutura de arquivos do projeto

## Estrutura atual

```
C:.
├───lib
│   ├───data                     # Camada de dados (comunicação com API, armazenamento local, etc.)
│   │   ├───auth                 # Autenticação (data sources, repositórios)
│   │   │   ├───repositories     # Implementações concretas dos repositórios
│   │   │   └───sources          # Fontes de dados (API, local storage, etc.)
│   │   ├───profile              # Dados do perfil do usuário
│   │   │   ├───repositories
│   │   │   └───sources
│   │   ├───documents            # Documentos do usuário
│   │   │   ├───repositories
│   │   │   └───sources
│   │   └───shared               # Recursos compartilhados da camada de dados
│   │       └───network          # Configuração de HTTP, interceptores, etc.
│   │
│   ├───domain                   # Regras de negócio e lógica da aplicação
│   │   ├───auth                 # Modelos e interfaces relacionados à autenticação
│   │   │   ├───models           # Modelos de domínio (entidades)
│   │   │   └───repositories     # Interfaces de repositórios
│   │   ├───profile              # Modelos e interfaces do perfil
│   │   │   ├───models
│   │   │   └───repositories
│   │   ├───documents            # Modelos e interfaces de documentos
│   │   │   ├───models
│   │   │   └───repositories
│   │   └───shared               # Modelos e interfaces compartilhados
│   │       ├───models           # Modelos de domínio compartilhados (como User)
│   │       └───interfaces       # Interfaces compartilhadas
│   │
│   ├───presentation             # Interface do usuário (UI)
│   │   ├───auth                 # Telas de autenticação
│   │   │   ├───views            # Telas (login, cadastro, etc.)
│   │   │   └───widgets          # Widgets específicos de autenticação
│   │   ├───profile              # Telas de perfil
│   │   │   ├───views
│   │   │   └───widgets
│   │   ├───documents            # Telas de documentos
│   │   │   ├───views
│   │   │   └───widgets
│   │   └───shared               # Widgets compartilhados (botões, inputs, etc.)
│   │       ├───widgets          # Widgets reutilizáveis
│   │       └───theme            # Definições de tema
│   │
│   ├───providers                # Gerenciamento de estado e injeção de dependências
│   │   ├───auth                 # Providers relacionados à autenticação
│   │   ├───profile              # Providers relacionados ao perfil
│   │   └───init.dart            # Inicialização de todos os providers
│   │
│   ├───routes                   # Configuração de rotas (go_router)
│   │
│   └───main.dart               # Ponto de entrada da aplicação
│
└───test
    ├───data                    # Testes para a camada de dados
    │   ├───auth
    │   └───profile
    ├───domain                  # Testes para a camada de domínio
    │   ├───auth
    │   └───profile
    ├───presentation            # Testes para a camada de apresentação
    │   ├───auth
    │   └───profile
    └───mocks                   # Mocks para testes
```

## Principais diretórios e suas responsabilidades

### Camada de dados (`lib/data`)

Responsável por implementar a comunicação com fontes externas de dados, como APIs RESTful, bancos de dados locais, ou serviços de armazenamento. Implementa as interfaces definidas na camada de domínio.

### Camada de domínio (`lib/domain`)

Contém a lógica de negócios da aplicação, modelos e interfaces de repositórios. Esta camada é independente de qualquer framework e define as regras do negócio.

### Camada de apresentação (`lib/presentation`)

Contém todos os componentes de UI, incluindo telas, widgets e lógica de apresentação.

### Providers (`lib/providers`)

Gerencia o estado da aplicação e a injeção de dependências. O arquivo `init.dart` é responsável por inicializar todos os providers.

### Configuração (`lib/config`)

Contém arquivos de configuração da aplicação, como rotas, temas e constantes.
