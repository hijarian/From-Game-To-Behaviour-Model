/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement individual
    open core, fuzzySupport

constants
    className = "user_logic/individual".
    classVersion = "".

clauses
    classInfo(className, classVersion).

%
constants
    %
    error_signature : symbol = "User logic error".

    %
    max_param_value : integer = 900.

    %
    max_stress_lv : integer = 100.

    %
    max_money_quantity : integer = 10000.

    %
    max_inclination_value : integer = 3.
    
    % Коэффициент, участвующий в вычислении значения изменений параметров в результате выполнения действий
    % Грубо - влияет на количество повторений действия, которое требуется совершить особи для максимизации параметра, 
    %   который увеличивает данное действие.
    param_change_degree : real = 0.002.
    
    % То же самое, что и param_change_degree, только для конкретного параметра - стресса
    stress_change_degree : real = 0.02.

% Конструктор по умолчанию
clauses
    new() :-
        succeed().

%
facts -parameters
    % Наклонности; являются параметрами первого рода, поэтому выделены особо
    incl : (symbol ID, unsigned Value).

    % Значения параметров; выделены отдельно, так как будет много assert'ов и retract'ов
    param : (symbol ID, real Value).

    % Ограничения значений параметров; сохраняются, так как при фаззификации требуется
    %   создавать нечёткие переменные, которые учитывают границы универсума дискурса
    paramConstraint : (symbol ID, real MinValue, real MaxValue).

    %
    age : integer := erroneous.

%
facts -inclinationsWeight
    inclWt : ( % Связь параметра и влияний на него склонностей
        symbol Param
       ,real Phys
       ,real Cogn
       ,real Creat
       ,real Masc
       ,real Fem
       ,real Intr
       ,real Sex
       ,real Aggr
        ).

%
facts -temp
    %
    tempChanges_fact : paramChangeList := erroneous.

    %
    tempFVarList : fvar* := erroneous.

% TODO HARD-CODING WARNING! Заменить ВСЁ на вызов парсера внешних источников данных
% Пресозданная таблица влияния склонностей на характеристики
clauses 
    % inclWt(AttrName, Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr)
	inclWt("attrSTR", 1.7, 0, 0, 1.1, 1, 0, 0, 1.1).
	inclWt("attrCON", 1.7, 0, 0, 1, 1.1, 0, 1.1, 0).
    inclWt("attrINT", 0, 1.7, 1, 1, -0.9, 1.4, -1.3, 0).
    inclWt("attrREF", 0, 0, 1, -1, 1.7, 0, 1, -0.3).
    inclWt("attrCHA", 0, 1, 0, -1.7, 1.3, 0, 1.7, 0.3).
    inclWt("attrETH", 0, 1.7, -1, 1.3, 0, 1, 0, 1).
    inclWt("attrAMR", 0, 0, 0, 0, -1.7, 0, 1.7, 1.7).    % т. к. аморальность имеет обратную ценность, тут можно ещё подумать.
    inclWt("attrSEN", 0, -1.3, 1.7, -1, 1, 1.1, 0, 0).
%
	inclWt("skillDec", 0, 1, 1, 0.6, 1.3, 1, -1.3, -0.7).
	inclWt("skillArt", 0, 1, 1.7, 0, 1, 0.7, 0, -0.7).
    inclWt("skillConv", 0, 1.3, 0.5, 0, 0, -1, 1.2, 0).
    inclWt("skillClean", 0.3, 0, -0.7, 1, 1.3, 0, 0, -0.3).
    inclWt("skillCook", 0, 0.3, 0.3, 1, 1, 0, 0, 0).
    inclWt("skillCombSkl", 1.7, 0.3, 0, 1.3, -1, 0, 0, 1.7).
    inclWt("skillCombAtt", 1.3, 0, 0, 1, -1, 0, 0, 1.7).
    inclWt("skillCombDef", 1.3, 0, 0, 1, -1, 1, 0, -1).
    inclWt("skillMgrSkl", 0, 1.5, 1.5, -0.3, 1.3, 0, 0, 1).
    inclWt("skillMgrAtt", 0, 1.5, 1.5, -0.3, 1.3, 0, 0, 1).
    inclWt("skillMgrDef", 0, 1.5, 1.5, -1, 1.5, 1, 0, -1).
%
    inclWt("moneyQt", 0, 1.3, -1.3, 1, 1, 1.3, -1.7, -1).    % Здесь надо подумать над предположениями, скрывающимися за этими весовыми коэффициентами
    inclWt("stressLv", 0, 1.3, -1.7, 1.3, -1.3, 1.7, -1, 1).

% Инициализация особи, совершается один раз, поэтому можно особо не осторожничать.
clauses
    init([Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr | _ErroneousCode]) :-
        !,
        setInclinations(Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr),    % Создали факты с наклонностями
        createPresetParams(),    % Создали параметры как таковые
        setInitialAttributes(Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr),    % Для интереса заполнили параметры некоторыми значениями
        age := 0.
    init(_TooShortGenome) :-
        exception::raise(
                classInfo,
                runtime_exception::internalError,
                [namedValue(error_signature, string("Не удалось инициализировать особь: неверный геном"))]).


