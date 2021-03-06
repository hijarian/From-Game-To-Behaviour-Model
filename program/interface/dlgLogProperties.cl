/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class dlgLogProperties : dlgLogProperties
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

predicates
    display : (window Parent) -> dlgLogProperties DlgLogProperties.

constructors
    new : (window Parent).

end class dlgLogProperties