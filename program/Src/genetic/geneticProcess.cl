/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class geneticProcess
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

predicates
    getLogFilename : () -> string Filename.
    
    setLogFilename : (string Filename).
    
    getLogType : () -> logger::logtype LogType.
    
    setLogType : (logger::logtype LogType).
    
    run : (genDraw DrawControl) -> cell BestIndivid.

end class geneticProcess