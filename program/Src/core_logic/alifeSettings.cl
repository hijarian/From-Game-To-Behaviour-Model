/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class alifeSettings
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

% Exported domains
domains
    ending = ending(symbol EndingID, fuzzySupport::fclause* ParametersNeeded).

% Извлечение/установка настроек
predicates
    % Продолжительность существования особи, 
    %   измеряемая в циклах выбора - совершения действий.
    getLifeLength : () -> integer LifeLength.
    
    %
    setLifeLength : (integer LifeLength).
    
    % Целевое конечное состояние особи,
    %   выраженное в лингвистических значениях некоторых из её параметров
    getTargetEnding : () -> ending TargetEnding.

    %
    setTargetEnding : (ending TargetEnding).
    
    %
    getMainLogType : () -> logger::logtype MainLoggerType.
    
    %
    setMainLogType : (logger::logtype MainLoggerType).
    
    %
    getFuzzyMindResolution : () -> unsigned Resolution.
    
    %
    setFuzzyMindResolution : (unsigned Resolution).
    
    %
    getMainLogFilenamePrefix : () -> string FilenamePrefix.
    
    %
    setMainLogFilenamePrefix : (string FilenamePrefix).
    
    %
    getActionListLogFilenamePrefix : () -> string FilenamePrefix.
    
    %
    setActionListLogFilenamePrefix : (string FilenamePrefix).
    
    %
    isDumpReality : () determ.
    
    %
    setIfDumpReality : (boolean DumpOrNot).
    
    %
    getRealityStateLogFilename : () -> string Filename.
    
    %
    setRealityStateLogFilename : (string Filename).

/*    
% Причины закомментированности - в alife.pro

    %
    isDumpIndividualClass : () determ.
    
    %
    getIndividualClassLogFilename : () -> string Filename.
    
    %
    setIndividualClassLogFilename : (string Filename).
*/
    
    %
    isDumpCurrentIndividual : () determ.
    
    %
    setIfDumpCurrentIndividual : (boolean DumpOrNot).
    
    %
    getCurrentIndividualLogFilename : () -> string Filename.
    
    %
    setCurrentIndividualLogFilename : (string Filename).
    
end class alifeSettings