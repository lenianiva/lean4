/-
Copyright (c) 2024 Amazon.com, Inc. or its affiliates. All Rights Reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Init.Core

namespace Lean.Grind

/-- A helper gadget for annotating nested proofs in goals. -/
def nestedProof (p : Prop) {h : p} : p := h

/--
Gadget for marking terms that should not be normalized by `grind`s simplifier.
`grind` uses a simproc to implement this feature.
We use it when adding instances of `match`-equations to prevent them from being simplified to true.
-/
def doNotSimp {α : Sort u} (a : α) : α := a

/-- Gadget for representing offsets `t+k` in patterns. -/
def offset (a b : Nat) : Nat := a + b

/--
Gadget for annotating the equalities in `match`-equations conclusions.
`_origin` is the term used to instantiate the `match`-equation using E-matching.
When `EqMatch a b origin` is `True`, we mark `origin` as a resolved case-split.
-/
def EqMatch (a b : α) {_origin : α} : Prop := a = b

theorem nestedProof_congr (p q : Prop) (h : p = q) (hp : p) (hq : q) : HEq (@nestedProof p hp) (@nestedProof q hq) := by
  subst h; apply HEq.refl

end Lean.Grind
