def f (x y : Nat) : Nat :=
  x + 2*y

-- "+" with priority higher than the builtin "+" notation
infix:65 (priority := high) "+" => f

/-- info: 1+2 : Nat -/
#guard_msgs in
#check 1 + 2

theorem ex (x y : Nat) : x + y = f x y :=
  rfl
