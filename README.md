# Cálculo Numérico

Um aplicativo desenvolvido em **Flutter** para resolver e demonstrar diversos métodos numéricos ensinados em disciplinas de Cálculo Numérico. O aplicativo permite ao usuário resolver problemas matemáticos através de uma interface interativa e amigável.

## 🚀 Funcionalidades (Métodos Implementados)

O projeto engloba a implementação de diversos algoritmos matemáticos divididos nas seguintes categorias:

### Zeros de Funções
*   **Método da Bisseção**
*   **Método de Newton-Raphson**

### Sistemas Lineares
*   **Triangulação de Gauss** (Eliminação de Gauss)
*   **Método de Gauss-Seidel**

### Interpolação Polinomial
*   **Interpolação Polinomial (Resolução por Sistema Linear)**
*   **Forma de Lagrange**
*   **Forma de Newton**

### Ajuste de Curvas
*   **Método dos Mínimos Quadrados**

### Integração Numérica
*   **Regra dos Trapézios**
*   **Regra 1/3 de Simpson**
*   **Regra 3/8 de Simpson**

## 🛠️ Tecnologias e Pacotes Utilizados

*   [Flutter](https://flutter.dev/) - SDK de desenvolvimento UI
*   [Dart](https://dart.dev/) - Linguagem de programação principal
*   [function_tree](https://pub.dev/packages/function_tree) - Para parsing e avaliação de expressões e funções matemáticas fornecidas pelo usuário em formato de string.
*   [fraction](https://pub.dev/packages/fraction) - Para operações matemáticas e representação de resultados na forma de frações.
*   [flutter_math_fork](https://pub.dev/packages/flutter_math_fork) - Para renderização de equações matemáticas no estilo LaTeX.

## 📱 Estrutura do Projeto

A arquitetura principal está localizada na pasta `lib/`:
*   `core/`: Componentes visuais reutilizáveis em toda a aplicação (ex: botões, cards de métodos, diálogos de informação).
*   `modules/home/`: Contém a tela inicial (`home_view.dart`) responsável pela navegação principal.
*   `modules/metodos/`: Contém as telas e lógicas específicas (algoritmos) para cada um dos métodos numéricos.

## 📥 Download / Instalação

Você pode baixar a versão mais recente do aplicativo pronta para uso diretamente na aba **Releases** deste repositório no GitHub.

## 💻 Como executar o projeto

1.  Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado corretamente no seu ambiente.
2.  Faça o clone do repositório ou efetue o download do código-fonte.
3.  Abra o terminal na pasta raiz do projeto e instale todas as dependências:
    ```bash
    flutter pub get
    ```
4.  Execute o aplicativo (selecione um emulador Android/iOS ou dispositivo físico conectado):
    ```bash
    flutter run
    ```

## 💡 Dica de Uso
O aplicativo possui uma opção de **Valores de Exemplo** na barra superior da tela inicial. Quando ativada, os campos de entrada dos métodos numéricos serão preenchidos automaticamente com dados pré-definidos para facilitar a demonstração e os testes rápidos.
