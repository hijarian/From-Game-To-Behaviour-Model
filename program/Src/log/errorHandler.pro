/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement errorHandler
    open core

constants
    className = "log/errorHandler".
    classVersion = "".

clauses
    classInfo(className, classVersion).

constants
    error_message_signature : symbol = "Designer's Notes".

clauses
    raise(ClassInfo, Msg) :-
        exception::raise(
                ClassInfo,
                runtime_exception::internalError,
                [namedValue(error_message_signature, string(Msg))]).
                
    continue(ClassInfo, ExceptionTraceID, Msg) :-
        exception::continue(
                ExceptionTraceID,
                ClassInfo,
                runtime_exception::internalError,
                [namedValue(error_message_signature, string(Msg))]).

class facts
    tempString : string := erroneous.

clauses
    handle(ExceptionTraceID, FullErrorReport) :-
        %TODO exception handling
        % 1. Запись в логе
        % 2. Сообщение в окне сообщений
        tempString := "",
        foreach ED = exception::getDescriptor_nd(ExceptionTraceID) do    % backtrack point!
            ED = exception::descriptor(
                    exception::classInfoDescriptor(ClassName, _VersionInfo),
                    ExceptionDescriptor, 
                    _Kind,    % raised() | continued() 
                    ExtraInfoList,    % namedValue_list 
                    _GMT, 
                    Description_1,    % string 
                    _ThreadID),    % unsigned
            MsgCustom = getExtraInfo(ExtraInfoList),
            %MsgCustom = namedValue::getNamed_string(ExtraInfoList, "DN"),
            exception::getExceptionInformation(
                ExceptionDescriptor, 
                _ClassInfo, 
                PredicateName, 
                Description_2),
            Msg = string::concatList([
                "-----\nException cathed.\n\tErroneous class: ",
                ClassName, "\n",
                "\tErroneous predicate: ",
                PredicateName, "\n",
                "\tDescription from exception descriptor: \n",
                Description_1, "\n",
                "\tFrom exception information:\n",
                Description_2, "\n",
                "\tFrom designer:\n",
                MsgCustom, "\n"]),
            tempString := string::concat(tempString, Msg)
        end foreach,
        FullErrorReport = tempString.

class predicates
    getExtraInfo : (namedValue_list ExtraInfoList) -> string ExtraInfoAsString procedure (i).
clauses
    getExtraInfo([]) = "" :-
        !.
    getExtraInfo([namedValue(ErrorSignature, string(MsgCustom)) | _DontMatter]) = Msg :-    % только первый встреченный!
        Msg = string::concat("signature: ", toString(ErrorSignature), ", text: ", MsgCustom),
        !.
    getExtraInfo(_AnyOtherInfo) = "".

end implement errorHandler
