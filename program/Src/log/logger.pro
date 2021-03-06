/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement logger
    open core, file

constants
    className = "log/logger".
    classVersion = "".

clauses
    classInfo(className, classVersion).

constants
    default_css_filename : string = @"XHTML Logger.css".
    
class facts -loggerRepository
    logger_fact : (symbol LoggerID, logger SavedLogger) nondeterm.

clauses
    getLogger(ID) = Logger :-
        logger_fact(ID, Logger),
        !.
    getLogger(IncorrectID) = _DontMatter :-
        Msg = string::concat("logger::getLogger/1-> : Не удалось извлечь объект класса logger: ID ", IncorrectID, " неизвестен"),
        errorHandler::raise(
            classInfo,
            Msg).

clauses
    getLogger_nd(ID, Logger) :-
        logger_fact(ID, Logger).
        
clauses
    saveLogger(ID, Logger) :-
        assert(logger_fact(ID, Logger)).

clauses
    deleteLogger(ID) :-
        retractall(logger_fact(ID, _)).

clauses
    createAndSaveLogger(ID, Type, BufferSize, FileName) = Logger :-
        try
            Logger = logger::new(Type, BufferSize, FileName)
        catch CannotCreate_Exception do
            Msg = "logger::createAndSaveLogger/4-> : Не удалось создать и сохранить общедоступный объект класса logger: конструктор завершился аварийно",
            errorHandler::continue(
                classInfo,
                CannotCreate_Exception,
                Msg)
        end try,
        saveLogger(ID, Logger).

/* Выкинуто как не приносящее пользы усложнение
class facts
    % Если dump_filename ВНЕЗАПНО исчез, попробовать ли создать новый файл лога (с немного изменённым именем)
    %   попытка восстановления производится _один_ раз, после чего точно следует runtime error.
    is_recover_on_error : boolean := false().

clauses
    setIsRecover(IsRecoverOnError) :-
        is_recover_on_error := IsRecoverOnError.
*/

/*
Содержательная часть лога
*/
facts
    %
    log_type_fact : logtype := erroneous.

/*    
    %
    dump_file : outputStream := erroneous.
*/
    
    %
    dump_filename_fact : string := erroneous.
    
    %
    record_fact : (symbol MessageType, symbol MessageSubject, string Message) nondeterm.
    
    %
    records_count : integer := erroneous.

    %
    buffer_size : integer := erroneous.

    %
    written_messages_counter : integer := erroneous.

    %
    log_is_closed : boolean := erroneous.
    
%
predicates
    createDumpFile : (string FileName, logtype LogType) procedure (i, i).
clauses
    createDumpFile(FileName, LogType) :-
        try
            Stream = outputStream_file::create(FileName, stream::unicode(), fileSystem_api::permitNone())
        catch CannotCreateFile_Exception do
            Msg = string::concat("logger::createDumpFile/1 : Не удалось создать файл лога: ошибка при создании файла ", Filename),
            errorHandler::continue(classInfo, CannotCreateFile_Exception, Msg)
        end try,
        DumpFileHeader = constructLogHeader(LogType),
        Stream:write(DumpFileHeader),
        Stream:close().
        
%
clauses
    new(LogType, BufSize, FileName) :-
        try
            createDumpFile(FileName, LogType)
        catch CannotCreateFile_Exception do
            Msg = string::concat("logger::new/3-> : Не удалось создать объект класса logger: ошибка при создании выходного файла ", Filename),
            errorHandler::continue(classInfo, CannotCreateFile_Exception, Msg)
        end try,
        log_type_fact := LogType,
        dump_filename_fact := FileName,
        buffer_size := BufSize,
        records_count := 0,
        written_messages_counter := 0,
        log_is_closed := false().

% Финализатор, объявленный неявно. Вызывается при уничтожении объекта класса logger.
clauses
    finalize() :-
        closeLog().

clauses
    closeLog() :-
        log_is_closed = true(),
        !.
    closeLog() :-
        try
            dumpBuffer()
        catch CannotWriteRecords_Exception do
            errorHandler::continue(
                classInfo,
                CannotWriteRecords_Exception,
                "logger::closeBuffer/0 : Не удалось перед закрытием лога сохранить оставшиеся в памяти записи в файл: предикат dumpBuffer/0 завершился аварийно.")
        end try,
        Footer = constructLogFooter(log_type_fact),
        Stream = outputStream_file::append(dump_filename_fact),
        try
            Stream:write(Footer)
        catch CannotWriteFooter_Exception do
            errorHandler::continue(
                classInfo,
                CannotWriteFooter_Exception,
                "logger::closeBuffer/0 : Не удалось записать корректный завершающий текст лога в файл: предикат записи завершился аварийно.")
        end try,
        Stream:close(),
        log_is_closed := true().

