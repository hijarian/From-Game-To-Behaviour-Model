/*****************************************************************************



******************************************************************************/

implement fuzzySupport
    open core

constants
    className = "fuzzy/fuzzySupport".
    classVersion = "".

clauses
    classInfo(className, classVersion).

%------------------------------------------------------------------------------
% Создание правил

%
clauses
    %
    createSimpleRule(PID, PTID, AID, ATID) = FuzzyRule :-
        FuzzyRule = fuzzyRule::new(),
        FuzzyRule:addToLHS(fuzzySupport::fclause(PID, PTID)),
        FuzzyRule:addToRHS(fuzzySupport::fclause(AID, ATID)).


%------------------------------------------------------------------------------
% Обработка исключений (только создание и продолжение)

constants
    error_message_signature : symbol = "Designer's Notes".

class predicates
    continueWithMessage : (exception::traceId E, string Message) erroneous.
clauses
    continueWithMessage(E, Msg) :-
        exception::continue(
                E,
                classInfo,
                runtime_exception::internalError,
                [namedValue(error_message_signature, string(Msg))]).

clauses
    continueWithMessage(CI, E, Msg) :-
        exception::continue(
                E,
                CI,
                runtime_exception::internalError,
                [namedValue(error_message_signature, string(Msg))]).

class predicates
    raiseWithMessage : (string Message) erroneous.
clauses
    raiseWithMessage(Msg) :-
        exception::raise(
                    classInfo,
                    runtime_exception::internalError,
                    [namedValue(error_message_signature, string(Msg))]).

clauses
    raiseWithMessage(CI, Msg) :-
        exception::raise(
                    CI,
                    runtime_exception::internalError,
                    [namedValue(error_message_signature, string(Msg))]).


%------------------------------------------------------------------------------
% Вывод объектов нечёткого вывода на консольное окно

class facts
    tempString : string := "".

clauses
    %
    debugRules(InfEng) :-
        foreach Rule = InfEng:getRule_nd() do
            console::write(toString_frule(Rule)), 
            console::nl()
        end foreach.

    toString_frule(Rule) = RuleAsString :-
        tempString := "-- Правило: \n---- Предпосылки: \n",
        foreach fclause(FInVarID, FInValID) = Rule:getLHSClause_nd() do
            tempString := string::concat(tempString, "If ", FInVarID, " is ", FInValID, "\n")
        end foreach,
        tempString := string::concat(tempString, "---- Последствия: \n"),
        foreach fclause(FOutVarID, FOutValID) = Rule:getRHSClause_nd() do
            tempString := string::concat(tempString, "then ", FOutVarID, " is ", FOutValID, "\n")
        end foreach,
        tempString := string::concat(tempString, "---- Истинность правила: ", toString(Rule:firing_strength), "\n"),
        RuleAsString = tempString.

clauses
    %
    debugFVar(FVar) :-
        console::write(toString_fvar(FVar)).

    %
    toString_fvar(FVar) = FVarAsString :-
        FVarAsString_1 = string::concatList([
            "-- Переменная: \n",
            "  ID: ", toString(FVar:id), "\n",
            "  xmin: ", toString(FVar:xmin), "\n",
            "  xmax: ", toString(FVar:xmax), "\n",
            "  crisp value: ", toString(FVar:xvalue), "\n",
            "---- Нечёткое значение: \n",
            toString_fset(FVar:fvalue),
            "---- Лингвистические значения: \n"]),
        tempString := "",
        foreach FVar:getTerm_nd(TermID, TermFSet) do
            tempString := string::concat(tempString, "\"", TermID, "\", соответствует нечёткому множеству: \n"),
            tempString := string::concat(tempString, toString_fset(TermFSet), "\n")
        end foreach,
        FVarAsString = string::concat(FVarAsString_1, tempString).

