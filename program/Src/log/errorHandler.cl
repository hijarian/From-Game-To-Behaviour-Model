/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class errorHandler
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

predicates
    % Создаём runtime_exception::internalError с namedValue("Designer's Note", string(Message)) 
    %   в качестве дополнительной информации.
    raise : (classInfo ClassInfo, string Message) erroneous (i, i).

    %
    continue : (classInfo ClassInfo, exception::traceId ExceptionToContinue, string Message) erroneous (i, i, i).
    
    %
    handle : (exception::traceId ExceptionToHandle, string ErrorReport) procedure (i, o).

end class errorHandler