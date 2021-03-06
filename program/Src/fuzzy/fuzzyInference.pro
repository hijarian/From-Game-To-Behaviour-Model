/*****************************************************************************



******************************************************************************/

implement fuzzyInference
    open core, fuzzySupport

constants
    className = "fuzzy/fuzzyInference".
    classVersion = "".

clauses
    classInfo(className, classVersion).

clauses
    new() :-
        resolution := 100,
        out_vars_count := 0,
        in_vars_count := 0,
        rules_count := 0.
    new(Resolution) :-
        resolution := Resolution,
        out_vars_count := 0,
        in_vars_count := 0,
        rules_count := 0.

facts
    %
    rule : (fuzzyRule FuzzyRule).

    %
    rules_count : integer := erroneous.

    %
    in_var : (fvar InputVar).

    %
    in_vars_count : integer := erroneous.

    %
    out_var : (fvar OutputVar).

    %
    out_vars_count : integer := erroneous.

    %
    resolution : unsigned := erroneous.

%
clauses
    %
    addRule(FRule) :-
        assert(rule(FRule)),
        rules_count := rules_count + 1.

    %
    addRuleList([]) :-
        !.
    addRuleList([FRule | List]) :-
        addRule(FRule),    % atomic-argument variant
        addRuleList(List).

    %
    addInVar(FVar) :-
        _ = tryGetInVar(FVar:id),
        raiseWithMessage(classInfo, "Не уникальный ID для новой входной переменной").
    addInVar(FVar) :-
        assert(in_var(FVar)),
        in_vars_count := in_vars_count + 1.

    %
    addInVarList([]) :-
        !.
    addInVarList([FVar | List]) :-
        addInVar(FVar),    % atomic-argument variant
        addInVarList(List).

    %
    addOutVar(FVar) :-
        _ = tryGetOutVar(FVar:id),
        raiseWithMessage(classInfo, "Не уникальный ID для новой входной переменной").
    addOutVar(Fvar) :-
        assert(out_var(FVar)),
        out_vars_count := out_vars_count + 1.

    %
    addOutVarList([]) :-
        !.
    addOutVarList([FVar | List]) :-
        addOutVar(FVar),    % atomic-argument variant
        addOutVarList(List).

clauses
    %
    getInVar_nd() = FVar :-
        in_var(FVar).

    %
    getOutVar_nd() = FVar :-
        out_var(FVar).

    %
    getRule_nd() = FRule :-
        rule(FRule).

clauses
    %
    tryGetInVar(FVID) = FVar :-
        in_var(FVar),
        !,
        FVar:id = FVID.

    %
    tryGetOutVar(FVID) = FVar :-
        out_var(FVar),
        !,
        FVar:id = FVID.

clauses
    %
    getInVar(FVID) = FVar :-
        in_var(FVar),
        FVar:id = FVID,
        !.
    getInVar(IncorrectID) = _DontMatter :-
        fuzzySupport::raiseWithMessage(classInfo,
            string::concat("fuzzyInference:getInVar/1-> : Не удалось извлечь входную переменную: переменная с id = ",
                toString(IncorrectID), " не определена")).

    %
    getOutVar(FVID) = FVar :-
        out_var(FVar),
        FVar:id = FVID,
        !.
    getOutVar(IncorrectID) = _DontMatter :-
        fuzzySupport::raiseWithMessage(classInfo,
            string::concat("fuzzyInference:getOutVar/1-> : Не удалось извлечь выходную переменную: переменная с id = ",
                toString(IncorrectID), " не определена")).

clauses
    clearInVar(FVarID) :-
        in_var(FVar),
        FVar:id = FVarID,
        retract(in_var(FVar)),
        !,
        in_vars_count := in_vars_count - 1.
    clearInVar(_DontMatter) :-
        !.

    removeAllOutVars() :-
        retractall(out_var(_)),
        out_vars_count := 0.

clauses
    setInVarValue(InFVarID, Value) :-
        try
            FVar = getInVar(InFVarID)
        catch NonexistentVariable_Exception do
        Msg = string::concat("fuzzyInference:setVarValue/2 : Не удалось установить новое значение для входной переменной: идентификатор ",
                toString(InFVarID), " неизвестен."),
        fuzzySupport::continueWithMessage(
            classInfo,
            NonexistentVariable_Exception,
            Msg)
        end try,
        FVar:xvalue := Value.

% Временные факты, имитирующие массив действительных чисел
facts -tempForAggregate
    tempMembership : (real) nondeterm.

% Вычисление firing strength правила с помощью оператора min/2 (предпосылки соединяются оператором AND)
% TODO: есть тема обобщить этот предикат, на использование любого оператора, заданного настройками нечёткого вывода
% <подлежит правке>
% TODO: чудовищная реализация, императивное программирование такое императивное.
predicates
    aggregate : (fuzzyRule FuzzyRule).
