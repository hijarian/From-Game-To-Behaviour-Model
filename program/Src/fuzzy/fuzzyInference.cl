/*****************************************************************************

                         

******************************************************************************/
class fuzzyInference : fuzzyInference
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

constructors
    new : ().
    new : (unsigned Resolution).

end class fuzzyInference