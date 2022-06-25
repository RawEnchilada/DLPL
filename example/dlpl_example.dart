import 'dart:io';
import 'package:dlpl/src/language_definition/grammar_tree.dart';

void main() {
    File grammar = File("test.gr");
    var parseTree = GrammarTree(grammar.readAsStringSync());
    String source = "int something;";
    print("input: $source");
    Result result = parseTree.classify(source);
    String res = "";
    switch(result.status){
        case 0:
            res = "EOF";
            break;
        case 1:
            res = "Unknown";
            break;
        case 2:
            res = "Ambiguous";
            break;
        case 3:
            res = "Found";
            break;

    }
    print(res);
    for (var element in result.rules) {print(element.name);}
}
