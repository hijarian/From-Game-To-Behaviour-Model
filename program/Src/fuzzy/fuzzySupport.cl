/*****************************************************************************



******************************************************************************/
class fuzzySupport
    open core

predicates
    classInfo : core::classInfo.

%------------------------------------------------------------------------------
% Нечёткое утверждение вида
%  FVar is FSet
domains
    fClause = fclause(symbol FVarID, symbol FSetID).

%------------------------------------------------------------------------------
% predicate domains для функций принадлежности
domains
    mf = (real XValue, real* FunctionArguments) -> real MembershipValue. % Функция принадлежности
    mf_stored = mff(mf Function, real* Arguments). % Сборный домен для хранения функции принадлежности

/*
Заранее определённые заготовки параметризованных функций принадлежности
  для использования их при определении термов
*/
predicates
    sigmoidMF : mf.    % 2 аргумента, открытая в зависимости от 1го арг-та слева или справа
    triangleMF : mf.    % 3 аргумента
    triangleLMF : mf.    % 2 аргумента, открытая слева
    triangleRMF : mf.    % 2 аргумента, открытая справа
    trapezoidMF : mf.    % 4 аргумента
    gaussianMF : mf.    % 2 аргумента
    bellMF : mf.    % 3 аргумента

%------------------------------------------------------------------------------
/*
Заранее собранные предикаты для работы с ошибками
*/
predicates
% Re-raising, класс, вызывающий этот предикат передаёт СВОЁ ClassInfo
    continueWithMessage : (core::classInfo ClassInfo, exception::traceId E, string Message) erroneous.

% Raising, класс, вызывающий этот предикат передаёт СВОЁ ClassInfo
    raiseWithMessage : (core::classInfo ClassInfo, string Message) erroneous.

%------------------------------------------------------------------------------
/*
Заранее подготовленные операторы над нечёткими множествами
*/
predicates
% Оператор нахождения максимума
% Больше предпочтения отдаёт множеству FSetA;
%   если FSetB определён более подробно (гладко), вызывать с обратным порядком аргументов
    getMaxFSet : (fset FSetA, fset FSetB) -> fset MaxFSet.


%------------------------------------------------------------------------------
/*
Заранее подготовленные удобные обёртки для создания нечётких правил
*/
predicates
    % Создание простого правила, из одной предпосылки и одного последствия
    createSimpleRule : (symbol ParamID, symbol ParamTermID, symbol ActionID, symbol PriorityTermID) -> fuzzyRule FuzzyRule procedure (i, i, i, i).

%------------------------------------------------------------------------------
/*
% Вывод объектов нечёткого вывода на консоль
*/
predicates
    %
    toString_fvar : (fvar FVarToString) -> string FVarAsString procedure (i).
    
    %
    toString_fset : (fset FSetToString) -> string FSetAsString procedure (i).
    
    %
    toString_frule : (fuzzyRule FRuleToString) -> string FRuleAsString procedure (i).
    
    %
    toString_fclauseList : (fuzzySupport::fclause* FClauseList) -> string Description procedure (i).
    
    %
    toString_fclause : (fuzzySupport::fclause FClause) -> string Description procedure (i).

%------------------------------------------------------------------------------
/*
% Вывод объектов нечёткого вывода на консоль
*/
predicates
    %
    debugRules : (fuzzyInference InferenceEngine).

    %
    debugFVar : (fvar FVarToDebug).

    %
    debugFSet : (fset FSetToDebug).

end class fuzzySupport