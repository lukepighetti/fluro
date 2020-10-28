[English](../../../fluro/README.md) | [Português](./README.md)

<img src="https://storage.googleapis.com/product-logos/logo_fluro.png" width="220">
<br/><br/>

O roteador mais brilhante, moderno e legal para o Flutter.

[![Versão](https://img.shields.io/github/v/release/lukepighetti/fluro?label=version)](https://pub.dev/packages/fluro)
[![Status de construção](https://github.com/lukepighetti/fluro/workflows/build/badge.svg)](https://github.com/lukepighetti/fluro/actions)

## Funcionalidade

- Navegação simples de rotas
- Funções manipuladoras (mapeie para uma função ao invés de uma rota)
- Parâmetros coringa de comparação
- Tranformação de parâmetros de busca
- Transições comuns embutidas
- Criação simples de transições customizadas

## Projeto de exemplo

Há um projeto muito bom de exemplo na pasta `example`. Confira. De outra forma, continue lendo para começar e rodar.

## Começando

Primeiro, você deve definir um novo objeto `FluroRouter`, inicializando-o assim:

```dart
final router = FluroRouter();
```

Pode ser conveniente para você armazenar o roteador globalmente/estaticamente, assim você pode acessar o roteador em outras áreas da sua aplicação.

Após instanciado o roteador, você irá precisar definir suas rotas e seus manipuladores de rotas:

```dart
var usersHandler = Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
  return UsersScreen(params["id"][0]);
});

void defineRoutes(FluroRouter router) {
  router.define("/users/:id", handler: usersHandler);

  // também é possível definir a transição da rota, para usar
  // router.define("users/:id", handler: usersHandler, transitionType: TransitionType.inFromLeft);
}
```

No exemplo acima, o roteador irá interceptar uma rota como
`/users/1234` e rotear a aplição para `UsersScreen`, passando
o valor `1234` como parâmetro dessa tela.

## Navegação

Você pode usar `FluroRouter` com o parâmetro `MaterialApp.onGenerateRoute` 
através do `FluroRouter.generator`. Para fazer isso, passe a referência da função para o parâmetro `onGenerate` como: `onGenerateRoute: router.generator`.

Você pode usar então `Navigator.push` e o mecanismo de navegação do Flutter irá combinar as rotas para você.

Você também pode mudar para uma rota manualmente. Para fazer isso:

```dart
router.navigateTo(context, "/users/1234", transition: TransitionType.fadeIn);
```

## Argumentos de classe

Não quer usar strings para parâmetros? Não se preocupe.

Após empilhar uma rota com um `RouteSettings` customizado, você pode usar a extensão `BuildContext.settings` para extrair as configurações. Normalmente isso poderia ser feito no `Handler.handlerFunc`, então você pode passar `RouteSettings.arguments` para os seus widgets de tela.

```dart
/// Empilhe uma rota com um RouteSettings customizado se você não quiser usar parâmetros de caminho
FluroRouter.appRouter.navigateTo(
  context,
  'home',
  routeSettings: RouteSettings(
    arguments: MyArgumentsDataClass('foo!'),
  ),
);

/// Extraia os argumentos usando [BuildContext.settings.arguments] ou [BuildContext.arguments] para abreviação
var homeHandler = Handler(
  handlerFunc: (context, params) {
    final args = context.settings.arguments as MyArgumentsDataClass;

    return HomeComponent(args);
  },
);
```
