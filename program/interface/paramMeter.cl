/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class paramMeter : paramMeter
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

constructors
    new : ().

constructors
    new : (containerWindow Parent).

end class paramMeter