% Установка изначальных значений параметров; реализована, чтобы было интереснее: каждая особь будет начинать со своих стартовых условий. 
%   Принципиально для системы не нужна
predicates
    setInitialAttributes : (unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned).
clauses
    setInitialAttributes(Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr) :-
        tempChanges_fact := [],
        foreach inclWt(AttrID, PW, CgW, CrW, MW, FW, IW, SW, AW) do
            Val = Phys * PW + Cogn * CgW + Creat * CrW + Masc * MW + Fem * FW + Intr * IW + Sex * SW + Aggr * AW,
            tempChanges_fact := [tuple(AttrID, Val) | tempChanges_fact]
        end foreach,
        changeSelf(tempChanges_fact),
        tempChanges_fact := [].

predicates
    setInclinations : (unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned, unsigned).
clauses
    setInclinations(Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr) :-
        assert(incl("inclPhys", Phys)),
        assert(incl("inclCogn", Cogn)),
        assert(incl("inclCreat", Creat)),
        assert(incl("inclMasc", Masc)),
        assert(incl("inclFem", Fem)),
        assert(incl("inclIntr", Intr)),
        assert(incl("inclSex", Sex)),
        assert(incl("inclAggr", Aggr)).

predicates
    createPresetParams : ().
clauses
    createPresetParams() :-
% Атрибуты
        createParam("attrSTR", 0, 0, max_param_value),
        createParam("attrCON", 0, 0, max_param_value),
        createParam("attrINT", 0, 0, max_param_value),
        createParam("attrREF", 0, 0, max_param_value),
        createParam("attrCHA", 0, 0, max_param_value),
        createParam("attrETH", 0, 0, max_param_value),
        createParam("attrAMR", 0, 0, max_param_value),
        createParam("attrSEN", 0, 0, max_param_value),
% Навыки
        createParam("skillDec", 0, 0, max_param_value / 2),
        createParam("skillArt", 0, 0, max_param_value / 2),
        createParam("skillConv", 0, 0, max_param_value / 2),
        createParam("skillClean", 0, 0, max_param_value / 2),
        createParam("skillCook", 0, 0, max_param_value / 2),
        createParam("skillCombSkl", 0, 0, max_param_value / 2),
        createParam("skillCombAtt", 0, 0, max_param_value / 2),
        createParam("skillCombDef", 0, 0, max_param_value / 2),
        createParam("skillMgrSkl", 0, 0, max_param_value / 2),
        createParam("skillMgrAtt", 0, 0, max_param_value / 2),
        createParam("skillMgrDef", 0, 0, max_param_value / 2),
% Уровень стресса и количество денег по умолчанию
        createParam("stressLv", 0, 0, max_stress_lv),
        createParam("moneyQt", 500, 0, max_money_quantity).

predicates
    createParam : (symbol ParamID, real Value, real MinValue, real MaxValue).
clauses
    createParam(PID, V, MinV, MaxV) :-
        assert(param(PID, V)),
        assert(paramConstraint(PID, MinV, MaxV)).

% Инициализация - конец
%-----------------------------------------------

%
clauses
    getParameterData(ID, Value, MinValue, MaxValue) :-
        param(ID, Value),
        paramConstraint(ID, MinValue, MaxValue),
        !.
    getParameterData(ID, _, _, _) :-
        Msg = string::concat("Не определён параметр: ", toString(ID)),
        exception::raise(
                classInfo,
                runtime_exception::internalError,
                [namedValue(error_signature, string(Msg))]).

    getParameterData_nd(ID, Value, MinValue, MaxValue) :-
        param(ID, Value),
        paramConstraint(ID, MinValue, MaxValue).

%--

%-----------------------------------------------
% Оценка своих параметров (имеют значение только параметры функций принадлежности лингвистических значений)

