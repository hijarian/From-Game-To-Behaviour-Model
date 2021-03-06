/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

interface reality
    open core
    
predicates
    %
    init : () procedure.

    % Загрузка в реальность параметров особи, фаззифицированных согласно 
    %   свойствам реальности
    fuzzyParamsFromIndivid : (individual Individ).
    
    %
    getRules : () -> fuzzyRule* RealityRules.

    %
    getActions : () -> fvar* PossibleActions.
    
    %
    getVar : (symbol FVarID) -> fvar FVar.
    
    %
    getRealityDescription : () -> string RealityDescription.
    
end interface reality
