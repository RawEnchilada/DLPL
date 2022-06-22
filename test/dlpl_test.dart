import 'dart:io';
import 'dart:math';
import 'package:dlpl/dlpl.dart';
import 'package:dlpl/src/language_definition/grammar_tree.dart';
import 'package:test/test.dart';


void main() {

    group('Parse tree tests', (){
        GrammarTree? parseTree;

        test('Parsing grammar', (){
            File grammar = File("test.gr");
            parseTree = GrammarTree(grammar.readAsStringSync());
            expect(parseTree!.rules.length, 4);
        });

        test('Parsing a letter',(){
            String source = "w";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.ambiguous);
        });

        test('Parsing a word',(){
            String source = "word";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.found);
            expect(result.rule!.name, "word");
        });

        test('Parsing a type',(){
            String source = "int";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.ambiguous);
        });

        test('Parsing a variable',(){
            String source = "int word;";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.found);
            expect(result.rule!.name, "variable");
        });

        test('Parsing an unknown token',(){
            String source = "ő";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.unknown);
        });
    });
}
