<!-- 
Author: Wittmann Áron
Date: 2022-06-14

DLPL - A dynamic language processing library.
-->

# Dynamic Language Processing Library
This library provides a simple interface for processing text based on a given formal grammar.

## Features

 - Lexing a given source code based on a provided grammar.

#### Roadmap:

 - Processing the code to a parse tree.
 - Compilig a parse tree back into code.

## Install

The package will be available on pub.dev and released in the packages section, whenever the main goals in the roadmap are achieved.

## Getting started

Create your own grammar using test.gr as a reference.
or use one of the provided grammars from the grammars folder.

*[Antlr's existing grammar(.g4) files](https://github.com/antlr/grammars-v4), can be converted without too much difficulty to the DLPL grammar format.*

## Usage

 - Run tests with `test_and_coverage.sh`.
 - Run the given example with `dart run example/dlpl_example.dart`.

#### Using the ([Lexer](https://github.com/RawEnchilada/dlpl/blob/main/lib/src/parser/lexer.dart)): 
```dart
GrammarTree tree = GrammarTree(File("grammars/test.gr").readAsLinesSync());
Lexer lexer = new Lexer(tree, File("source.lang").readAsStringSync());
Token token = lexer.nextToken();
```

