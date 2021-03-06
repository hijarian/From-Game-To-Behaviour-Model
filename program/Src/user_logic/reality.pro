/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement reality
    open core, fuzzySupport

constants
    className = "user_logic/reality".
    classVersion = "".

clauses
    classInfo(className, classVersion).

constants
    error_signature : symbol = "User logic error".

facts -reality
    % Нечёткие правила, собранные в виде списка объектов класса fuzzyRule
    % Список заполняется один раз при инициализации This
    packedFRules : fuzzyRule* := erroneous.

    % Нечёткие переменные, представляющие собой фаззифицированные приоритеты действий.
    % Список заполняется один раз при инициализации This
    packedFActions : fvar* := erroneous.

    % Фаззифицированные согласно представлениям реальности параметры особи.
    %   Заполняются предикатом fuzzyParamsFromIndivid/1
    evaluated_individ_param : (symbol ParamID, fvar FuzzyEvaluation) nondeterm.

clauses
    getVar(ParamID) = FVar :-
        evaluated_individ_param(ParamID, FVar),
        !.
    getVar(ErroneousID) = _DontMatter :-
        Msg = string::concat("reality::getVar/1->: Не удалось получить оценку параметра \"", toString(ErroneousID), "\": ещё не оценивался"),
        exception::raise(
                classInfo,
                runtime_exception::internalError,
                [namedValue(error_signature, string(Msg))]).

clauses
    % TODO HARD-CODING WARNING!
    init() :-
%
        AllJobsIDList = [
            "jobMaid",
            "jobBabysitter",
            "jobInn",
            "jobFarm",
            "jobChurch",
            "jobRestaurant",
            "jobLumber",
            "jobSalon",
            "jobMason",
            "jobHunter",
            "jobCemetery",
            "jobTutor",
            "jobBar",
            "jobBordello",
            "jobCabaret"],
%
        AllStudiesIDList = [
            "studyScience",
            "studyStrategy",
            "studyTeology",
            "studyPoetry",
            "studyFighting",
            "studyFencing",
            "studyMagic",
            "studyEtiquette",
            "studyArts",
            "studyDancing"],
