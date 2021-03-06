(** * The precategory of types

This file defines the precategory of types in a fixed universe ([type_precat])
and shows that it has some limits and exponentials.

Author: Langston Barrett (@siddharthist), Feb 2018
*)

(** ** Contents:

- The precategory of types (of a fixed universe) ([type_precat])
- (Co)limits
  - Colimits
    - Initial object ([InitialType])
    - Binary coproducts ([BinCoproductsType])
  - Limits
    - Terminal object ([TerminalType])
    - Binary products ([BinProductsType])
- Exponentials
  - The exponential functor y ↦ yˣ ([exp_functor])
  - Exponentials ([ExponentialsType])

*)

Require Import UniMath.Foundations.PartA.
Require Import UniMath.Foundations.Sets.
Require Import UniMath.MoreFoundations.PartA.

(* Basic category theory *)
Require Import UniMath.CategoryTheory.Categories.
Require Import UniMath.CategoryTheory.functor_categories.

(* (Co)limits *)
Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.bincoproducts.
Require Import UniMath.CategoryTheory.limits.binproducts.

(* Exponentials *)
Require Import UniMath.CategoryTheory.exponentials.
Require Import UniMath.CategoryTheory.Adjunctions.

Local Open Scope cat.
Local Open Scope functions.

(** ** The precategory of types of a fixed universe *)

Definition type_precat : precategory.
Proof.
  use mk_precategory.
  - use tpair; use tpair.
    + exact UU.
    + exact (λ X Y, X -> Y).
    + exact (λ X, idfun X).
    + exact (λ X Y Z f g, funcomp f g).
  - repeat split; intros; apply idpath.
Defined.

(** ** (Co)limits *)

(** *** Colimits *)

(** **** Initial object ([InitialType]) *)
(** The [empty] type is an initial object for the precategory of types. *)
Lemma InitialType : Initial type_precat.
Proof.
  apply (mk_Initial (empty : ob type_precat)).
  exact iscontrfunfromempty.
Defined.

(** **** Binary coproducts ([BinCoproductsType]) *)
(** The precategory of types has binary coproducts. *)
Lemma BinCoproductsType : BinCoproducts type_precat.
Proof.
  intros X Y.
  use tpair.
  - exact (coprod X Y,, inl,, inr).
  - apply isBinCoproduct'_to_isBinCoproduct.
    intro Z; apply (weqfunfromcoprodtoprod X Y Z).
Defined.

(** *** Limits *)

(** **** Terminal object ([TerminalType]) *)
(** The [unit] type is a terminal object for the precategory of types. *)
Lemma TerminalType : Terminal type_precat.
Proof.
  apply (mk_Terminal (unit : ob type_precat)).
  exact iscontrfuntounit.
Defined.

(** **** Binary products ([BinProductsType]) *)
(** The precategory of types has binary products. *)
Lemma BinProductsType : BinProducts type_precat.
Proof.
  intros X Y.
  use tpair.
  - exact ((X × Y),, dirprod_pr1,, dirprod_pr2).
  - apply isBinProduct'_to_isBinProduct.
    intro; apply (weqfuntoprodtoprod _ X Y).
Defined.

(** ** Exponentials *)

(** *** Exponential functor *)

Section ExponentialFunctor.
  Context (A : UU). (** This is the object we're ×-ing and ^-ing with *)

  (** To show that [type_precat] has exponentials, we need a right adjoint to the
      functor Y ↦ X × Y for fixed Y. *)
  Local Definition exp_functor_ob (X : UU) : UU := A -> X.
  Local Definition exp_functor_arr (X Y : UU) (f : X -> Y) :
    (A -> X) -> (A -> Y) := λ g, f ∘ g.
  Local Definition exp_functor_data : functor_data type_precat type_precat :=
    functor_data_constr _ _ (exp_functor_ob : type_precat → type_precat)
                            (@exp_functor_arr).

  Lemma exp_functor_is_functor : is_functor exp_functor_data.
  Proof.
    use dirprodpair.
    - intro; reflexivity.
    - intros ? ? ? ? ?; reflexivity.
  Defined.

  Definition exp_functor : functor type_precat type_precat :=
    mk_functor exp_functor_data exp_functor_is_functor.
End ExponentialFunctor.

Lemma ExponentialsType : Exponentials BinProductsType.
Proof.
  intro X.
  unfold is_exponentiable.
  unfold is_left_adjoint.
  refine (exp_functor X,, _).
  unfold are_adjoints.
  use tpair.
  - use dirprodpair.
    + use mk_nat_trans.
      * intro Y; cbn.
        unfold exp_functor_ob.
        exact (flip dirprodpair).
      * intros ? ? ?; reflexivity.
    + use mk_nat_trans.
      * intro Y; cbn.
        unfold exp_functor_ob.
        exact (λ pair, (pr2 pair) (pr1 pair)).
      * intros ? ? ?; reflexivity.
  - use mk_form_adjunction; reflexivity.
Defined.
