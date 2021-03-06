/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

interface individual
    open core

domains
    paramChange = core::tuple{symbol ParamID, real ValueChange}.
    paramChangeList = paramChange*.

predicates
    % Создаём первоначальные значения параметров особи на основе генома клетки
    init : (cell::phenotype CellPhenotype) procedure (i).
    
    % Получаем на основе самооценки состояния список действий,
    %   из которых надо выбирать наиболее приоритетное.
    getActionsToPrioritize : () -> symbol* ActionsAsFVarList procedure.
    
    % Совершение действия. На выходе получаем изменения значений параметров,
    %   изменившихся в результате действия.
    doAction : (symbol ActionID) -> paramChangeList ChangedParameterList procedure (i).
    
    % Получить параметры особи, фаззифицированные (оценённые) самой особью
    getFuzzifiedParams : () -> fvar* ParametersAsFVars procedure.
    
    %
    getParameterData : (symbol ParamID, real ParamValue, real ParamMin, real ParamMax) procedure (i, o, o, o).
    
    %
    getParameterData_nd : (symbol ParamID, real ParamValue, real ParamMin, real ParamMax) nondeterm (o, o, o, o).
    
    %
    getSelfDescription : () -> string IndividObjectDescription procedure.
    
    %
    getClassDescription : () -> string IndividDescription procedure.
        
end interface individual