%
clauses
    isClosed() :-
        log_is_closed = true().

%
clauses
    %
    record(_MT, _MS, _M) :-
        records_count + 1 > buffer_size,
        dumpBuffer(),
        fail().
    %
    record(MsgType, MsgSubject, Message) :-
        assert(record_fact(MsgType, MsgSubject, Message)),
        records_count := records_count + 1.

%
clauses
    dumpToBuffer_Forced() :-
        dumpBuffer().

%
clauses
    %
    type() = log_type_fact.
    
    %
    dump_filename() = dump_filename_fact.

clauses
    getFilenameExtensionFor(xhtml()) = ".html" :-
        !.
    getFilenameExtensionFor(xml()) = ".xml" :-
        !.
    getFilenameExtensionFor(txt()) = ".txt" :-
        !.
    getFilenameExtensionFor(_AnyOtherType) = "".    % Могут быть добавлены ещё типы лога в домен logger::logtype.
      
/*
Собственно вывод в файл
*/
predicates
    dumpBuffer : () procedure.
clauses
    dumpBuffer() :-
        Stream = outputStream_file::append(dump_filename_fact),
        foreach retract(record_fact(MsgType, MsgSubject, Message)) do
            written_messages_counter := written_messages_counter + 1,
            StringMessage = convertRecordToString(log_type_fact, written_messages_counter, MsgType, MsgSubject, Message),
            try
                Stream:write(StringMessage)
            catch CannotWrite_Exception do
                errorHandler::continue(
                    classInfo,
                    CannotWrite_Exception,
                    "logger::dumpBuffer/0 : Не удалось записать содержимое лога в файл: предикат записи завершился аварийно.")
            end try 
        end foreach,
        Stream:close(),
        records_count := 0.
        
/*
Преобразование лога в текст, форматированный по указанным правилам разметки (XML, Plain text, XHTML)
% TODO HARD-CODING WARNING!
*/
class predicates
    getCSS : () -> string CSSAsString procedure.
clauses
    getCSS() = CSSAsString :-
        Str = outputStream_string::new(),
        try
            CSSFile = inputStream_file::openFile(default_css_filename)
        catch _CannotOpenException do
            fail()
        end try,
        std::repeat(),
            Str:write(CSSFile:readLine()),
            Str:nl(),
        CSSFile:endOfStream(),
        !,
        CSSAsString = Str:getString(),
        Str:close().
    getCSS() = "".
    
clauses
    constructLogHeader(xml()) = LogHeader :-
        XMLHeader = "<?xml version=\"1.0\" encoding=\"utf-16\" standalone=\"yes\" ?>\n",
        MainTagOpen = "<log>",
        DateTimeObj = time::new(),
        CurrentDateTime = DateTimeObj:format("'\t<creation date=\"'MMM dd, yyyy'\" time=\"'HH:mm:ss.qqq'\" \\>'\n"),
        LogHeader = string::concat(XMLHeader, MainTagOpen, CurrentDateTime).
    constructLogHeader(xhtml()) = LogHeader :-
        DOCTYPEHeader = "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n",
        Caption = "Victoria Project Working Log",
        DateTimeObj = time::new(),
        CurrentDateTime = DateTimeObj:format("'Creation date: 'MMM dd, yyyy,' time: 'HH:mm:ss.qqq"),
        XHTMLHeader = "<html xmlns=\"http://www.w3.org/1999/xhtml\">\n",
%        CSS = string::concat("\t<style type=\"text-css\" media=\"screen\">\n", getCSS(), "\n</style>\n"),
        CSS = string::concat("<link rel=\"stylesheet\" href=\"", default_css_filename, "\" media=\"screen\" type=\"text/css\" />\n"),
        HeadTag = string::concatList(["<head>\n\t<title> ", Caption, ". ", CurrentDateTime, "</title>\n", CSS, "</head>\n"]),
        TableParams = "border=\"1px\" cellspacing=\"0px\"",
        BodyTableOpen = string::concatList(["<body>\n\t<h1>", Caption, "\n\t</h1>\n\t\t<p>", CurrentDateTime, "</p>\n\t<table ", TableParams, ">\n"]),
        HeaderRow = "\t\t<tr>\n\t\t\t<th>#</th>\n\t\t\t<th>Тип</th>\n\t\t\t<th>Источник</th>\n\t\t\t<th>Сообщение</th>\n\t\t</tr>\n",
        LogHeader = string::concatList([DOCTYPEHeader, XHTMLHeader, HeadTag, BodyTableOpen, HeaderRow]).
    constructLogHeader(txt()) = LogHeader :-
        DateTimeObj = time::new(),
        CurrentDateTime = DateTimeObj:format("'date: 'MMM dd, yyyy,' time: 'HH:mm:ss.qqq"),
        LogHeader = string::concat("Victoria Project Working Log.\nCreation ", CurrentDateTime, "\n-----\n").

