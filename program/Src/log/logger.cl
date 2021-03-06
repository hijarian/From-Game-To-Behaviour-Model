/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class logger : logger
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

constructors
    new : (logtype LogType, integer BufferSize, string DumpFileName).

/* Выкинуто как не приносящее пользы
predicates
    setIsRecover : (boolean IsRecoverFromError) procedure (i).
*/

/*
Создание и манипулирование доступными отовсюду объектами класса logger
*/
predicates
    %
    createAndSaveLogger : (symbol ID, logtype LogType, integer BufferSize, string DumpFileName) -> logger SavedLogger procedure (i, i, i, i).
    
    %
    getLogger : (symbol ID) -> logger Logger procedure (i).
    
    %
    getLogger_nd : (symbol ID, logger Logger) nondeterm (i, o) (o, o).
    
    %
    saveLogger : (symbol ID, logger Logger) procedure (i, i).
    
    %
    deleteLogger : (symbol ID) procedure.

/*
Преобразование лога в текст, форматированный по указанным правилам разметки (XML, Plain text, XHTML)
*/
predicates
    %
    constructLogHeader : (logtype LogType) -> string LogHeader procedure (i).
    
    %
    constructLogFooter : (logtype LogType) -> string LogFooter procedure (i).
    
    %
    convertRecordToString : (
        logtype LogType, 
        integer MessageIndex, 
        symbol MessageType, 
        symbol MessageSubject, 
        string Message) 
            -> string StringToWrite procedure (i, i, i, i, i).

predicates
    getFilenameExtensionFor : (logger::logtype LogType) -> string FilenameExtension.

end class logger