%
        packedFRules := list::appendList([
%
            createMixedProp(["inclIntr", "inclFem", "inclSex"], ["inclAggr"], "jobMaid"),
            createInverseProp(["skillCook", "skillClean"], "jobMaid"),
%
            createMixedProp(["inclFem"], ["inclIntr", "inclAggr"], "jobBabysitter"),
            createInverseProp(["attrSEN"], "jobBabysitter"),
%
            createInverseProp(["inclAggr"], "jobInn"),
            createInverseProp(["skillClean"], "jobInn"),
%
            createMixedProp(["inclPhys", "inclMasc"], ["inclCreat"], "jobFarm"),
            createInverseProp(["attrCON"], "jobFarm"),
%
            createInverseProp(["inclAggr", "inclCreat"], "jobChurch"),
            createMixedProp(["attrAMR"], ["attrETH"], "jobChurch"),    % Чем более этична особь, тем меньше желание замаливать аморальность в церкви
%
            createInverseProp(["inclAggr"], "jobRestaurant"),
            createInverseProp(["skillCook"], "jobRestaurant"),
%
            createMixedProp(["inclPhys", "inclMasc"], ["inclCreat"], "jobLumber"),
            createInverseProp(["attrSTR"], "jobLumber"),
%
            createDirectProp(["inclCreat", "inclFem"], "jobSalon"),
            createInverseProp(["attrSEN"], "jobSalon"),
%
            createDirectProp(["inclPhys", "inclMasc", "inclCreat"], "jobMason"),
            createInverseProp(["attrCON"], "jobMason"),
%
            createMixedProp(["inclPhys", "inclAggr"], ["inclFem"], "jobHunter"),
            createInverseProp(["skillCombSkl", "attrCON"], "jobHunter"),
%
            createDirectProp(["inclIntr"], "jobCemetery"),
            createInverseProp(["skillMgrDef", "attrSEN"], "jobCemetery"),
%
            createDirectProp(["inclCogn"], "jobTutor"),
            createInverseProp(["attrETH", "skillConv"], "jobTutor"),
%
            createMixedProp(["attrAMR"], ["attrETH", "inclCogn", "inclIntr"], "jobBar"),
            createInverseProp(["skillConv"], "jobBar"),
%
            createMixedProp(["attrAMR", "inclSex", "inclFem"], ["attrETH", "inclCogn"], "jobBordello"),
            createInverseProp(["attrCHA", "attrETH"], "jobBordello"),
%
            createMixedProp(["attrAMR", "inclSex", "inclFem"], ["attrETH", "inclIntr"], "jobCabaret"),
            createInverseProp(["attrETH"], "jobCabaret"),
%
            createDirectProp(["inclCogn"], "studyScience"),
            createInverseProp(["attrINT"], "studyScience"),
%
            createDirectProp(["inclAggr", "inclCogn"], "studyStrategy"),
            createInverseProp(["attrINT", "skillCombSkl"], "studyStrategy"),
%
            createMixedProp(["inclCogn"], ["inclAggr", "inclCreat"], "studyTeology"),
            createMixedProp(["attrAMR"], ["attrETH", "skillMgrDef"], "studyTeology"),
%
            createDirectProp(["inclCreat"], "studyPoetry"),
            createInverseProp(["skillArt", "attrREF"], "studyPoetry"),
%
            createDirectProp(["inclMasc", "inclAggr", "inclPhys"], "studyFighting"),
            createInverseProp(["skillCombSkl", "skillCombDef"], "studyFighting"),
%
            createDirectProp(["inclMasc", "inclAggr", "inclPhys"], "studyFencing"),
            createInverseProp(["skillCombSkl", "skillCombAtt"], "studyFencing"),
%
            createDirectProp(["inclFem", "inclCogn", "inclCreat"], "studyMagic"),
            createInverseProp(["skillMgrSkl", "skillMgrAtt"], "studyMagic"),
%
            createMixedProp(["inclFem"], ["inclAggr"], "studyEtiquette"),
            createInverseProp(["skillDec", "attrREF"], "studyEtiquette"),
%
            createMixedProp(["inclCreat"], ["inclAggr", "inclPhys"], "studyArts"),
            createInverseProp(["skillArt"], "studyArts"),
%
            createDirectProp(["inclSex", "inclPhys"], "studyDancing"),
            createInverseProp(["skillArt", "attrCHA"], "studyDancing"),
%
            createDirectProp(["stressLv"], "actLeizure"),
            createDirectProp(["stressLv", "moneyQt"], "actLeizure"),
%
            createCommonInverseFactor(
                "stressLv",
                list::append(AllJobsIDList, AllStudiesIDList)),
%
            createCommonInverseFactor(
                "moneyQt",
                AllJobsIDList),
            createCommonDirectFactor(
                "moneyQt",
                AllStudiesIDList)
            ]),
        packedFActions := initActionList(list::append(AllJobsIDList, AllStudiesIDList, ["actLeizure"])),
        succeed().

%
predicates
    initActionList : (symbol* ActionIDList) -> fvar* ActionPrioritiesAsFVarList procedure (i).
clauses
    initActionList([]) = [] :-
        !.
    initActionList([ActionID | OtherIDs]) = [FAct | OtherFActList] :-
        FAct = divineFuzzification(ActionID, 0, 0, 10000),
        OtherFActList = initActionList(OtherIDs).
%
clauses
%
    getRules() = packedFRules.

%
    getActions() = packedFActions.

predicates
    divineFuzzification : (symbol FVarID, real CurrentValue, real MinValue, real MaxValue) -> fvar FVar procedure (i, i, i, i).
clauses
    divineFuzzification(ID, Value, MinValue, MaxValue) = FVar :-
        %  Создали нечёткую переменную и заполнили её базовыми параметрами
        FVar = fvar::new(ID, MinValue, MaxValue),
        FVar:xvalue := Value,
% Теперь начинаем на основании минимального и максимального чёткого значения параметра вводить функции оценки чёткого значения
        Shift = (MaxValue - MinValue) / 10,
        % Типичное минимальное значение
        FSetMin = fset_LR::new("Universal Min"),
        FSetMin:membership_function := fuzzySupport::mff(triangleLMF, [MinValue + 1 * Shift, MinValue + 2 * Shift]),
        % Типичное малое значение
        FSetLow = fset_LR::new("Universal Low"),
        FSetLow:membership_function := fuzzySupport::mff(triangleMF, [MinValue + 1 * Shift, MinValue + 3 * Shift, MinValue + 4 * Shift]),
        % Типичное среднее значение
        FSetMed = fset_LR::new("Universal Medium"),
        FSetMed:membership_function := fuzzySupport::mff(triangleMF, [MinValue + 3 * Shift, MinValue + 5 * Shift, MinValue + 6 * Shift]),
        % Типичное высокое значение
        FSetHigh = fset_LR::new("Universal High"),
        FSetHigh:membership_function := fuzzySupport::mff(triangleMF, [MinValue + 5 * Shift, MinValue + 7 * Shift, MinValue + 8 * Shift]),
        % Типичное близкое к максимальному значение
        FSetOverpower = fset_LR::new("Universal Overpower"),
        FSetOverpower:membership_function := fuzzySupport::mff(triangleRMF, [MinValue + 7 * Shift, MinValue + 9 * Shift]),
