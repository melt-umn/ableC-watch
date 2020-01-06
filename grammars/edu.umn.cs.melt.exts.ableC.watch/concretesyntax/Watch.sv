grammar edu:umn:cs:melt:exts:ableC:watch:concretesyntax;

imports edu:umn:cs:melt:ableC:concretesyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:host as abs;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction as abs;
imports silver:langutil only ast; 

imports edu:umn:cs:melt:exts:ableC:watch:abstractsyntax;

marking terminal Watch_t 'watch' lexer classes {Keyword, Global};

concrete production watchTypeQualifier_c
top::TypeQualifier_c ::= 'watch'
{
  top.typeQualifiers = abs:foldQualifier([watchQualifier(location=top.location)]);
  top.mutateTypeSpecifiers = [];
}


