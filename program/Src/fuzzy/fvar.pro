/*****************************************************************************

                         

******************************************************************************/

implement fvar
    open core

constants
    className = "fuzzy/fvar".
    classVersion = "".

clauses
    classInfo(className, classVersion).

facts -data_model   
    % Идентификатор переменной
    id : symbol := erroneous.
    
    % Множество лингвистических значений (именованных нечётких множеств) - термов
    term : (symbol TermId, fset TermFuzzySet).
    
    % Хранимое нечёткое значение переменной (оно СОВСЕМ НЕ ОБЯЗАТЕЛЬНО дефаззифицируется в значение varXvalue)
    varFvalue : fset := erroneous.
    
    % Хранимое чёткое значение переменной
    varXvalue : real := erroneous. % до явного присваивания чёткого значения вычислять принадлежность для переменной нельзя!
    
    % Хранимое значение минимума универсума дискурса
    varXmin : real := erroneous.
    
    % Хранимое значение максимума универсума дискурса
    varXmax : real := erroneous.

clauses
% Конструктор: имя, минимум и максимум универсума дискурса
    new(ID, XMin, XMax) :-
        id := ID,
        varXmin := XMin,
        varXmax := XMax.
        
clauses
% Нечёткое значение
    fvalue() = Value :-
        try
            Value = varFvalue
        catch _NotEvaluated_Exception do
            Value = fset_byArray::new("nonevaluated")
        end try.
    fvalue(FSet) :-
        varFvalue := FSet.

% Чёткое значение    
    xvalue() = varXvalue.
    xvalue(XVal) :-
        varXvalue := XVal.

% Максимум универсума дискурса        
    xmax() = varXmax.
    xmax(XM) :-
        varXMax := XM.
        
% Минимум универсума дискурса        
    xmin() = varXmin.
    xmin(XM) :-
        varXMin := XM.

clauses
    % Добавление терма в термсет (нельзя добавлять термы с одинаковыми идентификаторами!)
    % <закончено> 
    addTerm(TermId, _DontMatter) :-
        term(TermId, _AlsoDontMatter),
        fuzzySupport::raiseWithMessage(
            classInfo,
            string::concat("fvar:addTerm/2 : Не удалось добавить лингвистическое значение для переменной ", toString(id), ": терм с идентификатором ", toString(TermId), " уже существует")).
    addTerm(TermId, SetToAdd) :-
        assert(term(TermId, SetToAdd)). 

    %
    %
    addTermList([]) :-
        !.
    addTermList([core::tuple(TermID, SetToAdd) | OtherTuples]) :-
        addTerm(TermID, SetToAdd),
        addTermList(OtherTuples).

   % Извлечение нечёткого множества для терма с требуемым идентификатором
   % <закончено>
    tryGetTerm(SetId) = ReturnSet :-
        term(SetId, ReturnSet),
        !. % игнорируем термы с такими же идентификаторами, такое может появиться только в результате ошибки моделирования
       
   % Извлечение нечёткого множества для терма с требуемым идентификатором
   % <закончено>
    getTerm(SetId) = ReturnSet :-
        term(SetID, ReturnSet),
        !.
    getTerm(IncorrectSetID) = _DontMatter :-
        Msg = string::concat("fvar:getTerm/1-> : Не удалось получить лингвистическое значение: для переменной с ID = ", toString(id),
                " не определено лингвистическое значение, обладающее ID = ", toString(IncorrectSetID)),
        fuzzySupport::raiseWithMessage(classInfo, Msg).
    
    getTerm_nd(TermID, TermFSet) :-
        term(TermID, TermFSet).
       
    % Попытка получить значение принадлежности чёткого значения переменной заданному терму
    % <закончено>
    tryGetMembership(SetId) = MembershipValue :-
        term(SetId, FSet),
        !,
        MembershipValue = FSet:get_membership(This:xvalue).

end implement fvar