clauses
    %
    debugFSet(FSet) :-
        console::write(toString_fset(FSet)).
        
    %
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_byArray, FSetI),    % Если множество - заданное массивом точек
        !,
        tempString := string::concat(toString(FSet:id), ": fuzzy set by array\n"),
        foreach FSet:getPoint(X, Y) do
            tempString := string::concat(tempString, "  MF(", toString(X), ") = ", toString(Y), "\n")
        end foreach,
        FSetAsString = tempString.
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_LR, FSetI),    % Если множество задано треугольной функцией
        FSet:membership_function = mff(triangleMF, [A, B, C | _ ]),
        !,
        FSetAsString = string::format("%s: fuzzy set by triangle MF\nA = %.3f, B = %.3f, C = %.3f", FSet:id, A, B, C).
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_LR, FSetI),    % Если множество задано открытой слева треугольной функцией
        FSet:membership_function = mff(triangleLMF, [A, B | _ ]),
        !,
        FSetAsString = string::format("%s: fuzzy set by left-opened triangle MF\nA = %.3f, B = %.3f", FSet:id, A, B).
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_LR, FSetI),    % Если множество задано открытой справа треугольной функцией
        FSet:membership_function = mff(triangleRMF, [A, B | _ ]),
        !,
        FSetAsString = string::format("%s: fuzzy set by right-opened triangle MF\nA = %.3f, B = %.3f", FSet:id, A, B).
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_LR, FSetI),    % Если множество - задано трапециевидной функцией
        FSet:membership_function = mff(trapezoidMF, [A, B, C, D | _ ]),
        !,
        FSetAsString = string::format("%s: fuzzy set by trapezoid MF\nA = %.3f, B = %.3f, C = %.3f, D = %.3f", FSet:id, A, B, C, D).
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_LR, FSetI),    % Если множество - задано сигмоидальной функцией
        FSet:membership_function = mff(sigmoidMF, [A, B | _ ]),
        !,
        FSetAsString = string::concatList([
                toString(FSet:id), ": fuzzy set by sigmoid MF\n",
                "  A = ", toString(A), "\n  B = ", toString(B), "\n"]).
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_LR, FSetI),    % Если множество - задано гауссовой функцией
        FSet:membership_function = mff(gaussianMF, [A, B | _ ]),
        !,
        FSetAsString = string::concatList([
                toString(FSet:id), ": fuzzy set by gaussian MF\n",
                "  A = ", toString(A), "\n  B = ", toString(B), "\n"]).
    toString_fset(FSetI) = FSetAsString :-
        FSet = tryConvert(fset_LR, FSetI),    % Если множество - задано колоколообразной функцией
        FSet:membership_function = mff(bellMF, [A, B, C | _ ]),
        !,
        FSetAsString = string::concatList([
                toString(FSet:id), ": fuzzy set by bell MF\n",
                "  A = ", toString(A), "\n  B = ", toString(B), "\n  C = ", toString(C), "\n"]).
    toString_fset(UnknownFSet) = ErrorMessage :-
            ErrorMessage = string::concat(toString(UnknownFSet:id), ": custom fuzzy set (cannot print properly)\n").

clauses
    toString_fclauseList([]) = "" :-
        !.
    toString_fclauseList([FClause | OtherFClauses]) = string::concat(Description_Head, Description_Tail) :-
        Description_Head = toString_fclauseList(OtherFClauses),
        Description_Tail = string::concat(toString_fclause(FClause), "\n").

clauses
    toString_fclause(fuzzySupport::fclause(VarID, VarTermID)) = Desc :-
        Desc = string::format("%s: %s", VarID, VarTermID).



%------------------------------------------------------------------------------
% Пресозданные функции принадлежности
clauses
% Открытая справа MF. Для того, чтобы она была открыта слева, A должно быть отрицательным.
    sigmoidMF(X, [A, C | _AnyOtherArgs]) = MFValue :-
        try
            MFValue = 1/(1 + math::exp(-A * (X - C)))
        catch E do
            continueWithMessage(E, "Сигмоидальная функция не смогла выполниться")
        end try,
        !.
    sigmoidMF(_X, _MFInvalidParams) = _ :-
        raiseWithMessage("Неверные параметры для сигмоидальной функции").

clauses
% Очень дословное определение треугольной MF, возможно, излишне
    triangleMF(X, [A, _B, _C | _AnyOtherArgs]) = 0 :-
        X <= A,
        !.
    triangleMF(X, [A, B, _C | _AnyOtherArgs]) = MFVal :-
        X > A,
        X < B,
        try
            MFVal = (X - A)/(B - A)    % A <> B !!, не трогать вышеуказанные условия!
        catch E do
            continueWithMessage(E, "Треугольная функция принадлежности не смогла выполниться")
        end try,
        !.
    triangleMF(X, [_A, B, _C | _AnyOtherArgs]) = 1 :-
        X = B,
        !.
    triangleMF(X, [_A, B, C | _AnyOtherArgs]) = MFVal :-
        X > B,
        X < C,
        try
            MFVal = (C - X)/(C - B)    % C <> B !!, не трогать вышеуказанные условия!
        catch E do
            continueWithMessage(E, "Треугольная функция принадлежности не смогла выполниться")
        end try,
        !.
    triangleMF(X, [_A, _B, C | _AnyOtherArgs]) = 0 :-
        X >= C,
        !.
    triangleMF(_X, _MFInvalidParams) = _ :-
        raiseWithMessage("Неверные параметры для треугольной функции").

