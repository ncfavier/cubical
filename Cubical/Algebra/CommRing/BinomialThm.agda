{-# OPTIONS --safe --experimental-lossy-unification #-}
module Cubical.Algebra.CommRing.BinomialThm where

open import Cubical.Foundations.Prelude
open import Cubical.Foundations.Equiv
open import Cubical.Foundations.Equiv.HalfAdjoint
open import Cubical.Foundations.Function
open import Cubical.Foundations.HLevels
open import Cubical.Foundations.Isomorphism
open import Cubical.Foundations.Univalence
open import Cubical.Foundations.Transport
open import Cubical.Foundations.SIP
open import Cubical.Foundations.Powerset

open import Cubical.Data.Sigma
open import Cubical.Data.Nat renaming ( _+_ to _+ℕ_ ; _·_ to _·ℕ_
                                      ; ·-assoc to ·ℕ-assoc ; ·-comm to ·ℕ-comm
                                      ; _choose_ to _ℕchoose_)
open import Cubical.Data.FinData

open import Cubical.Structures.Axioms
open import Cubical.Structures.Auto
open import Cubical.Structures.Macro
open import Cubical.Algebra.Semigroup
open import Cubical.Algebra.Monoid
open import Cubical.Algebra.Monoid.BigOp
open import Cubical.Algebra.AbGroup
open import Cubical.Algebra.Ring
open import Cubical.Algebra.Ring.BigOps
open import Cubical.Algebra.CommRing
open import Cubical.Algebra.RingSolver.ReflectionSolving

private
  variable
    ℓ : Level

module _ (R' : CommRing ℓ) where
 open CommRingStr (snd R')
 open Exponentiation R'
 open CommRingTheory R'
 open Sum (CommRing→Ring R')
 private R = fst R'

 _choose_ : ℕ → ℕ → R
 n choose zero = 1r
 zero choose suc k = 0r
 suc n choose suc k = n choose (suc k) + n choose k

 nChooseN+1 : ∀ n → n choose (suc n) ≡ 0r
 nChooseN+1 zero = refl
 nChooseN+1 (suc n) = {!!}

 BinomialVec : (n : ℕ) → R → R → FinVec R (suc n)
 BinomialVec n x y i = (n choose (toℕ i)) · x ^ (toℕ i) · y ^ (n ∸ toℕ i)

 thm : ∀ (n : ℕ) (x y : R) → (x + y) ^ n ≡ ∑ (BinomialVec n x y)
 thm zero x y = solve R'
 thm (suc n) x y =
     (x + y) ^ suc n
  ≡⟨ refl ⟩
     (x + y) · (x + y) ^ n
  ≡⟨ cong ((x + y) ·_) (thm n x y) ⟩
     (x + y) · ∑ (BinomialVec n x y)
  ≡⟨ ·Ldist+ _ _ _ ⟩
     x · ∑ (BinomialVec n x y) + y · ∑ (BinomialVec n x y)
  ≡⟨ cong₂ (_+_) (∑Mulrdist _ (BinomialVec n x y)) (∑Mulrdist _ (BinomialVec n x y)) ⟩
     ∑ (λ i → x · BinomialVec n x y i)
   + ∑ (λ i → y · BinomialVec n x y i)
  ≡⟨ refl ⟩
     ∑ {n = suc n} (λ i → x · ((n choose (toℕ i)) · x ^ (toℕ i) · y ^ (n ∸ toℕ i)))
   + ∑ {n = suc n} (λ i → y · ((n choose (toℕ i)) · x ^ (toℕ i) · y ^ (n ∸ toℕ i)))
  ≡⟨ cong₂ (_+_) (∑Ext xVecPath) (∑Ext yVecPath) ⟩
     ∑ xVec + ∑ yVec
  ≡⟨ cong (_+ ∑ yVec) (∑Last xVec) ⟩
     ∑ (xVec ∘ weakenFin) + xⁿ⁺¹ + (yⁿ⁺¹ + ∑ (yVec ∘ suc))
  ≡⟨ solve3 _ _ _ _ ⟩
     yⁿ⁺¹  + (∑ (xVec ∘ weakenFin) + ∑ (yVec ∘ suc)) + xⁿ⁺¹
  ≡⟨ cong (λ s → yⁿ⁺¹  + s + xⁿ⁺¹) (sym (∑Split _ _))  ⟩
     yⁿ⁺¹  + (∑ middleVec) + xⁿ⁺¹
  ≡⟨ cong (λ s → yⁿ⁺¹  + s + xⁿ⁺¹) (∑Ext middlePath) ⟩
     yⁿ⁺¹ + ∑ ((BinomialVec (suc n) x y) ∘ weakenFin ∘ suc) + xⁿ⁺¹
  ≡⟨ refl ⟩
     ∑ ((BinomialVec (suc n) x y) ∘ weakenFin) + xⁿ⁺¹
  ≡⟨ cong (∑ ((BinomialVec (suc n) x y) ∘ weakenFin) +_) xⁿ⁺¹Path
   ∙ sym (∑Last (BinomialVec (suc n) x y)) ⟩
     ∑ (BinomialVec (suc n) x y) ∎
  where
  xVec : FinVec R (suc n)
  xVec i = (n choose (toℕ i)) · x ^ (suc (toℕ i)) · y ^ (n ∸ toℕ i)

  solve1 : ∀ x nci xⁱ yⁿ⁻ⁱ → x · (nci · xⁱ · yⁿ⁻ⁱ) ≡ nci · (x · xⁱ) · yⁿ⁻ⁱ
  solve1 = solve R'

  xVecPath : ∀ (i : Fin (suc n)) → x · ((n choose (toℕ i)) · x ^ (toℕ i) · y ^ (n ∸ toℕ i)) ≡ xVec i
  xVecPath i = solve1 _ _ _ _

  yVec : FinVec R (suc n)
  yVec i = (n choose (toℕ i)) · x ^ (toℕ i) · y ^ (suc (n ∸ toℕ i))

  solve2 : ∀ y nci xⁱ yⁿ⁻ⁱ → y · (nci · xⁱ · yⁿ⁻ⁱ) ≡ nci · xⁱ · (y · yⁿ⁻ⁱ)
  solve2 = solve R'

  yVecPath : ∀ (i : Fin (suc n)) → y · ((n choose (toℕ i)) · x ^ (toℕ i) · y ^ (n ∸ toℕ i)) ≡ yVec i
  yVecPath i = solve2 _ _ _ _

  xⁿ⁺¹ : R
  xⁿ⁺¹ = xVec (fromℕ n)
  yⁿ⁺¹ : R
  yⁿ⁺¹ = yVec zero

  xⁿ⁺¹Path : xⁿ⁺¹ ≡ BinomialVec (suc n) x y (fromℕ (suc n))
  xⁿ⁺¹Path = cong (λ m → m · (x · x ^ toℕ (fromℕ n)) · y ^ (n ∸ toℕ (fromℕ n)))
                  (sym (+Lid _) ∙ cong (_+ (n choose toℕ (fromℕ n)))
                  (sym (subst (λ m → (n choose suc m) ≡ 0r) (sym (toFromId n)) (nChooseN+1 n))))

  solve3 : ∀ sx sy xⁿ⁺¹ yⁿ⁺¹ → sx + xⁿ⁺¹ + (yⁿ⁺¹ + sy) ≡ yⁿ⁺¹ + (sx + sy) + xⁿ⁺¹
  solve3 = solve R'

  middleVec : FinVec R n
  middleVec i = xVec (weakenFin i) + yVec (suc i)

  middlePath : ∀ (i : Fin n) → middleVec i ≡ BinomialVec (suc n) x y (weakenFin (suc i))
  middlePath i = {!!}
   where
   foo : (y · y ^ (n ∸ suc (toℕ (weakenFin i)))) ≡ y ^ (n ∸ toℕ (weakenFin i))
   foo = (y · y ^ (n ∸ suc (toℕ (weakenFin i)))) ≡⟨ refl ⟩
         y ^ (suc (n ∸ suc (toℕ (weakenFin i)))) ≡⟨ cong (y ^_) {!!} ⟩
         y ^ (suc n ∸ suc (toℕ (weakenFin i))) ≡⟨ refl ⟩
         y ^ (n ∸ toℕ (weakenFin i)) ∎
   --solve4 : ∀ ncwi xxʷⁱ
   weakenedPath  :  (n choose toℕ (weakenFin i)) · (x · x ^ toℕ (weakenFin i))
                  · y ^ (n ∸ toℕ (weakenFin i))
                  + (n choose suc (toℕ (weakenFin i))) · (x · x ^ toℕ (weakenFin i))
                  · (y · y ^ (n ∸ suc (toℕ (weakenFin i))))
                 ≡
                    ((n choose suc (toℕ (weakenFin i))) + (n choose toℕ (weakenFin i)))
                  · (x · x ^ toℕ (weakenFin i)) · y ^ (n ∸ toℕ (weakenFin i))
   weakenedPath = {!!}
   --then use weakenRespToℕ