% Созданные функции оценки приписываем переменной
% не забыть, что идентификаторы термов должны быть согласованы между правилами и всеми нечёткими переменными!
        FVar:addTermList([
            core::tuple("minimal", FSetMin),
            core::tuple("low", FSetLow),
            core::tuple("medium", FSetMed),
            core::tuple("high", FSetHigh),
            core::tuple("overpower", FSetOverpower)]).

% Фаззификация параметров особи для дальнейшей оценки приближённости её к целевому состоянию
clauses
    fuzzyParamsFromIndivid(Individ) :-
        % ОБЯЗАТЕЛЬНО ПОХЕРИТЬ СТАРЫЕ ДАННЫЕ!!!
        retractall(evaluated_individ_param(_, _)),
        foreach Individ:getParameterData_nd(ID, Value, MinValue, MaxValue) do
            FVar = divineFuzzification(ID, Value, MinValue, MaxValue),
% Сохраняем оценку переменной в базе фактов
            assert(evaluated_individ_param(ID, FVar))
        end foreach.

% Удобные обёртки для забивания базы правил, описывающих реальность.
%----------------------------------------------------------------------------

% Создание правила из нескольких предпосылок, ссылающихся на одно и то же лингвистическое значение, и одного последствия
predicates
    createRule : (symbol* ParamIDList, symbol ParamsCommonTermID, symbol ActionID, symbol PriorityTermID) -> fuzzyRule FuzzyRule procedure (i, i, i, i).
clauses
    createRule(PIDList, PTID, AID, ATID) = FuzzyRule :-
        FuzzyRule = fuzzyRule::new(),
        FuzzyRule:addListToLHS(convertIDListToFClauseList(PIDList, PTID)),
        FuzzyRule:addToRHS(fuzzySupport::fclause(AID, ATID)).

predicates
    convertIDListToFClauseList : (symbol* IDList, symbol TermID) -> fuzzySupport::fclause* FClauseList procedure (i, i).
clauses
    convertIDListToFClauseList([], _DontMatter) = [] :-
        !.
    convertIDListToFClauseList([ID | OtherIDs], TermID) = FClauseList :-
        CurrentClause = fuzzySupport::fclause(ID, TermID),
        PreviousClauses = convertIDListToFClauseList(OtherIDs, TermID),
        FClauseList = [CurrentClause | PreviousClauses].

%  Смешанная зависимость - DirectParamIDList определяет параметры, с которыми приоритет ActionID находится в прямой зависимости,
%    InverseParamIDList - параметры, с которыми приоритет ActionID находится в обратной зависимости.
% Через своё имя предикат возвращает набор нечётких правил, реализующих эти зависимости.
% Параметры в списках - факторы влияния на приоритет действия ActionID - все связаны друг с другом оператором AND.
predicates
    createMixedProp : (symbol* DirectParamIDList, symbol* InverseParamIDList, symbol ActionID) -> fuzzyRule* FuzzyRuleList procedure (i, i, i).
clauses
    createMixedProp(DirParamIDList, InvParamIDList, ActionID) = FuzzyRuleList :-
%
        IfDirParamsMin = convertIDListToFClauseList(DirParamIDList, "minimal"),
        IfDirParamsLow = convertIDListToFClauseList(DirParamIDList, "low"),
        IfDirParamsMed = convertIDListToFClauseList(DirParamIDList, "medium"),
        IfDirParamsHigh = convertIDListToFClauseList(DirParamIDList, "high"),
        IfDirParamsMax = convertIDListToFClauseList(DirParamIDList, "overpower"),
%
        IfInvParamsMin = convertIDListToFClauseList(InvParamIDList, "minimal"),
        IfInvParamsLow = convertIDListToFClauseList(InvParamIDList, "low"),
        IfInvParamsMed = convertIDListToFClauseList(InvParamIDList, "medium"),
        IfInvParamsHigh = convertIDListToFClauseList(InvParamIDList, "high"),
        IfInvParamsMax = convertIDListToFClauseList(InvParamIDList, "overpower"),
