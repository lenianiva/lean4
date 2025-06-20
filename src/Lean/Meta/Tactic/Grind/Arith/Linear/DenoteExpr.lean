/-
Copyright (c) 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Lean.Meta.Tactic.Grind.Arith.Linear.Util
import Lean.Meta.Tactic.Grind.Arith.Linear.Var

namespace Lean.Meta.Grind.Arith.Linear
/-!
Helper functions for converting reified terms back into their denotations.
-/

variable [Monad M] [MonadGetStruct M]

def _root_.Lean.Grind.Linarith.Poly.denoteExpr (p : Poly) : M Expr := do
  match p with
  | .nil => return (← getStruct).zero
  | .add k x p => go p (← denoteTerm k x)
where
  denoteTerm (k : Int) (x : Var) : M Expr := do
    if k == 1 then
      return (← getStruct).vars[x]!
    else
      return mkApp2 (← getStruct).hmulFn (mkIntLit k) (← getStruct).vars[x]!

  go (p : Poly) (acc : Expr) : M Expr := do
    match p with
    | .nil => return acc
    | .add k m p => go p (mkApp2 (← getStruct).addFn acc (← denoteTerm k m))

def _root_.Lean.Grind.Linarith.Expr.denoteExpr (e : LinExpr) : M Expr := do
  go e
where
  go : LinExpr → M Expr
  | .zero => return (← getStruct).zero
  | .var x => return (← getStruct).vars[x]!
  | .add a b => return mkApp2 (← getStruct).addFn (← go a) (← go b)
  | .sub a b => return mkApp2 (← getStruct).subFn (← go a) (← go b)
  | .mul k a => return mkApp2 (← getStruct).hmulFn (mkIntLit k) (← go a)
  | .neg a => return mkApp (← getStruct).negFn (← go a)

private def mkEq (a b : Expr) : M Expr := do
  let s ← getStruct
  return mkApp3 (mkConst ``Eq [s.u.succ]) s.type a b

def EqCnstr.denoteExpr (c : EqCnstr) : M Expr := do
  mkEq (← c.p.denoteExpr) (← getStruct).ofNatZero

def DiseqCnstr.denoteExpr (c : DiseqCnstr) : M Expr := do
  return mkNot (← mkEq (← c.p.denoteExpr) (← getStruct).ofNatZero)

private def denoteIneq (p : Poly) (strict : Bool) : M Expr := do
  if strict then
    return mkApp2 (← getStruct).ltFn (← p.denoteExpr) (← getStruct).ofNatZero
  else
    return mkApp2 (← getStruct).leFn (← p.denoteExpr) (← getStruct).ofNatZero

def IneqCnstr.denoteExpr (c : IneqCnstr) : M Expr := do
  denoteIneq c.p c.strict

def NotIneqCnstr.denoteExpr (c : NotIneqCnstr) : M Expr := do
  return mkNot (← denoteIneq c.p c.strict)

private def denoteNum (k : Int) : LinearM Expr := do
  return mkApp2 (← getStruct).hmulFn (mkIntLit k) (← getOne)

def _root_.Lean.Grind.CommRing.Power.denoteAsIntModuleExpr (pw : Grind.CommRing.Power) : LinearM Expr := do
  let x := (← getRing).vars[pw.x]!
  if pw.k == 1 then
    return x
  else
    return mkApp2 (← getRing).powFn x (toExpr pw.k)

def _root_.Lean.Grind.CommRing.Mon.denoteAsIntModuleExpr (m : Grind.CommRing.Mon) : LinearM Expr := do
  match m with
  | .unit => getOne
  | .mult pw m => go m (← pw.denoteAsIntModuleExpr)
where
  go (m : Grind.CommRing.Mon) (acc : Expr) : LinearM Expr := do
    match m with
    | .unit => return acc
    | .mult pw m => go m (mkApp2 (← getRing).mulFn acc (← pw.denoteAsIntModuleExpr))

def _root_.Lean.Grind.CommRing.Poly.denoteAsIntModuleExpr (p : Grind.CommRing.Poly) : LinearM Expr := do
  match p with
  | .num k => denoteNum k
  | .add k m p => go p (← denoteTerm k m)
where
  denoteTerm (k : Int) (m : Grind.CommRing.Mon) : LinearM Expr := do
    if k == 1 then
      m.denoteAsIntModuleExpr
    else
      return mkApp2 (← getStruct).hmulFn (mkIntLit k) (← m.denoteAsIntModuleExpr)

  go (p : Grind.CommRing.Poly) (acc : Expr) : LinearM Expr := do
    match p with
    | .num 0 => return acc
    | .num k => return mkApp2 (← getStruct).addFn acc (← denoteNum k)
    | .add k m p => go p (mkApp2 (← getStruct).addFn acc (← denoteTerm k m))

end Lean.Meta.Grind.Arith.Linear
