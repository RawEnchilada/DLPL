

class GrammarTree{
    List<Rule> rules = [];
    List<Rule> _missingReferences = [];

    Result classify(String token){
        int matched = 0;
        Rule? rule;
        int status = Rule.unknown;
        for(var node in rules){
            var got = node.pass(token,this);
            switch(got){
                case Rule.eof:
                    status = Rule.eof;
                    throw Exception("Unexpected end of file");
                case Rule.unknown:
                    break;
                case Rule.ambiguous:
                    matched = 2;
                    break;
                case Rule.found:
                    status = Rule.found;
                    rule = node;
                    matched++;
                    break;
            }
        }
        if(matched == 0){
            status = Rule.unknown;
        }
        if(matched > 1){
            status = Rule.ambiguous;
        }
        return Result(status,rule);
    }

    GrammarTree(String grammar){
        var word = RegExp(r'([a-zA-z])\w+');
        var conditional = RegExp(r'');

        var lines = grammar.split("\n");
        bool isComment = false;
        String nodeName = "";
        String condition = "";
        bool addExpression = false;
        List<String> nodeContent = [];
        for(var line in lines){
            if(line.startsWith("/*")){
                isComment = true;
            }
            else if(isComment && line.startsWith("*/")){
                isComment = false;
            }
            else if(line.startsWith("//")){
                continue;
            }
            else if(isComment){
                continue;
            }
            else if(line.isEmpty){
                continue;
            }
            else{
                var parts = line.split(" ");

                for(var part in parts){
                    if(nodeName == "" && word.hasMatch(part)){
                        nodeName = part;
                    }
                    else if(nodeName != "" && (part == ":" || part == "|") ){
                        addExpression = true;
                    }
                    else if(addExpression && conditional.hasMatch(part)){
                        if(part.startsWith("'")){
                            condition += " "+part;
                        }
                        else{
                            condition += " @"+part;
                        }
                    }
                    else if(addExpression && (part == "\n" || part == "|")){
                        nodeContent.add(condition);
                        addExpression = false;
                        condition = "";
                    }
                    else if(part == ";" && nodeName != "" && nodeContent.isNotEmpty){
                        nodeContent.add(condition);
                        rules.add(Rule(nodeName, nodeContent));
                        nodeName = "";
                        nodeContent = [];
                        addExpression = false;
                        condition = "";
                    }
                    else{
                        throw Exception("Invalid grammar: $line");
                    }
                }
            }
        }
    }
}




class Rule{
    static const int eof = 0;
    static const int unknown = 1;
    static const int ambiguous = 2;
    static const int found = 3;


    final String name; 
    final List<String> conditions; //If ANY of these conditions apply, the rule will be accepted


    Rule(this.name, this.conditions);

    /*
    if the condition starts with @, it is a reference to a rule
    if the condition is within '', it is a regular expression
    */
    int pass(String source,GrammarTree tree){
        int matched = 0;
        for(var condition in conditions){
            //TODO 
            if(condition.startsWith("@")){
                var referenced = tree.rules.firstWhere((rule) => rule.name == condition.substring(1));
                if(referenced.pass(source,tree) == found){
                    matched++;
                }
            }
            else if(condition.startsWith("'")){
                var regex = condition.substring(1,condition.length-1);

                if(RegExp(regex).hasMatch(source)){
                    matched++;
                }
            }

        }
        if(matched == conditions.length){
            return found;
        }
        else{
            return unknown;
        }
    }
}


class Result{
    int status;
    Rule? rule;

    Result(this.status, this.rule);
}