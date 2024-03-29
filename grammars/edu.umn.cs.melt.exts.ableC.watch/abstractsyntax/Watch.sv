grammar edu:umn:cs:melt:exts:ableC:watch:abstractsyntax;

imports edu:umn:cs:melt:exts:ableC:string:abstractsyntax;
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
    \tmpRhs :: Expr ->
      exprStmt(
        directCallExpr(
          name("printf"),
          foldExpr([
            stringLiteral(
              "\"" ++ getParsedOriginLocationOrFallback(lhs).unparse ++
              ": " ++ show(80, lhs.pp) ++ " = %s\\n\""
            ),
            showExprText(tmpRhs)
          ])
        )
      );

  runtimeMods <-
    if containsQualifier(watchQualifier(), lhs.typerep)
    then [inj:rhsRuntimeMod(inj:runtimeInsertion(insertPrint))]
    else [];
}

aspect production inj:callExpr
top::Expr ::= f::Expr a::Exprs
{
  local isQualifiedWatch :: Boolean =
    containsQualifier(watchQualifier(), f.typerep);

  local prePrint :: (Stmt ::= Decorated Exprs) = \args::Decorated Exprs ->
    exprStmt(
      directCallExpr(
        name("printf"),
        foldExpr(
          stringLiteral(
              "\"" ++ getParsedOriginLocationOrFallback(top).unparse ++ ": calling " ++ show(80, f.pp) ++ "(" ++
              implode(",", map(\i::Integer -> "%s", range(0, exprsLength(args)))) ++
              ")\\n\""
          ) :: showExprs(args)
        )
      )
    );

  local postPrint :: (Stmt ::= Decorated Exprs  Decorated Expr) =
    \args::Decorated Exprs  result::Decorated Expr ->
      exprStmt(
        directCallExpr(
          name("printf"),
          foldExpr(
            stringLiteral(
                "\"" ++ getParsedOriginLocationOrFallback(top).unparse ++ ": returning " ++ show(80, f.pp) ++ "(" ++
                implode(",", map(\i::Integer -> "%s", range(0, exprsLength(args)))) ++
                ") = %s\\n\""
            ) :: (showExprs(args) ++ [showExprText(new(result))])
          )
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

function showExprs
[Expr] ::= es::Decorated Exprs
{
  return
    case es of
      consExpr(h, t) -> showExprText(new(h)) :: showExprs(t)
    | nilExpr() -> []
    end;
}

function showExprText
Expr ::= e::Expr
{
  return
    memberString(
      showExpr(e),
      false,
      name("text")
    );
}

function exprsLength
Integer ::= es::Decorated Exprs
{
  return
    case es of
      consExpr(_, t) -> 1 + exprsLength(t)
    | nilExpr() -> 0
    end;
}

function range
[Integer] ::= n1::Integer n2::Integer
{
  return if n1 < n2 then n1 :: range(n1+1, n2) else [];
}

