
///A set of rules parsed from a grammar file, that can be used to identify tokens matching the language.
class GrammarTree{
    List<_Rule> rules = [];

    /// Parse a grammar (.gr) file and create a GrammarTree object.
    GrammarTree(List<String> lines){
        final word = RegExp(r"([a-zA-z])\w+");
        final conditional = RegExp(r"([^;|:]|\'.+\')");

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
                        rules.add(_Rule(nodeName, nodeContent, priority: priority));
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
    
    ///Return all rules in the tree that match [token] as a [Result].
    Result classify(String token){
        int matched = 0;
        List<_Rule> rulelist = [];
        int status = Result.unknown;
        for(var node in rules){
            var got = node.pass(token,this);
            if(got == token.length){
                status = Result.found;
                rulelist.add(node);
                matched++;
            }
            if(node.priority == 1 && status == Result.found){
                return Result(status, rulelist);
            }
        }
        if(matched == 0){
            status = Result.unknown;
        }
        if(matched > 1){
            status = Result.ambiguous;
        }
        return Result(status,rulelist);
    }
}



///A set of regular expressions to match a token.
class _Rule{
    final String name; 
    ///Used for matching keywords, do not set manually.
    final int priority;
    final List<String> conditions; //If ANY of these conditions apply, the rule will be accepted


    _Rule(this.name, this.conditions, {this.priority = 0}){
        //sort conditions to regex first
        conditions.sort((a,b){
            if(a.startsWith("'")) {
              return -1;
            } else {
              return 1;
            }
        });
    }

    /*
        if the condition starts with @, it is a reference to a rule
        if the condition is within '', it is a regular expression
    */

    ///Check if the [token] matches this rule, using references from [tree]
    ///
    ///Return the number of characters matched
    int pass(String token,GrammarTree tree){
        int matchedLengthToReturn = 0;
        for(var condition in conditions){
            int matchedLength = 0;
            int matchedParts = 0;
            var parts = condition.split(' ');
            String sourceCopy = token;
            for(var part in parts){
                bool partValid = false;
				if(part.startsWith("'")){
                    var regex = part.substring(1,part.length-1);
                    var result = RegExp(regex).firstMatch(sourceCopy);
                    if(result != null){
                        sourceCopy = sourceCopy.substring(result.end);
                        int spaces = sourceCopy.length;
                        sourceCopy = sourceCopy.trimLeft();
                        spaces = spaces - sourceCopy.length;
                        matchedLength += result.end+spaces;
                        matchedParts++;
                        partValid = true;
                    }
                }
                else if(part.startsWith("@")){
                    var referenced = tree.rules.firstWhere((rule) => rule.name == part.substring(1));
                    int resultEnd = referenced.pass(sourceCopy,tree);
                    if(resultEnd > 0){
                        sourceCopy = sourceCopy.substring(resultEnd);
                        int spaces = sourceCopy.length;
                        sourceCopy = sourceCopy.trimLeft();
                        spaces = spaces - sourceCopy.length;
                        matchedLength += resultEnd+spaces;
                        matchedParts++;
                        partValid = true;
                    }
                }
                if(!partValid){
                    break;
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

///A result of a classification, containing the status and the list of rules that matched.
class Result{
    static const int eof = 0;
    static const int unknown = 1;
    static const int ambiguous = 2;
    static const int found = 3;

    ///The status is one of the following:
    /// - [eof] (0) - The token was at the end of the file.
    /// - [unknown] (1) - The token was not recognized.
    /// - [ambiguous] (2) - The token was recognized, but there were multiple rules that matched.
    /// - [found] (3) - The token was recognized, and there was only one rule that matched.
    int status;
    ///The list of rules that matched.
    List<_Rule> rules;

    Result(this.status, this.rules);
}