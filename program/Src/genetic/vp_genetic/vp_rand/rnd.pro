/*****************************************************************************
Gildas Ménier - gildas.menier@univ-ubs.fr
Laboratoire VALORIA - Université de Bretagne Sud
Random generator built on 2 Multiple Linear Congr. Generators with high prime numbers merge
see ACM V.31 J.88, N.6. p42 & P.L'Ecuyer
******************************************************************************/

implement rnd
    open core

resolve unsigned_seed externally
resolve unsigned_rnd externally
resolve real_rnd externally

constants
    className = "vp_rand/rnd".
    classVersion = "".

clauses
    classInfo(className, classVersion).
    
clauses
    seed() :-
        Time = time::new(), Time:getTimeDetailed(H,M,S),
        unsigned_seed(convert(unsigned,math::round(H*M*S)),4567)
    .%
    
    rnd(X) = unsigned_rnd(X).
    
    rnd() = real_rnd().


end implement rnd
