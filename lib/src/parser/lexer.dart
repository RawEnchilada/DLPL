import 'package:dlpl/src/language_definition/grammar_tree.dart';

class Lexer{

    final GrammarTree _grammarTree;
    String _content = "";

    Lexer(this._grammarTree, this._content);

    String _peek({int num = 0})  {
        return _content.substring(0, num);
    }

    String _consume({int num = 0}) {
        var token = _content.substring(0, num);
        _content = _content.substring(num+1);
        return token;
    }

    Token nextToken() {
        int tokenLength = 1;
        Result? result;
        if(_peek() == "\0")return Token("\0","EOF");

        //find the next substring that has a space or newline after it
        String peek = _peek(num: tokenLength);
        while(tokenLength <= _content.length && peek[peek.length-1] != " " && peek[peek.length-1] != "\n"){
            tokenLength++;
            peek = _peek(num: tokenLength);
        }
        tokenLength = peek.length-1;//remove the last space or newline

        //trim the last character of the substring until we find a matching rule
        while(tokenLength < _content.length-1){
            result = _grammarTree.classify(peek);

            if(result.status == Rule.unknown || result.status == Rule.ambiguous){
                tokenLength--;
                peek = _peek(num: tokenLength);
            }
            else{
                break;
            }
        }


        if(result!.status == Rule.ambiguous){
            String msg = "Unable to parse token - Ambiguous token: $peek\n\tValid rules:\n";
            for (var e in result.rules) {
                msg += "\t${e.name}\n";
            }
            throw Exception(msg);
        }
        if(result.status == Rule.unknown){
            throw Exception("Unable to parse token - Unknown token: ${_peek(num: tokenLength)}\n");
        }
        if(tokenLength == _content.length-1){
            throw Exception("Unable to parse token - Unexpected end of file\n");
        }
        return Token(_consume(num: tokenLength),result.rules[0].name);
    }

}

class Token{
    late final String type;
    final String content;

    Token(this.content, this.type);

}