%
        FRuleToMin = fuzzyRule::new(),
        FRuleToMin:addListToLHS(IfDirParamsMin),
        FRuleToMin:addListToLHS(IfInvParamsMax),
        FRuleToMin:addToRHS(fuzzySupport::fclause(ActionID, "minimal")),

        FRuleToLow = fuzzyRule::new(),
        FRuleToLow:addListToLHS(IfDirParamsLow),
        FRuleToLow:addListToLHS(IfInvParamsHigh),
        FRuleToLow:addToRHS(fuzzySupport::fclause(ActionID, "low")),

        FRuleToMed = fuzzyRule::new(),
        FRuleToMed:addListToLHS(IfDirParamsMed),
        FRuleToMed:addListToLHS(IfInvParamsMed),
        FRuleToMed:addToRHS(fuzzySupport::fclause(ActionID, "medium")),

        FRuleToHigh = fuzzyRule::new(),
        FRuleToHigh:addListToLHS(IfDirParamsHigh),
        FRuleToHigh:addListToLHS(IfInvParamsLow),
        FRuleToHigh:addToRHS(fuzzySupport::fclause(ActionID, "high")),

        FRuleToMax = fuzzyRule::new(),
        FRuleToMax:addListToLHS(IfDirParamsMax),
        FRuleToMax:addListToLHS(IfInvParamsMin),
        FRuleToMax:addToRHS(fuzzySupport::fclause(ActionID, "overpower")),

%
        FuzzyRuleList = [
            FRuleToMin,
            FRuleToLow,
            FRuleToMed,
            FRuleToHigh,
            FRuleToMax].

% Прямая зависимость приоритета действия от значения параметра
%   (чем выше параметр, тем выше приоритет действия)
% Принимает список параметров в качестве предпосылки.
predicates
    createDirectProp : (symbol* ParamIDList, symbol ActionID) -> fuzzyRule* FuzzyRuleList procedure (i, i).
clauses
    createDirectProp(ParamIDList, ActionID) = FuzzyRuleList :-
        %
        FuzzyRuleMinToMin = createRule(ParamIDList, "minimal", ActionID, "minimal"),
        FuzzyRuleLowToLow = createRule(ParamIDList, "low", ActionID, "low"),
        FuzzyRuleMedToMed = createRule(ParamIDList, "medium", ActionID, "medium"),
        FuzzyRuleHighToHigh = createRule(ParamIDList, "high", ActionID, "high"),
        FuzzyRuleMaxToMax = createRule(ParamIDList, "overpower", ActionID, "overpower"),
        %
        FuzzyRuleList = [
            FuzzyRuleMinToMin,
            FuzzyRuleLowToLow,
            FuzzyRuleMedToMed,
            FuzzyRuleHighToHigh,
            FuzzyRuleMaxToMax].

% Обратная зависимость приоритета действия от значения параметра
%   (чем выше параметр, тем ниже приоритет действия)
% Принимает список параметров в качестве предпосылки.
predicates
    createInverseProp : (symbol* ParamIDList, symbol ActionID) -> fuzzyRule* FuzzyRuleList procedure (i, i).
clauses
    createInverseProp(ParamIDList, ActionID) = FuzzyRuleList :-
        %
        FuzzyRuleMinToMin = createRule(ParamIDList, "minimal", ActionID, "overpower"),
        FuzzyRuleLowToLow = createRule(ParamIDList, "low", ActionID, "high"),
        FuzzyRuleMedToMed = createRule(ParamIDList, "medium", ActionID, "medium"),
        FuzzyRuleHighToHigh = createRule(ParamIDList, "high", ActionID, "low"),
        FuzzyRuleMaxToMax = createRule(ParamIDList, "overpower", ActionID, "minimal"),
        %
        FuzzyRuleList = [
            FuzzyRuleMinToMin,
            FuzzyRuleLowToLow,
            FuzzyRuleMedToMed,
            FuzzyRuleHighToHigh,
            FuzzyRuleMaxToMax].

predicates
    createCommonDirectFactor : (symbol ParamID, symbol* ActionIDList) -> fuzzyRule* FuzzyRuleList procedure (i, i).
clauses
    createCommonDirectFactor(Factor, ActionsAffected) = FuzzyRulesList :-
