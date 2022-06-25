import 'dart:io';
import 'package:dlpl/src/language_definition/grammar_tree.dart';
import 'package:dlpl/src/parser/lexer.dart';
import 'package:test/test.dart';


void main() {

    group('Parse tree test: ', (){
        GrammarTree? parseTree;

        test('Parsing grammar', (){
            File grammar = File("test.gr");
            parseTree = GrammarTree(grammar.readAsStringSync());
            expect(parseTree!.rules.length, 3);
        });


        test('Parsing a word',(){
            String source = "word";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.found);
            expect(result.rules[0].name, "word");
        });

        test('Parsing a type',(){
            String source = "int";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.found);
            expect(result.rules[0].name, "type");
        });

        test('Parsing a variable',(){
            String source = "int word;";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.found);
            expect(result.rules[0].name, "variable");
        });

        test('Parsing an unknown token',(){
            String source = "ő";
            Result result = parseTree!.classify(source);
            expect(result.status, Rule.unknown);
        });
    });

    group("Lexer test:", (){
        GrammarTree tree = GrammarTree(File("test.gr").readAsStringSync());

        test("Tokenize small sample", (){
            Lexer lexer = Lexer(tree,"int whole;\nchar letter;");
            Token token = lexer.nextToken();
            expect(token.type,"type");
            expect(token.content,"int");
            token = lexer.nextToken();
            expect(token.type,"word");
            expect(token.content,"whole");
        });

        
    });
}
