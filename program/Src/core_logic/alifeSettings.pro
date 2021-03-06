/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement alifeSettings
    open core

constants
    className = "core_logic/alifeSettings".
    classVersion = "".

clauses
    classInfo(className, classVersion).

%
class facts
    targetEnding_fact : ending := erroneous.

clauses
    %
    getTargetEnding() = targetEnding_fact.
    
    %
    setTargetEnding(Value) :-
        targetEnding_fact := Value.

%
class facts
    lifeLength_fact : integer := 100.

clauses
    %
    getLifeLength() = lifeLength_fact.
    
    %
    setLifeLength(Value) :-
        lifeLength_fact := Value.

%
class facts
    mainLoggerType_fact : logger::logtype := logger::xhtml().

clauses
    %
    getMainLogType() = mainLoggerType_fact.
    
    %
    setMainLogType(LogType) :-
        mainLoggerType_fact := LogType.
        
%
class facts
    fuzzyMindResolution_fact : unsigned := 50.

clauses
    %
    getFuzzyMindResolution() = fuzzyMindResolution_fact.
    
    %
    setFuzzyMindResolution(Resolution) :-
        fuzzyMindResolution_fact := Resolution.

class facts
    filenamePrefix_logMain : string := "simulateLife ".

clauses
    %
    getMainLogFilenamePrefix() = filenamePrefix_logMain.
    
    %
    setMainLogFilenamePrefix(Prefix) :-
        filenamePrefix_logMain := Prefix.
        
class facts
    filenamePrefix_logActionList : string := "actionlist ".

clauses
    %
    getActionListLogFilenamePrefix() = filenamePrefix_logActionList.
    
    %
    setActionListLogFilenamePrefix(Prefix) :-
        filenamePrefix_logActionList := Prefix.

class facts
    isDumpReality_fact : boolean := true().
    filename_logRealityState : string := "reality init report".

clauses
    %
    getRealityStateLogFilename() = filename_logRealityState.
    
    %
    setRealityStateLogFilename(Filename) :-
        filename_logRealityState := Filename.

    %
    isDumpReality() :-
        isDumpReality_fact = true().

    %
    setIfDumpReality(State) :-
        isDumpReality_fact := State.
        
/* 
% Возможность сбросить дамп информации о классе individual нереализуема, так как требует обращения из core_logic непосредственно 
%   к какому-либо предикату класса individual, что не предусмотрено архитектурой каркаса системы.
% По этой же причине закомменированы соответствующие dump- предикаты в классе alife.

class facts
    isDumpIndividualClass_fact : boolean := false().
    filename_logIndividualClass : string := "individ class details".
    
clauses
    %
    isDumpIndividualClass() :-
        isDumpIndividualClass_fact := true().
    
    %
    setIsDumpIndividualClass(State) :-
        isDumpIndividualClass_fact := State.

    %
    getIndividualClassLogFilename() = filename_logIndividualClass.
    
    %
    setIndividualClassLogFilename(Filename) :-
        filename_logIndividualClass := Filename.
*/
    
class facts
    isDumpCurrentIndividual_fact : boolean := false().
    filenamePrefix_logCurrentIndividual : string := "individ details: ".

clauses
    %
    isDumpCurrentIndividual() :-
        isDumpCurrentIndividual_fact = true().
    
    %
    setIfDumpCurrentIndividual(State) :-
        isDumpCurrentIndividual_fact := State.

    %
    getCurrentIndividualLogFilename() = filenamePrefix_logCurrentIndividual.
    
    %
    setCurrentIndividualLogFilename(Filename) :-
        filenamePrefix_logCurrentIndividual := Filename.
        
end implement alifeSettings
