/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class fmViewIndividual : fmViewIndividual
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

predicates
    display : (window Parent) -> fmViewIndividual FmViewIndividual.

constructors
    new : (window Parent).

end class fmViewIndividual