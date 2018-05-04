Require Import SLC.Lib.

Require Import ZArith.
Require Import Coq.Bool.Bool.

Hint Rewrite eqb_true_iff: libR.
Hint Rewrite eqb_false_iff: libR.
Hint Rewrite <- Zeq_is_eq_bool: libR.
Hint Rewrite orb_true_iff: libR.

(*
Definition bool_and b1 (b2: true = b1 -> bool): bool :=
  match b1 as B return (B = b1 -> bool) with
  | true => b2
  | false => fun _ => false
  end eq_refl.

Notation "b1 &b b2" := (bool_and b1 (fun _ => b2)) (at level 80, right associativity).

Lemma bool_and_iff: forall b1 b2,
    (b1 &b b2) = true <-> b1 = true /\ b2 = true.
  unfold bool_and; repeat libStep.
Qed.

Hint Rewrite bool_and_iff: libR.
 *)

Notation "b1 &&b b2" := (if b1 then b2 else false) (at level 50). 

Lemma rewrite_and_true:
  forall b: bool, b &&b true = b.
Proof.
  repeat libStep.
Qed.

Lemma rewrite_and_true2:
  forall a b: bool, b &&b true = a -> b = a.
Proof.
  repeat libStep.
Qed.

Lemma rewrite_true_and:
  forall b: bool, true &&b b = b.
Proof.
  repeat libStep.
Qed.

Lemma rewrite_and_false:
  forall b: bool, b &&b false = false.
Proof.
  repeat libStep.
Qed.

Lemma rewrite_false_and:
  forall b: bool, false &&b b = false.
Proof.
  repeat libStep.
Qed.

Hint Rewrite rewrite_and_true: libR.
Hint Rewrite rewrite_true_and: libR.
Hint Rewrite rewrite_and_false: libR.
Hint Rewrite rewrite_false_and: libR.

Lemma if_then_false:
  forall b (e1: true = b -> bool),
           ifthenelse b bool e1 (fun _ => false) = true ->
           b = true /\ exists H: true = b, e1 H = true.
Proof.
  repeat libStep || exists eq_refl.
Qed.

Lemma if_then_false2:
  forall b e1,
           (ifthenelse b bool (fun _ => e1) (fun _ => false)) = true ->
           b = true /\ e1 = true.
Proof.
  repeat libStep.
Qed.

Ltac literal b :=
  (unify b true) + (unify b false).

Ltac not_literal b := tryif literal b then fail else idtac.


Ltac t_bool :=
  match goal with
  | H: ?b &&b true = ?a |- _ =>
    let H2 := fresh H in
    poseNew (Mark (a,b) "rewrite_and_true");
    pose proof (rewrite_and_true2 _ _ H) as H2                            
  | H: eqb ?a ?b = true |- _ =>
    let H2 := fresh H in
    poseNew (Mark H "eqb_true_iff");
    pose proof (proj1 (eqb_true_iff _ _) H) as H2                             
  | H: ifthenelse ?b bool ?a _ = true |- _ =>
    let H2 := fresh H in
    poseNew (Mark (a,b) "if_then_false2");
    pose proof (if_then_false2 _ _ H) as H2                              
  | H: true = ifthenelse ?b bool ?a _ |- _ =>
    let H2 := fresh H in
    poseNew (Mark (a,b) "if_then_false2");
    pose proof (if_then_false2 _ _ (eq_sym H)) as H2                          
  | H: ifthenelse ?b bool ?a _ = true |- _ =>
    let H2 := fresh H in
    poseNew (Mark (a,b) "if_then_false");
    pose proof (if_then_false _ _ H) as H2                              
  | H: true = ifthenelse ?b bool ?a _ |- _ =>
    let H2 := fresh H in
    poseNew (Mark (a,b) "if_then_false");
    pose proof (if_then_false2 _ _ (eq_sym H)) as H2    
  | |- ?b1 = ?b2 => not_literal b1; not_literal b2; apply eq_iff_eq_true
  end.