clauses
% "Открытая слева" треугольная функция принадлежности.
% f(x; A, B) = 1, x <= A
% f(x; A, B) = (B - X)/(B - A), A < x < B, т. е., прямая линия от точки (A, 1) до (B, 0).
% f(x; A, B) = 0, x >= B.
    triangleLMF(X, [A, _B | _AnyOtherArgs]) = 1 :-
        X <= A,
        !.
    triangleLMF(X, [A, B | _AnyOtherArgs]) = MFVal :-
        X > A,
        X < B,
        try
            MFVal = (B - X)/(B - A)    % B <> A !!
        catch E do
            continueWithMessage(E, "Открытая слева треугольная функция принадлежности не смогла выполниться")
        end try,
        !.
    triangleLMF(X, [_A, B | _AnyOtherArgs]) = 0 :-
        X >= B,
        !.
    triangleLMF(_X, _MFInvalidParams) = _ :-
        raiseWithMessage("Неверные параметры для открытой слева треугольной функции").

clauses
% "Открытая справа" треугольная функция принадлежности.
% f(x; A, B) = 0, x <= A
% f(x; A, B) = (X - A)/(B - A), A < x < B, т. е., прямая линия от точки (A, 0) до (B, 1).
% f(x; A, B) = 1, x >= B.
    triangleRMF(X, [A, _B | _AnyOtherArgs]) = 0 :-
        X <= A,
        !.
    triangleRMF(X, [A, B | _AnyOtherArgs]) = MFVal :-
        X > A,
        X < B,
        try
            MFVal = (X - A)/(B - A)    % B <> A !!
        catch E do
            continueWithMessage(E, "Открытая слева треугольная функция принадлежности не смогла выполниться")
        end try,
        !.
    triangleRMF(X, [_A, B | _AnyOtherArgs]) = 1 :-
        X >= B,
        !.
    triangleRMF(_X, _MFInvalidParams) = _ :-
        raiseWithMessage("Неверные параметры для открытой справа треугольной функции").

clauses
% Очень дословное определение трапециевидной MF, возможно, излишне
    trapezoidMF(X, [A, _B, _C, _D | _AnyOtherArgs]) = 0 :-
        X <= A,
        !.
    trapezoidMF(X, [A, B, _C, _D | _AnyOtherArgs]) = MFVal :-
        X > A,
        X < B,
        try
            MFVal = (X - A)/(B - A)    % B <> A !!, не трогать вышеуказанные условия!
        catch E do
            continueWithMessage(E, "Трапециевидная функция принадлежности не смогла выполниться")
        end try,
        !.
    trapezoidMF(X, [_A, B, C, _D]) = 1 :-
        X >= B,
        X <= C,
        !.
    trapezoidMF(X, [_A, _B, C, D]) = MFVal :-
        X > C,
        X < D,
        try
            MFVal = (D - X)/(D - C)    % D <> C !!, не трогать вышеуказанные условия!
        catch E do
            continueWithMessage(E, "Трапециевидная функция принадлежности не смогла выполниться")
        end try,
        !.
    trapezoidMF(X, [_A, _B, _C, D]) = 0 :-
        X >= D,
        !.
    trapezoidMF(_X, _InvalidMFParams) = _ :-
        raiseWithMessage("Неверные параметры для трапециевидной функции").

clauses
    gaussianMF(X, [C, D]) =  MFVal:-
        try
            MFVal = math::exp((-1) * math::sqr((X - C)/D))
        catch E do
            continueWithMessage(E, "Гауссова функция не смогла выполниться")
        end try,
        !.
    gaussianMF(_X, _InvalidMFParams) = _ :-
        raiseWithMessage("Неверные параметры для гауссовой функции").

clauses
    bellMF(X, [A, B, C]) =  MFVal :-
        try
            MFVal = 1 / ( 1 + ((X - C) / A) ^ (2 * B) )
        catch E do
            continueWithMessage(E, "Обобщённая колоколообразная функция не смогла выполниться")
        end try,
        !.
    bellMF(_X, _InvalidMFParams) = _ :-
        raiseWithMessage("Неверные параметры для обобщённой колоколообразной функции").

%------------------------------------------------------------------------------
% Оператор максимума
clauses
% Пока что максимум определён только для fset_ByArray
    getMaxFSet(FSetA, FSetB) = MaxFSet :-
        FSetAA = tryConvert(fset_ByArray, FSetA),
        !,
        MaxFSet = fset_ByArray::new("ResultOfMaxOperator"),
        foreach FSetAA:getPoint(Xa, Ya) do
            Yb = FSetB:get_membership(Xa),
            if Yb > Ya
                then MaxFSet:setPoint(Xa,Yb)
                else MaxFSet:setPoint(Xa, Ya)
            end if
        end foreach.
    getMaxFSet(_FSetA, _FSetB) = _MaxFSet :-
        raiseWithMessage("Оператор максимума для произвольных нечётких множеств ещё не определён!").


end implement fuzzySupport