clauses
    aggregate(FRule):-
        retractall(tempMembership(_)),
        foreach FRule:getLHSClause_nd() = fclause(FVarID, FSetID) do
            getVarAndValueToAggregate(FVarID, FSetID, FVar, FSet),
            MembVal = FSet:get_membership(FVar:xvalue),
            assert(tempMembership(MembVal))
        end foreach,
        FRule:firing_strength := findMinTempValue().

predicates
    getVarAndValueToAggregate : (symbol FVarID, symbol FSetID, fvar FVar, fset FSet) procedure (i, i, o, o).
clauses
    getVarAndValueToAggregate(FID, FSID, FV, FS) :-
        try
            FV = getInVar(FID)
        catch NonexistentVariable_Exception do
            fuzzySupport::continueWithMessage(
                classInfo,
                NonexistentVariable_Exception,
                "fuzzyInference:getVarAndValueToAggregate/4 : Не удалось получить входную переменную для дальнейших вычислений")
        end try,
        try
            FS = FV:getTerm(FSID)
        catch SetNotDefinedForVariable_Exception do
            fuzzySupport::continueWithMessage(
                classInfo,
                SetNotDefinedForVariable_Exception,
                string::concat("fuzzyInference:getVarAndValueToAggregate/4 : Не удалось извлечь лингвистическое значение ", FSID, " из входной переменной ", FV:id, " для дальнейших вычислений"))
        end try.

% временное значение для предиката findMinTempValue/0->
facts
    minValue : real := erroneous.

% Предикат-обёртка для алгоритма нахождения минимального значения из множества фактов tempMembership : (real)
predicates
    findMinTempValue : () -> real MinTempValue.
clauses
    findMinTempValue() = minValue:-
        tempMembership(MVT),
        !,
        minValue := MVT,
        foreach tempMembership(MVTT) do
            if MVTT < minValue
                then
                    minValue := MVTT
            end if
        end foreach.
    findMinTempValue() = 0.0.

% Предикаты для базовой манипуляции нечётким выводом:
%   - производим аггрегацию всех правил
%   - оцениваем все выходные переменные
%   - дефаззифицируем все выходные переменные
clauses
    % Выполнить аггрегацию для всех правил в нечётком выводе
    aggregateAll() :-
        foreach rule(FRule) do
            aggregate(FRule)
        end foreach.

    % Оценить все выходные переменные
    evaluateAll() :-
        aggregateAll(),
        foreach out_var(FVar) do
            FSet = evaluate(FVar:id),
            FVar:fvalue := FSet
        end foreach.

clauses
    defuzzy(FVar) :-
        try    % (fvalue может быть erroneous)
            FSet = FVar:fvalue
        catch ErroneousValueException do
            MsgEVE = string::concat(
                "fuzzySupport:defuzzy/1 : Не удалось произвести дефаззификацию переменной ", FVar:id,
                ": отсутствует нечёткое значение"),
            fuzzySupport::continueWithMessage(
                classInfo,
                ErroneousValueException,
                MsgEVE)
        end try,
        try    %  (center_of_gravity/2-> может вылететь с ошибкой)
            FVar:xvalue := FSet:center_of_gravity(FVar:xmin, FVar:xmax)
        catch ErrorInCoGFunction do
            MsgEICF = string::concat(
                "fuzzySupport:defuzzy/1 : Не удалось произвести дефаззификацию переменной ", FVar:id,
                ": ошибка в методе дефаззификации"),
            fuzzySupport::continueWithMessage(
                classInfo,
                ErrorInCoGFunction,
                MsgEICF)
        end try.

    % Выполнить дефаззификацию для всех выходных переменных
    defuzzyAll() :-
        foreach out_var(FVar) do
            defuzzy(FVar)
        end foreach.

    %
    defuzzy_byIDList([]) :-
        !.
    defuzzy_byIDList([ID | OtherIDs]) :-
        defuzzy(getOutVar(ID)),
        defuzzy_byIDList(OtherIDs).

% Оценить только те нечёткие переменные, которые перечислены в переданном списке идентификаторов
clauses
    evaluate_byIDList([]) :-
        !.
    evaluate_byIDList([FVarID | OtherIDs]) :-
        FSet = evaluate(FVarID),
        FVar = getOutVar(FVarID),
        FVar:fvalue := FSet,
        evaluate_byIDList(OtherIDs).

facts
% Временное нечёткое множество для предиката evaluate/1->
    tempFSet : fset := erroneous.

