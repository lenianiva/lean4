abbrev f (a : α) := a

set_option grind.debug true
set_option grind.debug.proofs true

/--
error: `grind` failed
case grind.1.2
a b c : Bool
p q : Prop
left✝ : a = true
left : p
right : q
h✝ : b = false
h : c = true
⊢ False[facts] Asserted facts
  [prop] a = true
  [prop] b = true ∨ c = true
  [prop] p
  [prop] q
  [prop] b = false ∨ a = false
  [prop] b = false
  [prop] c = true[eqc] True propositions
  [prop] b = true ∨ c = true
  [prop] p
  [prop] q
  [prop] b = false ∨ a = false
  [prop] b = false
  [prop] c = true[eqc] Equivalence classes
  [eqc] {b = true, a = false}
  [eqc] {b, false}
  [eqc] {a, c, true}
-/
#guard_msgs (error) in
theorem ex (h : (f a && (b || f (f c))) = true) (h' : p ∧ q) : b && a := by
  grind

open Lean.Grind.Eager in
/--
error: `grind` failed
case grind.2.1
a b c : Bool
p q : Prop
left✝ : a = true
h✝ : c = true
left : p
right : q
h : b = false
⊢ False[facts] Asserted facts
  [prop] a = true
  [prop] c = true
  [prop] p
  [prop] q
  [prop] b = false[eqc] True propositions
  [prop] p
  [prop] q[eqc] Equivalence classes
  [eqc] {b, false}
  [eqc] {a, c, true}
-/
#guard_msgs (error) in
theorem ex2 (h : (f a && (b || f (f c))) = true) (h' : p ∧ q) : b && a := by
  grind

def g (i : Nat) (j : Nat) (_ : i > j := by omega) := i + j

/--
error: `grind` failed
case grind
i j : Nat
h : j + 1 < i + 1
h✝ : j + 1 ≤ i
x✝ : ¬g (i + 1) j ⋯ = i + j + 1
⊢ False[facts] Asserted facts
  [prop] j + 1 ≤ i
  [prop] ¬g (i + 1) j ⋯ = i + j + 1[eqc] True propositions
  [prop] j + 1 ≤ i[eqc] False propositions
  [prop] g (i + 1) j ⋯ = i + j + 1[offset] Assignment satisfying offset contraints
  [assign] j := 1
  [assign] i := 2
  [assign] i + j := 0
-/
#guard_msgs (error) in
example (i j : Nat) (h : i + 1 > j + 1) : g (i+1) j = f ((fun x => x) i) + f j + 1 := by
  grind

structure Point where
  x : Nat
  y : Int

/--
error: `grind` failed
case grind
a₁ : Point
a₂ : Nat
a₃ : Int
as : List Point
b₁ : Point
bs : List Point
b₂ : Nat
b₃ : Int
head_eq : a₁ = b₁
x_eq : a₂ = b₂
y_eq : a₃ = b₃
tail_eq : as = bs
⊢ False[facts] Asserted facts
  [prop] a₁ = b₁
  [prop] a₂ = b₂
  [prop] a₃ = b₃
  [prop] as = bs[eqc] Equivalence classes
  [eqc] {as, bs}
  [eqc] {a₃, b₃}
  [eqc] {a₂, b₂}
  [eqc] {a₁, b₁}
-/
#guard_msgs (error) in
theorem ex3 (h : a₁ :: { x := a₂, y := a₃ : Point } :: as = b₁ :: { x := b₂, y := b₃} :: bs) : False := by
  grind

def h (a : α) := a

example (p : Prop) (a b c : Nat) : p → a = 0 → a = b → h a = h c → a = c ∧ c = a → a = b ∧ b = a → a = c := by
  grind

set_option trace.grind.debug.proof true
/--
error: `grind` failed
case grind.1
α : Type
a : α
p q r : Prop
h₁ : HEq p a
h₂ : HEq q a
h₃ : p = r
left : ¬p ∨ r
h : ¬r
⊢ False[facts] Asserted facts
  [prop] HEq p a
  [prop] HEq q a
  [prop] p = r
  [prop] ¬p ∨ r
  [prop] ¬r ∨ p
  [prop] ¬r[eqc] True propositions
  [prop] p = r
  [prop] ¬p ∨ r
  [prop] ¬r ∨ p
  [prop] ¬p
  [prop] ¬r[eqc] False propositions
  [prop] a
  [prop] p
  [prop] q
  [prop] r
case grind.2
α : Type
a : α
p q r : Prop
h₁ : HEq p a
h₂ : HEq q a
h₃ : p = r
left : ¬p ∨ r
h : p
⊢ False[facts] Asserted facts
  [prop] HEq p a
  [prop] HEq q a
  [prop] p = r
  [prop] ¬p ∨ r
  [prop] ¬r ∨ p
  [prop] p[eqc] True propositions
  [prop] p = r
  [prop] ¬p ∨ r
  [prop] ¬r ∨ p
  [prop] a
  [prop] p
  [prop] q
  [prop] r[eqc] False propositions
  [prop] ¬p
  [prop] ¬r
-/
#guard_msgs (error) in
example (a : α) (p q r : Prop) : (h₁ : HEq p a) → (h₂ : HEq q a) → (h₃ : p = r) → False := by
  grind

example (a b : Nat) (f : Nat → Nat) : (h₁ : a = b) → (h₂ : f a ≠ f b) → False := by
  grind

example (a : α) (p q r : Prop) : (h₁ : HEq p a) → (h₂ : HEq q a) → (h₃ : p = r) → q = r := by
  grind

/--
warning: declaration uses 'sorry'
---
info: [grind.issues] found congruence between
      g b
    and
      f a
    but functions have different types
-/
#guard_msgs in
set_option trace.grind.issues true in
set_option trace.grind.debug.proof false in
example (f : Nat → Bool) (g : Int → Bool) (a : Nat) (b : Int) : HEq f g → HEq a b → f a = g b := by
  fail_if_success grind
  sorry
