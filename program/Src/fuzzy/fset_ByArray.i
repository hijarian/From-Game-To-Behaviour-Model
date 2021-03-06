/*****************************************************************************

                         

******************************************************************************/

interface fset_ByArray
    supports fset
    open core

predicates
    setPoint : (real XValue, real YValue).
    getPoint : (real XValue, real YValue) nondeterm (i, o) (o, o) (o, i) (i, i).
    removePoint : (real Xvalue, real YValue) nondeterm (i, o) (o, i) (i, i).

end interface fset_ByArray