-- http://chalkdustmagazine.com/features/can-computers-prove-theorems/
-- https://github.com/leanprover
-- https://github.com/jroesch/language-lean
inductive nat
| zero : nat
| S (n : nat) : nat

def add : nat → (nat → nat)
| m zero := m
| m (S(n)) := S(add m n)

theorem zero_add (n : nat) : zero + n = n :=
begin
  induction n with d H,
  {
    refl
  },
  {
    show S (zero + d) = S(d),
    rewrite H,
  }
end
-- H is the hypothesis that zero + d = d
-- 1 goal
-- d : nat,
-- H : zero + d = d
-- ⊢ S (zero + d) = S d
