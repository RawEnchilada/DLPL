

class GrammarTree{
    List<Rule> rules = [];

    GrammarTree(String grammar){
        var word = RegExp(r"([a-zA-z])\w+");
        var conditional = RegExp(r"([^;|:]|\'.+\')");

        var lines = grammar.split("\n");
        bool isComment = false;
        String nodeName = "";
        String condition = "";
        int priority = 0;
        bool addExpression = false;
        List<String> nodeContent = [];
        int index = 0;
        for(var line in lines){
            index++;
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
                var parts = line.trim().split(" ");

                for(var part in parts){
                    if(part == "") {
                        continue;
                    } 
                    else if(part == "keyword"){
                        priority = 1;
                    }
                    else if(nodeName == "" && word.hasMatch(part)){
                        nodeName = part;
                    }
                    else if(addExpression == false && nodeName != "" && (part == ":" || part == "|") ){
                        addExpression = true;
                    }
                    else if(addExpression && conditional.hasMatch(part)){
                        if(condition.isNotEmpty)condition+=" ";
                        if(part.startsWith("'")){
                            condition += part;
                        }
                        else{
                            condition += "@"+part;
                        }
                    }
                    else if(addExpression && (part == "\n" || part == "|")){
                        nodeContent.add(condition);
                        condition = "";
                    }
                    else if(part.contains(";") && nodeName != "" && (nodeContent.isNotEmpty || condition != "")){
                        nodeContent.add(condition);
                        rules.add(Rule(nodeName, nodeContent, priority: priority));
                        nodeName = "";
                        nodeContent = [];
                        addExpression = false;
                        condition = "";
                        priority = 0;
                    }
                    else{
                        String details = "";
                        for(var p in parts){
                            if(p == part){
                                details += "\x1B[31m"+part+"\x1B[0m";
                            }
                            else{
                                details += p;
                            }
                            details += " ";
                        }
                        throw Exception("Invalid grammar at line $index : \"$details\"");
                    }
                }
            }
        }
    }
    

    Result classify(String token){
        int matched = 0;
        List<Rule> rulelist = [];
        int status = Rule.unknown;
        for(var node in rules){
            var got = node.pass(token,this);
            if(got == token.length){
                status = Rule.found;
                rulelist.add(node);
                matched++;
            }
            if(node.priority == 1 && status == Rule.found){
                return Result(status, rulelist);
            }
        }
        if(matched == 0){
            status = Rule.unknown;
        }
        if(matched > 1){
            status = Rule.ambiguous;
        }
        return Result(status,rulelist);
    }
}




class Rule{
    static const int eof = 0;
    static const int unknown = 1;
    static const int ambiguous = 2;
    static const int found = 3;


    final String name; 
    final int priority;
    final List<String> conditions; //If ANY of these conditions apply, the rule will be accepted


    Rule(this.name, this.conditions, {this.priority = 0});

    /*
    if the condition starts with @, it is a reference to a rule
    if the condition is within '', it is a regular expression
    */
    int pass(String source,GrammarTree tree){
        int matchedLengthToReturn = 0;
        for(var condition in conditions){
            int matchedLength = 0;
            int matchedParts = 0;
            var parts = condition.split(' ');
            String sourceCopy = source;
            for(var part in parts){
                if(part.startsWith("@")){
                    //TODO implement null or more references;
                    var referenced = tree.rules.firstWhere((rule) => rule.name == part.substring(1));
                    int resultEnd = referenced.pass(sourceCopy,tree);
                    if(resultEnd > 0){
                        sourceCopy = sourceCopy.substring(resultEnd);
                        int spaces = sourceCopy.length;
                        sourceCopy = sourceCopy.trimLeft();
                        spaces = spaces - sourceCopy.length;
                        matchedLength += resultEnd+spaces;
                        matchedParts++;
                    }
                }
                else if(part.startsWith("'")){
                    var regex = part.substring(1,part.length-1);
                    var result = RegExp(regex).firstMatch(sourceCopy);
                    if(result != null){
                        sourceCopy = sourceCopy.substring(result.end);
                        int spaces = sourceCopy.length;
                        sourceCopy = sourceCopy.trimLeft();
                        spaces = spaces - sourceCopy.length;
                        matchedLength += result.end+spaces;
                        matchedParts++;
                    }
                }
            }
            if(matchedParts == parts.length){
                matchedLengthToReturn = matchedLength;
                break;
            }
        }
        return matchedLengthToReturn;
    }
}


class Result{
    int status;
    List<Rule> rules;

    Result(this.status, this.rules);
}