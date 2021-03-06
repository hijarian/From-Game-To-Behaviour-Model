/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

interface logger
    open core

%
domains
    %
    logtype = xml(); txt(); xhtml().


/*
    %
%    msgtype = error(); warning(); event(); report().    % Нахрен!
    MessageType = "error"; "warning"; "event"; "report"
    %
%    msgsubject = individ(); reality(); genetic(); fuzzy(); default().    % Нахрен!
    MessageSubject = "individ"; "reality"; "genetic"; "fuzzy"; "default"
*/
    
%
predicates
    %
    record : (symbol MessageType, symbol Subject, string Message) procedure (i, i, i).
    
    %
    dumpToBuffer_Forced : () procedure.
    
    % После закрытия лога возможность открыть его заново не предусмотрена! Только создавать новый лог.
    closeLog : () procedure.
    
    %
    isClosed : () determ.

% Получение ключевых свойств текущего объекта лога. Не знаю, зачем это может понадобиться. :)
properties
    %
    type : logtype (o).
    
    %
    dump_filename : string (o).
    
end interface logger