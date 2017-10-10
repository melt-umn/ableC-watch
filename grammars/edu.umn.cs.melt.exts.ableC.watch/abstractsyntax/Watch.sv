grammar edu:umn:cs:melt:exts:ableC:watch:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports silver:langutil;
imports silver:langutil:pp;

global MODULE_NAME :: String = "edu:umn:cs:melt:exts:ableC:watch";

abstract production watchQualifier
top::Qualifier ::=
{
  top.pp = pp"watch";
  top.mangledName = "watch";
  top.qualIsPositive = false;
  top.qualIsNegative = false;
  top.qualAppliesWithinRef = true;
  top.qualCompat = \qualToCompare::Qualifier ->
    case qualToCompare of
      watchQualifier() -> true
    | _                -> false
    end;
  top.qualIsHost = false;
  top.errors := [];
}

aspect production assignOp
top::BinOp ::= op::AssignOp
{
  local insertPrint :: (Stmt ::= Expr) =
    mkPrintFunc(op.lop);

  top.lhsRhsRuntimeMods <-
    if containsQualifier(watchQualifier(location=builtinLoc(MODULE_NAME)), op.lop.typerep)
    then [rhsRuntimeMod(runtimeInsertion(insertPrint))]
    else [];
}

function mkPrintFunc
(Stmt ::= Expr) ::= lhs::Decorated Expr
{
  return
    \tmpRhs :: Expr ->
      exprStmt(
        directCallExpr(
          name("printf", location=builtinLoc(MODULE_NAME)),
          foldExpr([
            txtExpr("\"" ++ lhs.location.unparse ++
              ": " ++ show(80, lhs.pp) ++ " = %d\\n\"", location=builtinLoc(MODULE_NAME)),
            tmpRhs
          ]),
          location=builtinLoc(MODULE_NAME)
        )
      );
}