clauses
    % Оценить переменную согласно всем записанным в базе правил правилам, в которых эта переменнная
    %    находится в правой части (последствии)
    evaluate(FVarID) = ResultFSet :-
        tempFSet := fset_ByArray::new("EvaluationResult"),
        try
            FVar = getOutVar(FVarID)
        catch NonexistentVariable_Exception do
            NEVMsg = string::concat("fuzzyInference:evaluate/1-> : Не удалось извлечь нечёткую переменную: ID ",
                toString(FVarID), " неизвестен."),
            fuzzySupport::continueWithMessage(
                    classInfo,
                    NonexistentVariable_Exception, 
                    NEVMsg)
        end try,
        foreach rule(FRule) do
            if FRule:firing_strength > 0
                then
                    foreach fclause(FVarID, FSetID) = FRule:getRHSClause_nd() do
                        try
                            FValue = FVar:getTerm(FSetID)
                        catch SetNotDefinedForVariable_Exception do
                            SNDMsg = string::concat("fuzzyInference:evaluate/1-> : Не удалось извлечь лингвистическое значение ", FSetID, " из нечёткой переменной ", FVarID, ": недоопределённая переменная"),
                            fuzzySupport::continueWithMessage(
                                    classInfo,
                                    SetNotDefinedForVariable_Exception,
                                    SNDMsg)
                        end try,
% Собственно, содержательная часть :) Вычисление нечёткого значения
                        FSetTmp = inference(FVar, FValue, FRule:firing_strength),
% TODO Здесь используется оператор max. Можно заменить на обобщение - для любого оператора T-нормы.
                        tempFSet := getMaxFSet(FSetTmp, tempFSet)
                    end foreach
            end if
        end foreach,
        ResultFSet = tempFSet.

/*
predicates
    getVarAndValueToInfer_nd : (fuzzyRule FRule, symbol FVarID, fvar FVar, fset FSet) nondeterm (i, i, o, o).
clauses
    getVarAndValueToInfer_nd(FRule, FID, FV, FS) :-
        fclause(FID, FSID) = FRule:getRHSClause_nd(),    
        % в этом месте перебираем все вышеперечисленные сущности
        try
            FV = getOutVar(FID)
        catch NonexistentVariable_Exception do
            NEVMsg = string::concat("fuzzyInference:getVarAndValueToInfer_nd/3 : Не удалось извлечь нечёткую переменную: ID ",
                    toString(FID), " неизвестен."),
            fuzzySupport::continueWithMessage(
                    classInfo,
                    NonexistentVariable_Exception,
                    NEVMsg)
        end try,
        try
            FS = FV:getTerm(FSID)
        catch SetNotDefinedForVariable_Exception do
            SNDMsg = string::concat("fuzzyInference:getVarAndValueToInfer_nd/3 : Не удалось извлечь лингвистическое значение ", FSID, " из нечёткой переменной ", FID, ": недоопределённая переменная"),
            fuzzySupport::continueWithMessage(
                    classInfo,
                    SetNotDefinedForVariable_Exception,
                    SNDMsg)
        end try.
*/

    % Нечёткий вывод для переменной FVar: определение её принадлежности заданному нечёткому множеству FSet
    inference(FVar, FSet, Match) = ResultFSet :-
        ResultFSet = fset_ByArray::new("InferenceResult"),
        VD = (FVar:xmax - FVar:xmin) / This:resolution,
        addPointsToFSet(FVar:xmin, VD, FSet, Match, This:resolution, ResultFSet).

predicates
    % Служебный предикат, для добавления набора вычисляемых на ходу точек к нечёткому множеству
    % Смысл такой: нечёткое множество SetToMatch отображается в ResultFSet - дискретизированное приближение
    %   её самой, помноженное на MatchCoefficient
    addPointsToFSet : (
            real XMin,    % Абсцисса самой левой точки из нужного множества
            real XStep,    % Приращение к абсциссе при перемещении по множеству точек вправо
            fset SetToMatch,    % С помощью функции принадлежности этого нечёткого множества будем находить ординаты искомых точек
            real MatchCoefficient,   % На это умножим ординату перед тем, как добавить точку в ResultFSet
            unsigned PointCount,    % Сколько точек набить в ResultFSet
            fset_ByArray ResultFSet    % Нечёткое множество, чья функция принадлежности будет описана набором вычисляемых этим предикатом точек
            ).

clauses
    % Воспользуемся рекурсией, дабы добавить PointNum точек к нечёткому множеству ResultFSet
    addPointsToFSet(_XM, _XD, _FSet, _MC, 0, _ResultFSet) :-
        !.
    addPointsToFSet(XM, XD, FSet, MC, PointNum, ResultFSet) :-
        XVal = XM + XD * (PointNum - 1),
        YVal = FSet:get_membership(XVal) * MC, % Умножение может быть заменено на другой оператор
        ResultFSet:setPoint(XVal, YVal),
        addPointsToFSet(XM, XD, FSet, MC, PointNum - 1, ResultFSet).

end implement fuzzyInference
