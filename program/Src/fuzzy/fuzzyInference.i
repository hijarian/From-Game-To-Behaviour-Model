/*****************************************************************************



******************************************************************************/

interface fuzzyInference
    open core

predicates
    %
    addRule : (fuzzyRule FRuleToAdd).

    %
    addRuleList : (fuzzyRule* FRulesToAdd).

    %
    addInVar : (fvar FVarToAdd).

    %
    addInVarList : (fvar* FVarsToAdd).

    %
    addOutVar : (fvar FvarToAdd).

    %
    addOutVarList : (fvar* FVarsToAdd).

predicates
    %
    getRule_nd : () -> fuzzyRule FRuleToGet nondeterm.

    %
    getInVar_nd : () -> fvar FVarToGet nondeterm.

    %
    getOutVar_nd : () -> fvar FvarToGet nondeterm.

predicates
    %
    getInVar : (symbol FVarID) -> fvar FVar.

    %
    getOutVar : (symbol FVarID) -> fvar FVar.

predicates
    %
    tryGetInVar : (symbol FVarID) -> fvar FVar determ.

    %
    tryGetOutVar : (symbol FVarID) -> fvar FVar determ.

predicates
    % Убирает входную переменную по её идентификатору и не проваливается в случае её отсутствия
    clearInVar : (symbol FVarID) procedure.

    % Удаляет все выходные переменные
    removeAllOutVars : () procedure.

properties
    %
    rules_count : integer (o).

    %
    in_vars_count : integer (o).

    %
    out_vars_count : integer (o).

    % Частота дискретизации нечётких множеств - результатов данного нечёткого вывода
    %   (результатами предикатов inference/3-> и evaluate/2-> являются объекты fset_ByArray) (пока)
    resolution : unsigned.

predicates
    %
    setInVarValue : (symbol VarID, real Value).

predicates
    %
    inference : (fvar FVar, fset FSet, real Match) -> fset ResultFValue.

    %
    evaluate : (symbol FVarID) -> fset ResultFSet.

    %
    evaluate_byIDList : (symbol* FVarIDList).

    %
    defuzzy : (fvar FVar).

    %
    defuzzy_byIDList : (symbol* FVarIDList).

    %
    aggregateAll : ().

    %
    evaluateAll : ().

    %
    defuzzyAll : ().

end interface fuzzyInference