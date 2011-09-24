/*****************************************************************************
Gildas Ménier - gildas.menier@univ-ubs.fr
Laboratoire VALORIA - Université de Bretagne Sud
Random generator built on 2 Multiple Linear Congr. Generators with high prime numbers merge
see ACM V.31 J.88, N.6. p42 & P.L'Ecuyer
******************************************************************************/
class rnd
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

predicates % from C
        unsigned_seed        : (unsigned X, unsigned Y) language c as "_unsigned_seed".
        unsigned_rnd          : (unsigned X) -> unsigned language c as "_unsigned_rnd".
        real_rnd                 : () -> real language c as "_real_rnd".
        
predicates % Visual Prolog
        seed: () .
        rnd: (unsigned X) -> unsigned procedure (i).
        rnd:() -> real .
        

end class rnd