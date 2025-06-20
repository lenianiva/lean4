/-
Copyright (c) 2025 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Init.Grind.CommRing.Poly
import Lean.Meta.Tactic.Grind.Arith.CommRing.Reify
import Lean.Meta.Tactic.Grind.Arith.CommRing.DenoteExpr
import Lean.Meta.Tactic.Grind.Arith.Linear.Var
import Lean.Meta.Tactic.Grind.Arith.Linear.StructId
import Lean.Meta.Tactic.Grind.Arith.Linear.Reify
import Lean.Meta.Tactic.Grind.Arith.Linear.DenoteExpr

namespace Lean.Meta.Grind.Arith.Linear

def isLeInst (struct : Struct) (inst : Expr) : Bool :=
  isSameExpr struct.leFn.appArg! inst
def isLtInst (struct : Struct) (inst : Expr) : Bool :=
  isSameExpr struct.ltFn.appArg! inst

def IneqCnstr.assert (c : IneqCnstr) : LinearM Unit := do
  trace[grind.linarith.assert] "{← c.denoteExpr}"
  -- TODO

def NotIneqCnstr.assert (c : NotIneqCnstr) : LinearM Unit := do
  trace[grind.linarith.assert] "{← c.denoteExpr}"
  -- TODO

def propagateCommRingIneq (e : Expr) (lhs rhs : Expr) (strict : Bool) (eqTrue : Bool) : LinearM Unit := do
  let some lhs ← withRingM <| CommRing.reify? lhs (skipVar := false) | return ()
  let some rhs ← withRingM <| CommRing.reify? rhs (skipVar := false) | return ()
  if eqTrue then
    let p' := (lhs.sub rhs).toPoly
    let lhs' ← p'.denoteAsIntModuleExpr
    let some lhs' ← reify? lhs' (skipVar := false) | return ()
    let p := lhs'.norm
    let c : IneqCnstr := { p, strict, h := .coreCommRing e lhs rhs lhs' }
    c.assert
  else if (← isLinearOrder) then
    let p' := (rhs.sub lhs).toPoly
    let strict := !strict
    let lhs' ← p'.denoteAsIntModuleExpr
    let some lhs' ← reify? lhs' (skipVar := false) | return ()
    let p := lhs'.norm
    let c : IneqCnstr := { p, strict, h := .notCoreCommRing e lhs rhs lhs' }
    c.assert
  else
    let p' := (lhs.sub rhs).toPoly
    let lhs' ← p'.denoteAsIntModuleExpr
    let some lhs' ← reify? lhs' (skipVar := false) | return ()
    let p := lhs'.norm
    let c : NotIneqCnstr := { p, strict, h := .coreCommRing e lhs rhs lhs' }
    c.assert

def propagateIntModuleIneq (e : Expr) (lhs rhs : Expr) (strict : Bool) (eqTrue : Bool) : LinearM Unit := do
  let some lhs ← reify? lhs (skipVar := false) | return ()
  let some rhs ← reify? rhs (skipVar := false) | return ()
  if eqTrue then
    let p := (lhs.sub rhs).norm
    let c : IneqCnstr := { p, strict, h := .core e lhs rhs }
    c.assert
  else if (← isLinearOrder) then
    let p := (rhs.sub lhs).norm
    let strict := !strict
    let c : IneqCnstr := { p, strict, h := .notCore e lhs rhs }
    c.assert
  else
    let p := (lhs.sub rhs).norm
    let c : NotIneqCnstr := { p, strict, h := .core e lhs rhs }
    c.assert

def propagateIneq (e : Expr) (eqTrue : Bool) : GoalM Unit := do
  let numArgs := e.getAppNumArgs
  unless numArgs == 4 do return ()
  let α := e.getArg! 0 numArgs
  let some structId ← getStructId? α | return ()
  LinearM.run structId do
    let inst := e.getArg! 1 numArgs
    let struct ← getStruct
    let strict ← if isLeInst struct inst then
      pure false
    else if isLtInst struct inst then
      pure true
    else
      return ()
    let lhs := e.getArg! 2 numArgs
    let rhs := e.getArg! 3 numArgs
    if (← isCommRing) then
      propagateCommRingIneq e lhs rhs strict eqTrue
    -- TODO: non-commutative ring normalizer
    else
      propagateIntModuleIneq e lhs rhs strict eqTrue

end Lean.Meta.Grind.Arith.Linear
