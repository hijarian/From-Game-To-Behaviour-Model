/*****************************************************************************

                         

******************************************************************************/
class fset_LR : fset_LR
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

constructors
    new : (symbol ID).

end class fset_LR