%
        MinPriority = convertIDListToFClauseList(ActionsAffected, "minimal"),
        LowPriority = convertIDListToFClauseList(ActionsAffected, "low"),
        MedPriority = convertIDListToFClauseList(ActionsAffected, "medium"),
        HighPriority = convertIDListToFClauseList(ActionsAffected, "high"),
        MaxPriority = convertIDListToFClauseList(ActionsAffected, "overpower"),

        FRuleToMin = fuzzyRule::new(),
        FRuleToMin:addToLHS(fuzzySupport::fclause(Factor, "minimal")),
        FRuleToMin:addListToRHS(MinPriority),

        FRuleToLow = fuzzyRule::new(),
        FRuleToLow:addToLHS(fuzzySupport::fclause(Factor, "low")),
        FRuleToLow:addListToRHS(LowPriority),

        FRuleToMed = fuzzyRule::new(),
        FRuleToMed:addToLHS(fuzzySupport::fclause(Factor, "medium")),
        FRuleToMed:addListToRHS(MedPriority),

        FRuleToHigh = fuzzyRule::new(),
        FRuleToHigh:addToLHS(fuzzySupport::fclause(Factor, "high")),
        FRuleToHigh:addListToRHS(HighPriority),

        FRuleToMax = fuzzyRule::new(),
        FRuleToMax:addToLHS(fuzzySupport::fclause(Factor, "overpower")),
        FRuleToMax:addListToRHS(MaxPriority),

        FuzzyRulesList = [
            FRuleToMin,
            FRuleToLow,
            FRuleToMed,
            FRuleToHigh,
            FRuleToMax
            ].

%
predicates
    createCommonInverseFactor : (symbol ParamID, symbol* ActionIDList) -> fuzzyRule* FuzzyRuleList procedure (i, i).
clauses
    createCommonInverseFactor(Factor, ActionsAffected) = FuzzyRulesList :-
%
        MinPriority = convertIDListToFClauseList(ActionsAffected, "minimal"),
        LowPriority = convertIDListToFClauseList(ActionsAffected, "low"),
        MedPriority = convertIDListToFClauseList(ActionsAffected, "medium"),
        HighPriority = convertIDListToFClauseList(ActionsAffected, "high"),
        MaxPriority = convertIDListToFClauseList(ActionsAffected, "overpower"),

        FRuleToMin = fuzzyRule::new(),
        FRuleToMin:addToLHS(fuzzySupport::fclause(Factor, "overpower")),
        FRuleToMin:addListToRHS(MinPriority),

        FRuleToLow = fuzzyRule::new(),
        FRuleToLow:addToLHS(fuzzySupport::fclause(Factor, "high")),
        FRuleToLow:addListToRHS(LowPriority),

        FRuleToMed = fuzzyRule::new(),
        FRuleToMed:addToLHS(fuzzySupport::fclause(Factor, "medium")),
        FRuleToMed:addListToRHS(MedPriority),

        FRuleToHigh = fuzzyRule::new(),
        FRuleToHigh:addToLHS(fuzzySupport::fclause(Factor, "low")),
        FRuleToHigh:addListToRHS(HighPriority),

        FRuleToMax = fuzzyRule::new(),
        FRuleToMax:addToLHS(fuzzySupport::fclause(Factor, "minimal")),
        FRuleToMax:addListToRHS(MaxPriority),

        FuzzyRulesList = [
            FRuleToMin,
            FRuleToLow,
            FRuleToMed,
            FRuleToHigh,
            FRuleToMax
            ].

/*
Создание отчёта о состоянии реальности
*/
clauses
    getRealityDescription() = Description :-
        RulesDesc = getAllRulesDescription(packedFRules, ""),
        FuzzifiedActionsDesc = getAllActionsDescription(packedFActions, ""),
        Description = string::concat(RulesDesc, FuzzifiedActionsDesc).

predicates
    getAllRulesDescription : (fuzzyRule* FRuleList, string Accumulator) -> string FRuleListAsString procedure (i, i).
clauses
    getAllRulesDescription([], StrAcc) = StrAcc :-
        !.
    getAllRulesDescription([FRule | OtherRules], StrAcc) = Description :-
        FRuleAsString = toString_frule(FRule),
        Description = getAllRulesDescription(OtherRules, string::concat(FRuleAsString, "\n", StrAcc)).
        
predicates
    getAllActionsDescription : (fvar* FRuleList, string Accumulator) -> string FVarListAsString procedure (i, i).
clauses
    getAllActionsDescription([], StrAcc) = StrAcc :-
        !.
    getAllActionsDescription([FVar | OtherVars], StrAcc) = Description :-
        FVarAsString = toString_fvar(FVar),
        Description = getAllActionsDescription(OtherVars, string::concat(FVarAsString, StrAcc)).

end implement reality
