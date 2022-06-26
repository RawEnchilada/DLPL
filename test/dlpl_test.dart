import 'dart:io';
import 'package:dlpl/src/language_definition/grammar_tree.dart';
import 'package:dlpl/src/parser/lexer.dart';
import 'package:test/test.dart';


void main() {

    group('Grammar tree test: ', (){
        GrammarTree? grammarTree;

        test('Parsing grammar', (){
            File grammar = File("grammars/test.gr");
            grammarTree = GrammarTree(grammar.readAsLinesSync());
            int actual = 0;
            for(var line in grammar.readAsLinesSync()){
                if(line.contains(" ;")){
                    actual++;
                }
            }
            expect(grammarTree!.rules.length, actual);
        });


        test('Parsing a word',(){
            String source = "word";
            Result result = grammarTree!.classify(source);
            expect(result.status, Result.found);
            expect(result.rules[0].name, "word");
        });

        test('Parsing a type',(){
            String source = "int";
            Result result = grammarTree!.classify(source);
            expect(result.status, Result.found);
            expect(result.rules[0].name, "type");
        });

        test('Parsing a variable',(){
            String source = "int word;";
            Result result = grammarTree!.classify(source);
            expect(result.status, Result.found);
            expect(result.rules[0].name, "variable");
        });

        test('Parsing an unknown token',(){
            String source = "ő";
            Result result = grammarTree!.classify(source);
            expect(result.status, Result.unknown);
        });

        test('Parsing a parameters declaration',(){
            String source = "int a, int b";
            Result result = grammarTree!.classify(source);
            expect(result.status, Result.found);
            expect(result.rules[0].name, "parameters_dec");
        });

        test('Parsing a function declaration',(){
            String source = "int a(int b, int c)";
            Result result = grammarTree!.classify(source);
            expect(result.status, Result.found);
            expect(result.rules[0].name, "function_dec");
        });
    });

    group("Lexer test:", (){
        GrammarTree tree = GrammarTree(File("grammars/test.gr").readAsLinesSync());

        test("Tokenize variables", (){
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
