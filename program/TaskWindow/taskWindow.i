/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

interface taskWindow supports applicationWindow
    open core

predicates
    getMessageStream : () -> outputStream MessageFormStream.

properties
    individViewWindow : fmViewIndividual (o).
    
end interface taskWindow