clauses
    constructLogFooter(xml()) = LogFooter :-
        DateTimeObj = time::new(),
        CurrentDateTime = DateTimeObj:format("\t<'closing date=\"'MMM dd, yyyy'\" time=\"'HH:mm:ss.qqq'\" \\>\n'"),
        MainTagClose = "</log>",
        LogFooter = string::concat(CurrentDateTime, MainTagClose).
    constructLogFooter(xhtml()) = LogFooter :-
        DateTimeObj = time::new(),
        CurrentDateTime = DateTimeObj:format("'\t<p>Closed on date: 'MMM dd, yyyy,' time: 'HH:mm:ss.qqq'</p>'"),
        LogFooter = string::concat("\t</table>\n", CurrentDateTime, "\n</body>\n</html>").
    constructLogFooter(txt()) = LogFooter :-
        DateTimeObj = time::new(),
        CurrentDateTime = DateTimeObj:format("'Closed on date: 'MMM dd, yyyy,' time: 'HH:mm:ss.qqq"),
        LogFooter = CurrentDateTime.

class predicates
    getMessageTypeName : (symbol MsgTypeLiteral) -> string MsgTypeAsString procedure (i).
clauses
    getMessageTypeName("event") = "Событие" :-
        !.
    getMessageTypeName("report") = "Отчёт" :-
        !.
    getMessageTypeName("warning") = "Предупреждение" :-
        !.
    getMessageTypeName("error") = "Ошибка" :-
        !.
    getMessageTypeName(_AnyOtherLiteral) = "".
    
class predicates
    getMessageSubjectName : (symbol MsgSubjectLiteral) -> string MsgSubjectAsString procedure (i).
clauses
    getMessageSubjectName("individ") = "Особь" :-
        !.
    getMessageSubjectName("reality") = "Виртуальная реальность" :-
        !.
    getMessageSubjectName("fuzzy") = "Нечёткий контроллер" :-
        !.
    getMessageSubjectName("genetic") = "Генетический алгоритм" :-
        !.
    getMessageSubjectName("default") = "Система" :-
        !.
    getMessageSubjectName(_AnyOtherLiteral) = "".

class predicates
    format_ByMsgType : (symbol MsgType, string Input) -> string Output procedure (i, i).
clauses
    format_ByMsgType("report", InputStr) = string::concat("<pre>", InputStr, "</pre>") :-
        !.
    format_byMsgType(_AnyOtherType, InputStr) = string::replaceAll(InputStr, "\n", "<br />").

clauses
    convertRecordToString(xml(), MsgIdx, MsgType, MsgSubj, MsgText) = RecordAsString :-
        MsgTypeStr = getMessageTypeName(MsgType),
        MsgSubjStr = getMessageSubjectName(MsgSubj),
        RecordAsString = string::concatList([
            "\t<record id=\"", toString(MsgIdx), "\" type=\"", toString(MsgType), "\" subject=\"", toString(MsgSubj), "\" >\n",
            "\t\t<type>", MsgTypeStr, "</type>\n",
            "\t\t<subject>", MsgSubjStr, "</subject>\n",
            "\t\t<text>", MsgText, "</text>\n",
            "\t</record>\n"]).
    convertRecordToString(xhtml(), MsgIdx, MsgType, MsgSubj, MsgText) = RecordAsString :-
        MsgTypeStr = getMessageTypeName(MsgType),
        MsgSubjStr = getMessageSubjectName(MsgSubj),
        RecordAsString = string::concatList([
            "\t\t<tr class=\"", string::format("%s-%s", MsgType, MsgSubj), "\" >\n\t\t\t<td>", toString(MsgIdx), "</td>",
            "<td>", MsgTypeStr, "</td><td>", MsgSubjStr, "</td>\n",
            "\t\t\t<td>", format_byMsgType(MsgType, MsgText), "</td>\n\t\t</tr>\n"]).
    convertRecordToString(txt(), MsgIdx, MsgType, MsgSubj, MsgText) = RecordAsString :-
        MsgTypeStr = getMessageTypeName(MsgType),
        MsgSubjStr = getMessageSubjectName(MsgSubj),
        RecordAsString = string::concatList([
            "--------------------------\n#", toString(MsgIdx), " type ", toString(MsgType), " subj ", toString(MsgSubj),
            "\n\tТип: ", MsgTypeStr,
            "\n\tИсточник: ", MsgSubjStr,
            "\n\tСообщение: ", MsgText,
            "\n--------------------------\n"]).
        
end implement logger