% Получение оценки особью своих параметров (предикат возвращает через своё имя список нечётких переменных fvar*)
% Каждая особь оценивает свои параметры по-своему, в зависимости от значений своих склонностей.
% Оценка каждого параметра заключается в присвоении ему набора лингвистических значений, функции принадлежности к которым
%   имеют параметры, определяемые значениями склонностей особи. Таким образом, реализуются утверждения, подобные следующему:
%   - если особь имеет сильно выраженную склонность к физическому развитию (inclPhys=3), то она оценивает своё телосложение (attrCON)
%     более критично (те значения attrCON, которые другой особью, менее склонной к физическому развитию (inclPhys<3), будут
%     оценены как "средние", этой особью будут оценены как "низкие" (или ещё ниже, неважно).

clauses
    getFuzzifiedParams() = ParamEvaluation :-
        tempFVarList := [],
        % Получаем списки термов для каждого параметра.
        % Термы вычисляются на основе наклонностей особи (параметров первого рода)
        foreach getParameterData_nd(ParamID, ParamValue, ParamMinValue, ParamMaxValue) do
            FParam = fvar::new(ParamID, ParamMinValue, ParamMaxValue),
            FParam:xvalue := ParamValue,
            TermListForFParam = getTermsForParam(ParamID),    % см. ниже
            FParam:addTermList(TermListForFParam),
            tempFVarList := [FParam | tempFVarList]
        end foreach,
        foreach incl(InclinationID, InclinationValue) do
            FIncl = fvar::new(InclinationID, 0, max_inclination_value),    % Склонности = {0, 1, 2, 3}.
            FIncl:xvalue := InclinationValue,
            TermListForFIncl = getTermList([1, 2, 3, 4, 5, 6, 7, 8], FIncl:xmin, FIncl:xmax),    % все склонности оцениваются одинаково
            FIncl:addTermList(TermListForFIncl),
            tempFVarList := [FIncl | tempFVarList]
        end foreach,
        ParamEvaluation = tempFVarList,
        tempFVarList := [].

% Получение для данной особи оценки заданного параметра
predicates
    getTermsForParam : (symbol ParamID) -> core::tuple{symbol TermName, fset TermFSet}* TermList.
clauses
    getTermsForParam(ParamID) = TermList :-
        paramConstraint(ParamID, ParamMin, ParamMax),
        !,
        try
            InclWeight = getInclinationsWeight(ParamID),    % Получили из значений склонностей влияние этих склонностей на заданную характеристику
            TermSetBoundaries = getTermSetBoundaries(InclWeight),    % Получили границы в термсете - список положительных действительных
            TermList = getTermList(TermSetBoundaries, ParamMin, ParamMax)    % Получает ParamID, так как надо знать ограничения на значения параметра
        catch AnyError do
            Msg = string::concat("individual:getTermsForParam/1-> : Не удалось произвести оценку параметра ", toString(ParamID)),
            exception::continue(
                    AnyError,
                    classInfo,
                    runtime_exception::internalError,
                    [namedValue(error_signature, string(Msg))])
        end try.
    getTermsForParam(ParamID) = _TermList :-
        Msg = string::concat("individual:getTermsForParam/1-> : Не удалось произвести оценку параметра ", toString(ParamID)),
        exception::raise(
            classInfo,
            runtime_exception::internalError,
            [namedValue(error_signature, string(Msg))]).
        

% HARD-CODING WARNING!

predicates
    getInclinationsWeight : (symbol ParamID) -> real InclinationWeight procedure (i).
clauses
    getInclinationsWeight(ParamID) = InclWeight :-
        inclWt(ParamID, PhW, CgW, CrW, MsW, FmW, InW, SxW, AgW),
        incl("inclPhys", PhI),
        incl("inclCogn", CgI),
        incl("inclCreat", CrI),
        incl("inclMasc", MsI),
        incl("inclFem", FmI),
        incl("inclIntr", InI),
        incl("inclSex", SxI),
        incl("inclAggr", AgI),
        !,
        InclWeight = inclValueListToWeight([PhI * PhW, CgI * CgW, CrI * CrW, MsI * MsW, FmI * FmW, InI * InW, SxI * SxW, AgI * AgW]).    % Наклонности модифицируются умножением на предопределённый коэффициент влияния наклонности на характеристику
    getInclinationsWeight(ParamID) = _InclWeight :-
        Msg = string::concat("Не удалось вычислить влияние наклонностей на характеристику: ", toString(ParamID),
                ", недоопределены наклонности"),
        exception::raise(
                classInfo,
                runtime_exception::internalError,
                [namedValue(error_signature, string(Msg))]).

% Преобразование списка значений склонностей в коэффициент *веса* этих склонностей [для какой-либо характеристики].
% То, что на каждую характеристику склонности влияют по-разному, обеспечивает то, что передаваемые в эту функцию значения -
%   не исходные значения склонностей, а модифицированные таблицей влияния (где-то выше по тексту).
class predicates
    inclValueListToWeight : (real* InclValueList) -> real Weight.
clauses
    inclValueListToWeight(VL) = Weight :-
        AverageInclination = getCrispArithmeticAverage(VL, 0, 0),
        Weight = (((AverageInclination - max_inclination_value)^2) / max_inclination_value) + 1/max_inclination_value.

% Получение среднего арифметического для списка действительных чисел,
%   пропуская нулевые элементы (!).
% Запускается так: AverageVal = getCrispArithmeticAverage(RealList, 0, 0).
% <закончено>
class predicates
    getCrispArithmeticAverage : (real* NmbList, real Accumulator, positive Counter) -> real ArithmeticAverage.
clauses
    getCrispArithmeticAverage([], _Acc, 0) = 0 :-
        !.
    getCrispArithmeticAverage([], Acc, Ct) = Acc/Ct :-
        !.
    getCrispArithmeticAverage([0|NLO], Acc, Ct) = getCrispArithmeticAverage(NLO, Acc, Ct) :-
        !.
    getCrispArithmeticAverage([Nmb|NLO], Acc, Ct) = getCrispArithmeticAverage(NLO, Acc+Nmb, Ct+1).


% Функция в зависимости от значения влияния наклонностей на оценку какой-либо характеристики
%   выдаёт список чисел, которые будут использованы как коэффициенты параметров функций принадлежности
%   для лингвистических значений (термов) этой характиристики. %
% При InclinationWeight = 1 -> [1, 2, 3, 4, 5] - это соответствует распределению границ для термсета, используемоего реальностью (reality.pro)
%   При InclinationWeight < 1 -> числа будут сдвинуты в сторону правого края (пяти) (особь более критично оценивает свои характеристики), "средние" значения характеристики завышаются
%   При InclinationWeight > 1 -> числа будут сдвинуты в сторону левого края (нуля) (особь менее критично оценивает свои характеристики), "средние" значения характеристики занижаются
% Не рекомендуется IW < 0.(3), так как самое левое число будет почти середина универсума дискурса
% Самое правое число всегда будет = 5 (любая особь считает,
%   что значение параметра, равное максимальному возможному значению этого параметра, является "чрезмерно большим"/"overpower").
% Отрицательные значения InclinationWeight недопустимы.
class predicates
    getTermSetBoundaries : (real InclinationsWeight) -> real* TermSetBoundaries.
clauses
    getTermSetBoundaries(IW) = _DontMatter :-
        IW < 0,
        Msg = string::concat("individual::getTermSetBoundaries/1-> : Не удалось вычислить параметры для функций принадлежности лингвистических значений нечёткой переменной: отрицательное значение коэффициента влияния наклонностей на самооценку особи: ",
                toString(IW), ", недопустимо"),
        exception::raise(
                classInfo,
                runtime_exception::internalError,
                [namedValue(error_signature, string(Msg))]).
    getTermSetBoundaries(1) = [1, 2, 3, 4, 5] :-
        !.
    getTermSetBoundaries(IW) = ParamList :-
        getBoundaryList(5, IW, 5, [], ParamList).    % Пять границ, последняя - правый край универсума дискурса.

% Получение списка границ внутри термсета. Эти границы будут использованы как параметры для функций принадлежности
%   лингвистическим значениям.
class predicates
    getBoundaryList : (integer BoundaryCount, real ShiftCoefficient, integer Limit, real* Accumulator, real* Boundaries) procedure (i, i, i, i, o).
clauses
    getBoundaryList(1, SC, L, BL, [B | BL]) :-
        B = getBoundary(1, SC, L),
        !.
    getBoundaryList(BC, SC, L, Acc, BL) :-
        B = getBoundary(BC, SC, L),
        getBoundaryList(BC - 1, SC, L, [B | Acc], BL).

% Получение текущей точки-границы.
class predicates
    getBoundary : (integer BoundaryNumber, real ShiftCoefficient, integer Limit) -> real BoundaryValue.
clauses
    getBoundary(BN, SC, L) = Value :-
        ValueEnumerator = BN ^ SC,    % ^ - встроенный аналог math::power/2->
        ValueDenominator = L ^ (SC - 1),
        Value = ValueEnumerator / ValueDenominator.

% TODO : HARD-CODING WARNING!
predicates
    getTermList : (real* TermSetBoundaryList, real ParamMin, real ParamMax) -> core::tuple{symbol TermName, fset TermFSet}* TermList procedure (i, i, i).
clauses
    getTermList([B1, B2, B3, B4, B5 | _DontMatter], MinValue, MaxValue) = TermList :-
        !,
    % Теперь начинаем на основании минимального и максимального чёткого значения параметра вводить функции оценки чёткого значения
        Shift = (MaxValue - MinValue) / 5,
        G = 1.17741,    % Константа для того, чтобы пользоваться вторым параметром гауссовой MF как абсциссой точки кроссовера (RTFM!)
      % Минимальное значение
        SB1 = MinValue + B1 * Shift,    % "S" stands for "Shifted", "B" for "Boundary"
        C1 = 0.0,    % первый параметр гауссовой MF - центр 
        S1 = SB1 / G,    % "S" stands for "Sigma", второй параметр гауссовой MF - размах. Делённый на G, становится расстоянием от центра до точки кроссовера
        TermMin = "minimal",
        StrMin = string::format("Субъективно минимальное значение: gaussian(X; %.3f, %.3f)", C1, S1),
        FSetMin = fset_LR::new(convert(symbol, StrMin)),
        FSetMin:membership_function := fuzzySupport::mff(gaussianMF, [C1, S1]),
      % Малое значение
        SB2 = MinValue + B2 * Shift,
        C2 = (SB2 - SB1) / 2 + SB1,
        S2 = (C2 - SB1) / G,
        TermLow = "low",
        StrLow = string::format("Субъективно низкое значение: gaussian(X; %.3f, %.3f)", C2, S2),
        FSetLow = fset_LR::new(convert(symbol, StrLow)),
        FSetLow:membership_function := fuzzySupport::mff(gaussianMF, [C2, S2]),
      % Среднее значение
        SB3 = MinValue + B3 * Shift,
        C3 = (SB3 - SB2) / 2 + SB2,
        S3 = (C3 - SB2) / G,
        TermMed = "medium",
        StrMed = string::format("Субъективно среднее значение: gaussian(X; %.3f, %.3f)", C3, S3),
        FSetMed = fset_LR::new(convert(symbol, StrMed)),
        FSetMed:membership_function := fuzzySupport::mff(gaussianMF, [C3, S3]),
      % Высокое значение
        SB4 = MinValue + B4 * Shift,
        C4 = (SB4 - SB3) / 2 + SB3,
        S4 = (C4 - SB3) / G,
        TermHigh = "high",
        StrHigh = string::format("Субъективно высокое значение: gaussian(X; %.3f, %.3f)", C4, S4),
        FSetHigh = fset_LR::new(convert(symbol, StrHigh)),
        FSetHigh:membership_function := fuzzySupport::mff(gaussianMF, [C4, S4]),
      % Близкое к максимальному значение
        SB5 = MinValue + B5 * Shift,    % так как B5 пока что всегда равно 5, очевидно, что SB5 всегда будет равно MaxValue, но вычисление всё равно оставлю, так как мало ли что ещё будет изменено .
        C5 = SB5,
        S5 = (SB5 - SB4) / G,
        TermOverpower = "overpower",
        StrOverpower = string::format("Субъективно крайне высокое значение: gaussian(X; %.3f, %.3f)", C5, S5),
        FSetOverpower = fset_LR::new(convert(symbol, StrOverpower)),
        FSetOverpower:membership_function := fuzzySupport::mff(gaussianMF, [C5, S5]),
% не забыть, что идентификаторы лингвистических значений должны быть согласованы: правила хранятся в reality, а термы создаются в individual
        TermList = [
            tuple(TermMin, FSetMin),
            tuple(TermLow, FSetLow),
            tuple(TermMed, FSetMed),
            tuple(TermHigh, FSetHigh),
            tuple(TermOverpower, FSetOverpower)
        ].
    getTermList(_DontMatterArgs, _, _) = _DontMatterResult :-
        Msg = "individual::getTermList/2-> : Не удалось получить корректные данные для создания термсета: слишком короткий список границ.",
        exception::raise(
                classInfo,
                runtime_exception::internalError,
                [namedValue(error_signature, string(Msg))]).

constants
    % Стандартная "продолжительность" действия
    actLongevity : integer = 4.

predicates
    paidIfWasAble : (core::tuple{symbol ParamID, real RequiredValue}* JobRequirements, integer ExpectedWage) -> integer EfectiveWage procedure (i, i).
clauses
    paidIfWasAble(JobRequirements, ExpectedWage) = ExpectedWage :-
        isAble(JobRequirements),
        !.
    paidIfWasAble(_NotPassed, _DontMatter) = 0.

predicates
    isAble : (core::tuple{symbol ParamID, real RequiredValue}* JobRequirements) determ (i).
clauses
    isAble([]).
    isAble([tuple(ParamID, RequiredValue) | OtherRequirements]) :-
        param(ParamID, EffectiveValue),
        !,
        EffectiveValue >= RequiredValue,
        isAble(OtherRequirements).

predicates
    setParam : (symbol ParamID, real NewValue) procedure (i, i).
clauses
    setParam(PID, NVal) :-
        retract(param(PID, _OldVal)),
        !,
        assert(param(PID, NVal)).
    setParam(ErroneousPID, _DontMatter) :-
        Msg = string::concat("individual:setParam/2 : Не удалось установить новое значение параметра: ID ", toString(ErroneousPID), " неизвестен."),
        exception::raise(
            classInfo,
            runtime_exception::internalError,
            [namedValue(error_signature, string(Msg))]).

%
predicates
    changeSelf : (paramChangeList ChangesList) procedure (i).
clauses
    changeSelf([]) :-
        !.
    changeSelf([core::tuple(ParamID, ParamChange) | OtherChanges]) :-
        getParameterData(ParamID, CurrentValue, _ValMin, ValMax),
        CurrentValue + ParamChange > ValMax,
        !,
        setParam(ParamID, ValMax),
        changeSelf(OtherChanges).
    changeSelf([core::tuple(ParamID, ParamChange) | OtherChanges]) :-
        getParameterData(ParamID, CurrentValue, ValMin, _ValMax),
        CurrentValue + ParamChange < ValMin,
        !,
        setParam(ParamID, ValMin),
        changeSelf(OtherChanges).
    changeSelf([core::tuple(ParamID, ParamChange) | OtherChanges]) :-
        getParameterData(ParamID, CurrentValue, _ValMin, _ValMax),
        setParam(ParamID, CurrentValue + ParamChange),    % Ничего не проверяем; все нужные проверки были выполнены двумя предыдущими предложениями.
        changeSelf(OtherChanges),
        !.
/*
    changeSelf([core::tuple(ErroneousParamID, _DontMatter) | _OtherChanges]) :-
        Msg = string::concat("individual:changeSelf/1 : Не удалось изменить параметр: ID ", ErroneousParamID, " неизвестен."),
        exception::raise(
            classInfo,
            runtime_exception::internalError,
            [namedValue(error_signature, string(Msg))]).
*/

% =====================================================================Действия
% Действия, которые может выполнить особь. Попытка выполнить действие, идентификатор которого не известен
%   (на который для doAction/1-> не определено конкретное предложение), приведёт к runtime error.
% TODO : HARD-CODING WARNING!
clauses
    doAction("jobMaid") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0005),
        WageAdvanced = paidIfWasAble([
            tuple("skillCook", (max_param_value / 2) / 3),
            tuple("skillClean", (max_param_value / 2) / 3)
            ], math::floor(max_money_quantity * 0.0006)),
        ResultingChanges = [
% повышения
            tuple("skillCook", (max_param_value / 2) * param_change_degree * 5),
            tuple("skillClean", (max_param_value / 2) * param_change_degree * 5),
% понижения
            tuple("attrSEN", max_param_value * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 5),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobBabysitter") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0005),
        WageAdvanced = paidIfWasAble([
            tuple("attrSEN", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0006)),
        ResultingChanges = [
% повышения
            tuple("attrSEN", max_param_value * param_change_degree * 5),
% понижения
            tuple("attrCHA", max_param_value * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 7),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobInn") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0005),
        WageAdvanced = paidIfWasAble([
            tuple("skillClean", (max_param_value / 2) / 3)
            ], math::floor(max_money_quantity * 0.0006)),
        ResultingChanges = [
% повышения
            tuple("skillClean", (max_param_value / 2) * param_change_degree * 5),
% понижения
            tuple("skillCombSkl", (max_param_value / 2) * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 6),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobFarm") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.001),
        WageAdvanced = paidIfWasAble([
            tuple("attrSTR", max_param_value / 3),
            tuple("attrCON", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0012)),
        ResultingChanges = [
% повышения
            tuple("attrSTR", max_param_value * param_change_degree * 5),
            tuple("attrCON", max_param_value * param_change_degree * 7),
% понижения
            tuple("attrREF", max_param_value * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 7),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobChurch") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0001),
        ResultingChanges = [
% повышения
            tuple("attrETH", max_param_value * param_change_degree * 5),
% понижения
            tuple("attrAMR", max_param_value * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 3),
            tuple("moneyQt", WageNormal)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobRestaurant") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0006),
        WageAdvanced = paidIfWasAble([
            tuple("skillCook", (max_param_value / 2) / 3)
            ], math::floor(max_money_quantity * 0.0008)),
        ResultingChanges = [
% повышения
            tuple("skillCook", (max_param_value / 2) * param_change_degree * 5),
% понижения
            tuple("skillCombSkl", (max_param_value / 2) * param_change_degree * 4 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 5),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobLumber") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0012),
        WageAdvanced = paidIfWasAble([
            tuple("attrCON", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0018)),
        ResultingChanges = [
% повышения
            tuple("attrSTR", max_param_value * param_change_degree * 8),
% понижения
            tuple("attrREF", max_param_value * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 5),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobSalon") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0009),
        WageAdvanced = paidIfWasAble([
            tuple("skillArt", (max_param_value / 2) / 3)
            ], math::floor(max_money_quantity * 0.0025)),
        ResultingChanges = [
% повышения
            tuple("attrSEN", max_param_value * param_change_degree * 8),
% понижения
            tuple("attrSTR", max_param_value * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 6),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobMason") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0015),
        WageAdvanced = paidIfWasAble([
            tuple("skillArt", (max_param_value / 2) / 3),
            tuple("attrCON", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0025)),
        ResultingChanges = [
% повышения
            tuple("attrCON", max_param_value * param_change_degree * 7),
% понижения
            tuple("attrCHA", max_param_value * param_change_degree * 6 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 8),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobHunter") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0012),
        WageAdvanced = paidIfWasAble([
            tuple("skillCombAtt", (max_param_value / 2) / 3)
            ], math::floor(max_money_quantity * 0.0012)),
        ResultingChanges = [
% повышения
            tuple("attrCON", max_param_value * param_change_degree * 3),
            tuple("skillCombSkl", (max_param_value / 2) * param_change_degree * 5),
            tuple("attrAMR", max_param_value * param_change_degree * 7),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 5),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobCemetery") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0008),
        WageAdvanced = paidIfWasAble([
            tuple("skillMgrAtt", (max_param_value / 2) / 3)
            ], math::floor(max_money_quantity * 0.0025)),
        ResultingChanges = [
% повышения
            tuple("attrSEN", max_param_value * param_change_degree * 6),
            tuple("skillMgrDef", (max_param_value / 2) * param_change_degree * 5),
% понижения
            tuple("attrCHA", max_param_value * param_change_degree * 5 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 6),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobTutor") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0020),
        WageAdvanced = paidIfWasAble([
            tuple("attrINT", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0025)),
        ResultingChanges = [
% повышения
            tuple("attrETH", max_param_value * param_change_degree * 5),
            tuple("skillConv", (max_param_value / 2) * param_change_degree * 5),
% понижения
            tuple("attrCHA", max_param_value * param_change_degree * 4 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 8),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobBar") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0020),
        WageAdvanced = paidIfWasAble([
            tuple("attrCHA", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0012)),
        ResultingChanges = [
% повышения
            tuple("skillCook", (max_param_value / 2) * param_change_degree * 5),
            tuple("skillConv", (max_param_value / 2) * param_change_degree * 5),
% понижения
            tuple("attrINT", max_param_value * param_change_degree * 5 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 8),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobBordello") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0050),
        WageAdvanced = paidIfWasAble([
            tuple("attrCHA", max_param_value / 3),
            tuple("attrCON", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0050)),
        ResultingChanges = [
% повышения
            tuple("attrCHA", max_param_value * param_change_degree * 8),
            tuple("attrAMR", max_param_value * param_change_degree * 10),
% понижения
            tuple("attrETH", max_param_value * param_change_degree * 7 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 9),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("jobCabaret") = ResultingChanges :-
        !,
        age := age + actLongevity,
        WageNormal = math::floor(max_money_quantity * 0.0035),
        WageAdvanced = paidIfWasAble([
            tuple("attrCHA", max_param_value / 3),
            tuple("attrREF", max_param_value / 3)
            ], math::floor(max_money_quantity * 0.0050)),
        ResultingChanges = [
% повышения
            tuple("attrAMR", max_param_value * param_change_degree * 8),
% понижения
            tuple("attrETH", max_param_value * param_change_degree * 3 * -1),
            tuple("attrINT", max_param_value * param_change_degree * 5 * -1),
            tuple("attrREF", max_param_value * param_change_degree * 4 * -1),
% стресс и зарплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 7),
            tuple("moneyQt", WageNormal + WageAdvanced)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyScience") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("attrINT", max_param_value * param_change_degree * 9),
% понижения
            tuple("skillMgrDef", (max_param_value / 2) * param_change_degree * 5 * -1),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyStrategy") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("attrETH", max_param_value * param_change_degree * 4),
            tuple("attrINT", max_param_value * param_change_degree * 7),
            tuple("skillCombSkl", (max_param_value / 2) * param_change_degree * 5),
% понижения
            tuple("attrSEN", max_param_value * param_change_degree * 6 * -1),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyTeology") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("attrETH", max_param_value * param_change_degree * 6),
            tuple("skillMgrDef", (max_param_value / 2) * param_change_degree * 3),
% понижения
            tuple("attrAMR", max_param_value * param_change_degree * 5 * -1),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyPoetry") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("attrSEN", max_param_value * param_change_degree * 6),
            tuple("skillArt", (max_param_value / 2) * param_change_degree * 6),
            tuple("attrREF", max_param_value * param_change_degree * 4),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyFighting") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("skillCombSkl", (max_param_value / 2) * param_change_degree * 5),
            tuple("skillCombDef", (max_param_value / 2) * param_change_degree * 5),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyFencing") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("skillCombSkl", (max_param_value / 2) * param_change_degree * 5),
            tuple("skillCombAtt", (max_param_value / 2) * param_change_degree * 5),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyMagic") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("skillMgrSkl", (max_param_value / 2) * param_change_degree * 5),
            tuple("skillMgrAtt", (max_param_value / 2) * param_change_degree * 5),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyEtiquette") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("skillDec", (max_param_value / 2) * param_change_degree * 5),
            tuple("attrREF", max_param_value * param_change_degree * 5),
            tuple("attrETH", max_param_value * param_change_degree * 4),
% понижения
            tuple("attrAMR", max_param_value * param_change_degree * 4 * -1),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyArts") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("skillArt", (max_param_value / 2) * param_change_degree * 5),
            tuple("attrSEN", max_param_value * param_change_degree * 5),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("studyDancing") = ResultingChanges :-
        !,
        age := age + actLongevity,
        ResultingChanges = [
% повышения
            tuple("skillArt", (max_param_value / 2) * 0.04),
            tuple("attrCHA", max_param_value * param_change_degree * 5),
            tuple("attrCON", max_param_value * param_change_degree * 4),
% стресс и оплата
            tuple("stressLv", max_stress_lv * stress_change_degree * 4),
            tuple("moneyQt", max_money_quantity * 0.0030 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction("actLeizure") = ResultingChanges :-
        param("moneyQt", MoneyQt),
        MoneyQt > max_money_quantity * 0.0200,
        !,
        age := age + math::floor(actLongevity / 2),
        ResultingChanges = [
            tuple("stressLv", max_stress_lv * 0.5 * -1),
            tuple("moneyQt", max_money_quantity * 0.0180 * -1)
            ],
        changeSelf(ResultingChanges).
    doAction("actLeizure") = ResultingChanges :-
        param("moneyQt", MoneyQt),
        MoneyQt > max_money_quantity * 0.0020,    % но, согласно провалу предыдущего предложения, < 200
        !,
        age := age + math::floor(actLongevity / 2),
        ResultingChanges = [
            tuple("attrAMR", max_param_value * 0.02),    % Если денег на серьёзный отдых нет, то будет страдать фигнёй и растлять сама себя - тлетворное влияние окружающей среды.
            tuple("stressLv", max_stress_lv * 0.35 * -1),
            tuple("moneyQt", max_money_quantity * 0.0005 * -1)
            ],
        changeSelf(ResultingChanges).
    doAction("actLeizure") = ResultingChanges :-
        !,
        age := age + math::floor(actLongevity / 2),
        ResultingChanges = [
            tuple("attrAMR", max_param_value * 0.20),    % Если денег совсем нет, найдёт самый аморальный и извращённый способ развлечься и поесть
            tuple("stressLv", max_stress_lv * 0.2 * -1)
            ],
        changeSelf(ResultingChanges).
%
    doAction(IllegalActionID) = _DontMatter :-
        Msg = string::concat("individual:doAction/1-> : Невозможно выполнить действие: ID ", IllegalActionID, " неизвестен."),
        exception::raise(
            classInfo,
            runtime_exception::internalError,
            [namedValue(error_signature, string(Msg))]).

%
clauses
    getActionsToPrioritize() = ActionsList :-
        param("moneyQt", Val),
        Val < max_money_quantity * 0.0030,    % Денег нет - не учимся и не отдыхаем, только работаем.
        !,
        JobsBasic = selectJobsBasic(),
        JobsAfter2Years = selectJobsAfter2Years(),
        JobsAfter4Years = selectJobsAfter4Years(),
        JobsAfter6Years = selectJobsAfter6Years(),
        ActionsList = list::appendList([
            JobsBasic,
            JobsAfter2Years,
            JobsAfter4Years,
            JobsAfter6Years]).

    getActionsToPrioritize() = ActionsList :-
        JobsBasic = selectJobsBasic(),
        JobsAfter2Years = selectJobsAfter2Years(),
        JobsAfter4Years = selectJobsAfter4Years(),
        JobsAfter6Years = selectJobsAfter6Years(),
        StudyAndLeizure = selectOtherActivity(),
        ActionsList = list::appendList([
            JobsBasic,
            JobsAfter2Years,
            JobsAfter4Years,
            JobsAfter6Years,
            StudyAndLeizure]).

%
predicates
    %
    selectJobsBasic : () -> symbol* JobIDList procedure.

    %
    selectJobsAfter2Years : () -> symbol* JobIDList procedure.

    %
    selectJobsAfter4Years : () -> symbol* JobIDList procedure.

    %
    selectJobsAfter6Years : () -> symbol* JobIDList procedure.

    %
    selectOtherActivity : () -> symbol* JobIDList procedure.

%
clauses
    %
    selectJobsBasic() = JobIDList :-
        JobIDList = [
            "jobMaid",
            "jobBabysitter",
            "jobInn",
            "jobChurch",
            "jobRestaurant",
            "jobFarm"].

    %
    selectOtherActivity() = ActIDList :-
        ActIDList = [
            "studyScience",
            "studyStrategy",
            "studyTeology",
            "studyPoetry",
            "studyFighting",
            "studyFencing",
            "studyMagic",
            "studyEtiquette",
            "studyArts",
            "studyDancing",
            "actLeizure"].

    %
    selectJobsAfter2Years() = JobIDList :-
        age > 365 * 2,
        !,
        JobIDList = [
            "jobLumber",
            "jobSalon",
            "jobMason"].
    selectJobsAfter2Years() = [].

    %
    selectJobsAfter4Years() = JobIDList :-
        age > 365 * 4,
        !,
        JobIDList = [
            "jobHunter",
            "jobCemetery",
            "jobTutor"].
    selectJobsAfter4Years() = [].

    %
    selectJobsAfter6Years() = JobIDList :-
        age > 365 * 6,
        !,
        JobIDList = [
            "jobBar",
            "jobBordello",
            "jobCabaret"].
    selectJobsAfter6Years() = [].

%----------------------------------------------
% Два варианта отчётов для логгера
facts
    tempString : string := erroneous.
    
clauses
    % Отчёт о текущем объекте особи, содержит значения параметров особи, склонностей и весов влияния склонностей на параметры.
    %   Также содержит кратко распределение
    getSelfDescription() = Description :-
        tempString := "Отчёт о состоянии текущего объекта особи\nПараметры первого рода (\"Наклонности\"):\n",
        foreach incl(InclID, InclVal) do
            tempString := string::concatList([tempString, "\t", toString(InclID), ": ", toString(InclVal), "\n"])
        end foreach,
        tempString := string::concat(tempString, "\nПараметры второго рода (\"Атрибуты\"/\"Навыки\"):\n"),
        foreach getParameterData_nd(ParamID, ParamVal, ParamMin, ParamMax) do
            tempString := string::concatList([tempString, "\t", toString(ParamID), ": ", toString(ParamVal), "[", toString(ParamMin), "..", toString(ParamMax), "]\n"]),
            IW = getInclinationsWeight(ParamID),
            tempString := string::concat(tempString, "\t\tВес наклонностей: ", toString(IW)),
            BL = getTermSetBoundaries(IW),
            tempString := string::concat(tempString, ", соответствующие границы: ", toString(BL), "\n")
        end foreach,
        Description = tempString.

clauses
    %
    getClassDescription() = Description :-
        tempString := string::concatList([
                "Отчёт о неизменяемых особенностях класса объектов особи\n",
                " Стандартное максимальное значение параметра: ", toString(max_param_value),
                "\n Стандартное максимальное значение параметра \"moneyQt\": ", toString(max_money_quantity),
                "\n Стандартное максимальное значение параметра \"stressLv\": ", toString(max_stress_lv),
                "\n Таблица весов\nParamID:\tinclPhys|inclCogn|inclCreat|inclMasc|inclFem|inclIntr|inclSex|inclAggr\n"
            ]),
        foreach inclWt(ParamID, PI, CgI, CrI, MI, FI, II, SI, AI) do
            tempString := string::concat(
                    tempString,
                    string::format(
                            "%s:\t%8.2f|%8.2f|%9.2f|%8.2f|%7.2f|%8.2f|%7.2f|%8.2f\n",
                            ParamID, PI, CgI, CrI, MI, FI, II, SI, AI)
                )
        end foreach,
        Description = tempString.
        
end implement individual
