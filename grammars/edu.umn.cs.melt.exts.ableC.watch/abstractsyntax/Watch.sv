grammar edu:umn:cs:melt:exts:ableC:watch:abstractsyntax;

imports edu:umn:cs:melt:ableC:abstractsyntax:host;
imports edu:umn:cs:melt:ableC:abstractsyntax:construction;
imports edu:umn:cs:melt:ableC:abstractsyntax:env;
imports edu:umn:cs:melt:ableC:abstractsyntax:injectable as inj;
imports silver:langutil;
imports silver:langutil:pp;

global MODULE_NAME :: String = "edu:umn:cs:melt:exts:ableC:watch";

abstract production watchQualifier
top::Qualifier ::=
{
  top.pp = pp"watch";
  top.mangledName = "watch";
  top.qualIsPositive = true;
  top.qualIsNegative = true;
  top.qualAppliesWithinRef = true;
  top.qualCompat = \qualToCompare::Qualifier ->
    case qualToCompare of
      watchQualifier() -> true
    | _                -> false
    end;
  top.qualIsHost = false;
  top.errors := [];
}

aspect production inj:eqExpr
top::Expr ::= lhs::Expr rhs::Expr
{
  local insertPrint :: (Stmt ::= Expr) =
    mkPrintFunc(lhs);

  runtimeMods <-
    if containsQualifier(watchQualifier(location=builtinLoc(MODULE_NAME)), lhs.typerep)
    then [inj:rhsRuntimeMod(inj:runtimeInsertion(insertPrint))]
    else [];
}

aspect production inj:directCallExpr
top::Expr ::= f::Name a::Exprs
{
  local isQualifiedWatch :: Boolean =
    containsQualifier(watchQualifier(location=bogusLoc()), f.valueItem.typerep);

  local prePrint :: (Stmt ::= [Expr]) = \args::[Expr] ->
    exprStmt(
      directCallExpr(
        name("printf", location=builtinLoc(MODULE_NAME)),
        foldExpr(
          stringLiteral(
              "\"" ++ top.location.unparse ++ ": calling " ++ f.name ++ "(" ++
              implode(",", map(\arg::Expr -> "%d", args)) ++
              ")\\n\"",
            location=builtinLoc(MODULE_NAME)
          ) ::
          map(\arg::Expr -> arg, args)
        ),
        location=builtinLoc(MODULE_NAME)
      )
    );

  local postPrint :: (Stmt ::= [Expr] Expr) = \args::[Expr] result::Expr ->
    exprStmt(
      directCallExpr(
        name("printf", location=builtinLoc(MODULE_NAME)),
        foldExpr(
          stringLiteral(
              "\"" ++ top.location.unparse ++ ": returning " ++ f.name ++ "(" ++
              implode(",", map(\arg::Expr -> "%d", args)) ++
              ") = %d\\n\"",
            location=builtinLoc(MODULE_NAME)
          ) ::
          (map(\arg::Expr -> arg, args) ++ [result])
        ),
        location=builtinLoc(MODULE_NAME)
      )
    );

  preInsertions <-
    if isQualifiedWatch
    then [prePrint]
    else [];

  postInsertions <-
    if isQualifiedWatch
    then [postPrint]
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

