/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain/
***********************************************************************/

implement alife
    open core, alifeSettings

constants
    className = "core_logic/alife".
    classVersion = "".

clauses
    classInfo(className, classVersion).

%
class facts
    %
    reality_fact : reality := erroneous.
    
    main_logger_fact : logger := erroneous.
    
    action_select_logger_fact : logger := erroneous.

class facts -misc
    dumpReportsLogtype : logger::logtype := logger::txt().

% Создание и инициализация виртуальной реальности, где хранятся правила выбора действия и универсальная оценка параметров особи
clauses
    initReality() :-
        reality_fact := reality::new(),
        reality_fact:init(),
        dumpReality_checked(reality_fact).

class predicates
    dumpReality_checked : (reality RealityToDump).
clauses
    dumpReality_checked(Reality) :-
        alifeSettings::isDumpReality(),
        !,
        LogRealityState_logtype = dumpReportsLogtype,
        LogRealityState_filename = string::concat(
                alifeSettings::getRealityStateLogFilename(),
                logger::getFilenameExtensionFor(dumpReportsLogtype)
            ),
        dumpReality(Reality, LogRealityState_logtype, LogRealityState_filename).
    dumpReality_checked(_DontMatter).

class predicates
    dumpReality : (reality RealityObjectToDump, logger::logtype LogType, string LogFilename).
clauses
    dumpReality(Reality, LogType, LogFilename) :-
        Logger = logger::new(LogType, 2, LogFilename),
        Logger:record("event", "default", "Начинаем выгрузку отчёта о состоянии виртуальной реальности в файл лога. Отчёт получен от класса виртуальной реальности (reality)"),
        Report = Reality:getRealityDescription(),
        Logger:record("report", "reality", Report),
        Logger:closeLog().

%
class predicates
    newFuzzyMind : (fvar* InFVars, fuzzyRule* FRules, fvar* OutFVars) -> fuzzyInference FuzzyMind procedure (i, i, i).
clauses
    newFuzzyMind(InFVars, FRules, OutFVars) = FuzzyMind :-
        try
            FuzzyMind = fuzzyInference::new(alifeSettings::getFuzzyMindResolution())
        catch _SettingNotSet do
            FuzzyMind = fuzzyInference::new()
        end try,
        FuzzyMind:addInVarList(InFVars),
        FuzzyMind:addRuleList(FRules),
        FuzzyMind:addOutVarList(OutFVars).

% Обёртка для часто используемой процедуры обработки возможных исключений
class predicates
    errorhalt : (exception::traceID ExceptionTraceID, logger Logger, symbol MessageSource, string Message) erroneous (i, i, i, i).
clauses
    errorhalt(TraceID, Logger, _MsgSrc, Msg) :-
        Logger:isClosed(),
        !,
        errorHandler::continue(classInfo, TraceID, Msg).
    errorhalt(TraceID, Logger, MsgSrc, Msg) :-
        Logger:record("error", MsgSrc, Msg),
        Logger:closeLog(),
        errorHandler::continue(classInfo, TraceID, Msg).

/*
class predicates
    dumpIndividualClass_checked : (individual IndividToDump).
clauses
    dumpIndividualClass_checked(Individ) :-
        alifeSettings::isDumpIndividualClass(),
        !,
        LogIndividClass_LogType = dumpReportsLogType,
        LogIndividClass_Filename = string::concat(
                alifeSettings::getIndividClassLogFilename(),
                logger::getFilenameExtensionFor(LogIndividClass_LogType)
            ),
        dumpIndividualClass(Individ, LogIndividClass_LogType, LogIndividClass_Filename).
    dumpIndividualClass_checked(_DontMatter).
        
class predicates        
    dumpIndividualClass : (individual IndividToReport, logger::logtype LogType, string LogFilename).
clauses
    dumpIndividualClass(Individ, LogType, LogFilename) :-
        Logger = logger::new(LogType, 1, LogFilename),
        Logger:record("event", "default", "Полученный от класса individual отчёт о настройках класса:"),
        Logger:record("report", "individ", Individual:getClassDescription()),
        Logger:closeLog().
*/

class predicates
    dumpIndividualObject_checked : (individual IndividToDump, string IndividUniqueSignature).
clauses
    dumpIndividualObject_checked(Individ, SigStr) :-
        alifeSettings::isDumpCurrentIndividual(),
        !,
        LogIndividClass_LogType = dumpReportsLogType,
        LogIndividClass_Filename = string::concat(
                alifeSettings::getCurrentIndividualLogFilename(),
                SigStr,
                logger::getFilenameExtensionFor(LogIndividClass_LogType)
            ),
        dumpIndividualObject(Individ, SigStr, LogIndividClass_LogType, LogIndividClass_Filename).
    dumpIndividualObject_checked(_DontMatter1, _DontMatter2).
        
class predicates        
    dumpIndividualObject : (individual IndividToReport, string IndividUniqueSignature, logger::logtype LogType, string LogFilename).
clauses
    dumpIndividualObject(Individ, SigStr, LogType, LogFilename) :-
        Logger = logger::new(LogType, 6, LogFilename),
        Logger:record("event", "default", "Полученный от объекта класса individual отчёт о собственном состоянии:"),
        Logger:record("event", "default", string::concat("Уникальный идентификатор объекта: ", SigStr)), 
        Logger:record("event", "default", "Особенности класса individual, общие для всех объектов:"),
        Logger:record("report", "individ", Individ:getClassDescription()),
        Logger:record("event", "default", "Индивидуальные особенности состояния:"),
        Logger:record("report", "individ", Individ:getSelfDescription()),
        Logger:closeLog().

% 
clauses
    simulateLife(CellPhenotype/*, TargetEnding*/, ChangedIndividual) = Fitness :-
% Два файла отчёта: основной лог (simulateLife) и список действий (actionlist) будут созданы в любом случае, их формирование нельзя отключить
        LogType = alifeSettings::getMainLogType(),
        LogActionList_Filename = string::concatList([
                alifeSettings::getActionListLogFilenamePrefix(),
                toString(CellPhenotype),
                "#", toString(alifeSettings::getLifeLength()),
                logger::getFilenameExtensionFor(LogType)
            ]),
        action_select_logger_fact := logger::new(LogType, 200, LogActionList_Filename),
        LogMain_Filename = string::concatList([
                alifeSettings::getMainLogFilenamePrefix(),
                toString(CellPhenotype),
                "#", toString(alifeSettings::getLifeLength()),
                logger::getFilenameExtensionFor(LogType)
            ]),
        main_logger_fact := logger::new(LogType, 200, LogMain_Filename),
        main_logger_fact:record("event", "default", string::concat("Начата симуляция жизни особи. Фенотип клетки: ", toString(CellPhenotype))),
% инициализация  // Подразумевается, что где-то когда-то был создан объект класса reality!!
        try
            Individual = individual::new()    %
        catch CannotCreateIndivid_Exception do
            Msg_1 = "alife::simulateLife/1-> : Не удалось провести симуляцию жизни: runtime exception в конструкторе объекта класса individual.",
            errorhalt(CannotCreateIndivid_Exception, main_logger_fact, "individ", Msg_1)
        end try,
        main_logger_fact:record("event", "individ", "Успешно создан объект класса individual"),
%
        try
            Individual:init(CellPhenotype)    % К сожалению, объявление конструктора нельзя затолкать в интерфейс
        catch CannotInitIndivid_Exception do
            Msg_2 = "alife::simulateLife/1-> : Не удалось провести симуляцию жизни: runtime exception при инициализации особи.",
            errorhalt(CannotInitIndivid_Exception, main_logger_fact, "individ", Msg_2)
        end try,
        main_logger_fact:record("event", "individ", string::concat("Объект класса individual успешно инициализирован фенотипом ", toString(CellPhenotype))),
%
        main_logger_fact:record("report", "individ", string::concat("----Начальные параметры особи:\n", toString_individParams(Individual))),
/*
*/
        try
            FuzzyParams = Individual:getFuzzifiedParams()    % Получили (начальную) фаззификацию (всех) параметров особи
        catch IndividCannotFuzzyfy_Exception do
            Msg_3 = "alife::simulateLife/1-> : Не удалось провести симуляцию жизни: runtime exception при получении нечёткой оценки особью своих параметров",
            errorhalt(IndividCannotFuzzyfy_Exception, main_logger_fact, "individ", Msg_3)
        end try,
        main_logger_fact:record("event", "individ", "От особи успешно получена нечёткая оценка её параметров"),
        dumpIndividualObject_checked(Individual, string::concat(toString(CellPhenotype), "#beginning")), 
%
%        dumpFuzzyVarList(FuzzyParams, logger::xhtml(), "fuzzyParams_initial.log"),
%
        try
            LifeRules = reality_fact:getRules()    % Получили fuzzyRule* - список нечётких правил для текущей конкретизиции
        catch RealityCannotInitRuleset_Exception do
            Msg_4 = "alife::simulateLife/1-> : Не удалось провести симуляцию жизни: runtime exception при получении нечётких правил из текущего объекта класса reality",
            errorhalt(RealityCannotInitRuleset_Exception, main_logger_fact, "reality", Msg_4)
        end try,
        main_logger_fact:record("event", "reality", "От реальности успешно получен список актуальных правил выбора действий особью"),
%
%        dumpFuzzyRuleList(LifeRules, logger::xhtml(), "fuzzyRules.log"),
%
        try
            PossibleActions = reality_fact:getActions()    % Получили fvar* - список нечётких переменных, представляющих собой приоритеты действий, доступных для особи
        catch RealityCannotInitActionset_Exception do
            Msg_5 = "alife::simulateLife/1-> : Не удалось провести симуляцию жизни: runtime exception при получении списка доступных особи действий из текущего объекта класса reality",
            errorhalt(RealityCannotInitActionset_Exception, main_logger_fact, "reality", Msg_5)
        end try,
        main_logger_fact:record("event", "reality", string::concat("От реальности успешно получен список доступных особи действий\nПодробности в логе ", actionlist_log_filename)),
%
%        dumpFuzzyVarList(PossibleActions, logger::xhtml(), "fuzzyActions_initial.log"),
%
        try
            FuzzyMind = newFuzzyMind(FuzzyParams, LifeRules, PossibleActions)    % Создали нечёткий контроллер на основе параметров особи и правил виртуальной реальности
        catch CannotCreateFuzzyMind_Exception do
            Msg_6 = "alife::simulateLife/1-> : Не удалось провести симуляцию жизни: runtime exception при создании нечёткого контроллера приоритета действий",
            errorhalt(CannotCreateFuzzyMind_Exception, main_logger_fact, "default", Msg_6)
        end try,
        main_logger_fact:record("event", "default", "Успешно инициализирован нечёткий контроллер приоритета действий"),
%
%        dumpFuzzyInference(FuzzyMind, LogType, "fuzzyMind_initial.log"),
% симуляция жизни
        main_logger_fact:record("event", "default", string::concat("Начинаем итерировать процесс выбора и совершения особью действий. Количество итераций: ", toString(alifeSettings::getLifeLength()))),
        ChangedIndividual = repeatChoice(Individual, FuzzyMind,  alifeSettings::getLifeLength()),    % Повторяем выбор и совершение действий особью
        action_select_logger_fact:closeLog(), 
        dumpIndividualObject_checked(Individual, string::concat(toString(CellPhenotype), "#ending")), 
% оценка итогового состояния
        main_logger_fact:record("report", "individ", string::concat("----Итоговые параметры особи:\n", toString_individParams(ChangedIndividual))),
        main_logger_fact:record("event", "reality", "Начинаем оценку конечного состояния"),
        reality_fact:fuzzyParamsFromIndivid(ChangedIndividual),
        main_logger_fact:record("event", "reality", "Запускаем вычисление приспособленности особи на основе нечёткой оценки её конечного состояния"),
        Fitness = evaluateResults(reality_fact/*, TargetEnding*/),
        main_logger_fact:record("event", "default", string::concat("Получена итоговая приспособленность: ", toString(Fitness))),
        main_logger_fact:closeLog().

%
class predicates
    repeatChoice : (individual Individ, fuzzyInference FuzzyMind, integer DaysToLive) -> individual ChangedIndividual procedure (i, i, i).
%
clauses
    repeatChoice(Individ, _FuzzyMind, DayNumber) = Individ :-
        DayNumber < 1,    % То есть ноль или отрицательное
        !.
%        main_logger_fact:record("warning", "default", "Количество итераций выбора/совершения действий, назначенных особи, меньше 1: особь не будет изменена.").
    repeatChoice(Individ, FuzzyMind, DayNumber) = ChangedIndivid :-
% подготовка к выбору действия
        try
            ActionList = Individ:getActionsToPrioritize()    % Получили symbol* - список идентификаторов действий, среди которых надо выбирать
        catch IndividCannotDeduceActionSet_Exception do
            Msg_1 = "alife::repeatChoice/3-> : Не удалось провести итерирование процесса выбора/совершения действия особью: runtime exception при построении объектом класса individual списка действий, среди которых следует производить выбор.",
            errorhalt(IndividCannotDeduceActionSet_Exception, main_logger_fact, "individ", Msg_1)
        end try,
%        main_logger_fact:record("event", "individ", string::concat("От особи получен список действий, приоритеты которых ей следует расставить: ", toString(ActionList))),
% выбор и совершение действия
        try
            ActionID = getTopPriorityAction(FuzzyMind, ActionList)    % Получили ID того действия (выходной переменной из FuzzyMind), у которого наибольший приоритет
        catch CannotGetTopPriorityAction_Exception do
            Msg_2 = "alife::repeatChoice/3-> : Не удалось провести итерирование процесса выбора/совершения действия особью: runtime exception при получении действия с наибольшим приоритетом",
            errorhalt(CannotGetTopPriorityAction_Exception, main_logger_fact, "default", Msg_2)
        end try,
        main_logger_fact:record("event", "default", string::concat("Успешно получен ID действия с наибольшим приоритетом: ", toString(ActionID))),
        action_select_logger_fact:record("event", "individ", toString(ActionID)),
        try
            ChangesInMind = Individ:doAction(ActionID)    % Одновременно и изменяем состояние Individ, и получаем individual::paramChangeList* - список параметров, которые изменились после совершения действия
        catch IndividCannotDoAction_Exception do
            Msg_3 = string::concat("alife::repeatChoice/3-> : Не удалось провести итерирование процесса выбора/совершения действия особью: выполнение особью действия с ID ", toString(ActionID), " завершилось аварийно"),
            errorhalt(IndividCannotDoAction_Exception, main_logger_fact, "individ", Msg_3)
        end try,
        main_logger_fact:record("event", "individ", string::concat("Успешно выполнено действие особью, список изменений параметров:\n", toString_paramChangeList(ChangesInMind))), 
% оценка результатов совершения действия
        try
            ChangedFuzzyMind = changeMind(FuzzyMind, ChangesInMind)    % Меняем значения изменившихся параметров - входных переменных нечёткого контроллера).
        catch CannotChangeMind_Exception do
            Msg_4 = "alife::repeatChoice/3-> : Не удалось провести итерирование процесса выбора/совершения действия особью: сохранение изменений параметров особи после выполения действия завершилось аварийно",
            errorhalt(CannotChangeMind_Exception, main_logger_fact, "individ", Msg_4)
        end try,
%        main_logger_fact:record("event", "default", "Изменения параметров успешно записаны в нечёткий контроллер"), 
        ChangedIndivid = repeatChoice(Individ, ChangedFuzzyMind, DayNumber - 1).

%
class predicates
    changeMind : (fuzzyInference FuzzyMind, individual::paramChangeList Changes) -> fuzzyInference ChangedFuzzyMind procedure (i, i).
clauses
    changeMind(FuzzyMind, []) = FuzzyMind :-
        !.
    changeMind(FuzzyMind, [core::tuple(ParamID, ValueChange) | OtherChanges]) = ChangedFuzzyMind :-
        FVar = FuzzyMind:getInVar(ParamID),
        NewValue = FVar:xvalue + ValueChange,
        NewValue < FVar:xmin,    % Значения параметров не опускаются ниже установленных для каждого из них минимумов
        !,
        FVar:xvalue := FVar:xmin,
%        FuzzyMind:setInVarValue(ParamID, NewValue),
        ChangedFuzzyMind = changeMind(FuzzyMind, OtherChanges).
    changeMind(FuzzyMind, [core::tuple(ParamID, ValueChange) | OtherChanges]) = ChangedFuzzyMind :-
        FVar = FuzzyMind:getInVar(ParamID),
        NewValue = FVar:xvalue + ValueChange,
        NewValue > FVar:xmax,    % Значения параметров не поднимаются выше установленных для каждого из них максимумов
        !,
        FVar:xvalue := FVar:xmax,
        ChangedFuzzyMind = changeMind(FuzzyMind, OtherChanges).
    changeMind(FuzzyMind, [core::tuple(ParamID, ValueChange) | OtherChanges]) = ChangedFuzzyMind :-
        FVar = FuzzyMind:getInVar(ParamID),
        FVar:xvalue := FVar:xvalue + ValueChange,    % Всё, что нужно, было проверено двумя предложениями ранее.
        ChangedFuzzyMind = changeMind(FuzzyMind, OtherChanges).

%
class predicates
    getTopPriorityAction : (fuzzyInference FuzzyMind, symbol* ActionList) -> symbol ActionID procedure (i, i).
%
clauses
    getTopPriorityAction(FuzzyMind, ActionIDList) = ActionID :-
/*
        DebugStream = outputStream_string::new(),
        profileTime::init(),
        profileTime::start_pr("fuzzy"),
%
        profileTime::start_pr("aggregate"),
*/
        FuzzyMind:aggregateAll(),
/*
        profileTime::stop_pr("aggregate"),
%
        profileTime::start_pr("evaluate"),
*/
        FuzzyMind:evaluate_byIDList(ActionIDList),  % ОБЯЗАТЕЛЬНО перед вызовом этого предиката произвести аггрегацию всех правил в контроллере!
/*
        profileTime::stop_pr("evaluate"),
%
        profileTime::start_pr("defuzzy"),
*/
        try
            FuzzyMind:defuzzy_byIDList(ActionIDList)
        catch DefuzzyError do
            errorHandler::continue(classInfo, DefuzzyError, "alife::getTopPriorityAction/2-> : Ошибка при выполнении дефаззификации.")
        end try,
/*
        profileTime::stop_pr("defuzzy"),
%
        profileTime::start_pr("getmax"),
*/
%        dumpFuzzyInference(FuzzyMind, logger::txt(), "fuzzymind.log"),
        
        ActionID = getVarWithMaxXValue(FuzzyMind, ActionIDList, 0, "ErroneousAction").    % Получаем ID той выходной переменной, у которой наибольшее xvalue.
/*
        profileTime::stop_pr("getmax"),
%
        profileTime::stop_pr("fuzzy"),
        profileTime::printAndReset(DebugStream),
%
        Msg = DebugStream:getString(),
        main_logger_fact:record("report", "fuzzy", Msg).
*/
%
class predicates
    getVarWithMaxXValue : (fuzzyInference FuzzyMind, symbol* FVarIDList, real AccumulatorValue, symbol AccumulatorID) -> symbol ActionID procedure (i, i, i, i).
%
clauses
    getVarWithMaxXValue(_FuzzyMind, [], _DontMatter, ActionID) = ActionID :-
        !.
    getVarWithMaxXValue(FuzzyMind, [FVarID | OtherIDList], CurrentMaxValue, _CurrentTopActionID) = ActionID :-
        try
            FVar = FuzzyMind:getOutVar(FVarID)
        catch NonExistentVariable_Exception do
            Msg = string::concat("alife::getVarWithMaxXValue/4-> : не удалось извлечь выходную переменную из механизма нечёткого вывода: ID ",
                    toString(FVarID), " неизвестен."),
            errorHandler::continue(classInfo, NonExistentVariable_Exception, Msg)
        end try,
        FVar:xvalue > CurrentMaxValue,
        !,
        ActionID = getVarWithMaxXValue(FuzzyMind, OtherIDList, FVar:xvalue, FVar:id).
    getVarWithMaxXValue(FuzzyMind, [_AlreadyCheckedFVarID | OtherIDList], CurrentMaxValue, CurrentTopActionID) = ActionID :-
        ActionID = getVarWithMaxXValue(FuzzyMind, OtherIDList, CurrentMaxValue, CurrentTopActionID),
        !.

%
class predicates
    evaluateResults : (reality Reality/*, alifeSettings::ending TargetEnding*/) -> real Fitness procedure (i/*, i*/).
%
clauses
    evaluateResults(_Reality) = Fitness :-
        ending(_EndingID, []) = alifeSettings::getTargetEnding(),
        main_logger_fact:record("warning", "default", "Список требований для конечного состояния пуст, приспособленность условно принята максимальной"),
        Fitness = 1,
        !.
    evaluateResults(Reality/*, Ending*/) = Fitness :-
        ending(_EndingID, Requirements) = alifeSettings::getTargetEnding(),
        main_logger_fact:record("event", "default", string::concat("Начата проверка соответствия конечного состояния особи требованиям.\nСписок требований:\n", fuzzySupport::toString_fclauseList(Requirements))),
        Fitness = evaluateRequirements(Reality, Requirements, 0, 0).

%
class predicates
    evaluateRequirements : (
        reality Reality, 
        fuzzySupport::fclause* Requirements,
        real AccNumerator,
        real AccDenominator) 
            -> real Closeness.
%
clauses
    evaluateRequirements(_Reality, [], _AccN, AccD) = _Closeness :-
        AccD = 0,
        !,
        Msg = "alife::evaluateRequirements/3-> : Не удалось оценить соответствие требованиям: требуемые параметры особи определены на отрезках нулевой длины.",
        errorHandler::raise(classInfo, Msg).
    evaluateRequirements(_Reality, [], AccN, AccD) = Closeness :-
        !,
        Closeness = 1 - math::sqrt(AccN / AccD).
    evaluateRequirements(
            Reality,
            [fuzzySupport::fclause(ParamNeeded, ParamValueNeeded) | OtherRequirements],
            OldAccN, 
            OldAccD)
                = Closeness :-
        try
            FVar = Reality:getVar(ParamNeeded)
        catch RealityCannotReturnFVar_Exception do
            Msg_1 = string::concat("alife::evaluateRequirements/3-> : Не удалось оценить соответствие требованию \"", toString(ParamNeeded), " is ", toString(ParamValueNeeded), "\": извлечение фаззифицированного параметра из объекта класса reality завершилось аварийно."),
            errorhalt(RealityCannotReturnFVar_Exception, main_logger_fact, "reality", Msg_1)
        end try,
        try
            FSet = FVar:getTerm(ParamValueNeeded)
        catch FVarCannotReturnTerm_Exception do
            Msg_2 = string::concat("alife::evaluateRequirements/3-> : Не удалось оценить соответствие требованию \"", toString(ParamNeeded), " is ", toString(ParamValueNeeded), "\": извлечение лингвистического значения для фаззифицированного параметра завершилось аварийно (Неверная оценка классом reality параметров особи?)."),
            errorhalt(FVarCannotReturnTerm_Exception, main_logger_fact, "fuzzy", Msg_2)
        end try,
        try
            FSetCenter = FSet:center_of_gravity(FVar:xmin, FVar:xmax)
        catch FSetCannotCalcCOG_Exception do
            Msg_5 = string::concat("alife::evaluateRequirements/3-> : Не удалось оценить соответствие требованию \"", toString(ParamNeeded), " is ", toString(ParamValueNeeded), "\": дефаззификация лингвистического значения требования завершилась аварийно"),
            errorhalt(FSetCannotCalcCOG_Exception, main_logger_fact, "fuzzy", Msg_5)
        end try,
/*
        try
%            CurrentCloseness =  FSet:get_membership(FVar:xvalue) %<--------------------------------------------------
            CurrentCloseness = evaluateCloseness(FSetCenter, FVar:xvalue, FVar:xmin, FVar:xmax)
        catch CannotCalcTermCenterPoint_Exception do
            Msg_3 = string::concat("alife::evaluateRequirements/3-> : Не удалось оценить соответствие требованию \"", toString(ParamNeeded), " is ", toString(ParamValueNeeded), "\": вычисление степени соответствия чёткого значения параметра лингвистическому завершилось аварийно."),
            errorhalt(CannotCalcTermCenterPoint_Exception, main_logger_fact, "fuzzy", Msg_3)
        end try,
*/
        NewAccN = OldAccN + math::sqr(FSetCenter - FVar:xvalue),
        NewAccD = OldAccD + math::sqr(FVar:xmax - FVar:xmin),
/*
        Msg_4 = string::concatList([
            "Оценка требования \"", toString(ParamNeeded), " is ", toString(ParamValueNeeded), "\":", toString(CurrentCloseness), "\n Итого накопленное соответствие = ",
            toString(NewCloseness)]),
        main_logger_fact:record("event", "default", Msg_4),
*/
        Closeness = evaluateRequirements(Reality, OtherRequirements, NewAccN, NewAccD).

/*
%
class predicates
    evaluateCloseness : (real FuzzyTermCenter, real CrispValue, real MinValue, real MaxValue) -> real Closeness procedure (i, i, i, i).
clauses
    evaluateCloseness(FTermCenter, XVal, MinVal, MaxVal) = Closeness :-
        Distance = math::abs(FTermCenter - XVal),
        Dispersion = math::max(math::abs(FTermCenter - MinVal), math::abs(MaxVal - FTermCenter)),
        Dispersion <> 0,    % Обратное возможно только при кривых руках проектировщика: если MinVal, MaxVal и FTermCenter равны.
        !,
        Closeness = 1 - Distance/Dispersion.
    evaluateCloseness(_FTC, _XV, _MinV, _MaxV) = _DontMatter :-
        Msg = "alife::evaluateCloseness/4-> : Не удалось вычислить относительную близость заданного значения к желаемому: неверные параметры",
        errorHandler::raise(classInfo, Msg).
*/

%
class predicates
    dumpFuzzyVarList : (fvar* FVarList, logger::logtype LogType, string LogFileName) procedure (i, i, i).
clauses
    dumpFuzzyVarList(FVarList, LogType, LogFileName) :-
        Log = logger::new(LogType, 50, LogFileName),
        Log:record("event", "default", "Начат сброс сведений о нечётких переменных в файл лога. Ниже перечислены сохраняемые нечёткие переменные, как они описываются подсистемой нечёткого вывода."),
        fvarListToLog(FVarList, Log),
        Log:closeLog().

class predicates
    fvarListToLog : (fvar* FVarList, logger Log) procedure (i, i).
clauses
    fvarListToLog([], _Log) :-
        !.
    fvarListToLog([FVar | OtherFVars], Log) :-
        FVarAsString = fuzzySupport::toString_fvar(FVar),
        Log:record("report", "fuzzy", FVarAsString),
        fvarListToLog(OtherFVars, Log).
        
%
class predicates
    dumpFuzzyRuleList : (fuzzyRule* FRuleList, logger::logtype LogType, string LogFileName) procedure (i, i, i).
clauses
    dumpFuzzyRuleList(FRuleList, LogType, LogFileName) :-
        Log = logger::new(LogType, 50, LogFileName),
        Log:record("event", "default", "Начат сброс сведений о правилах нечёткого вывода в файл лога. Ниже перечислены сохраняемые нечёткие правила, как они описываются подсистемой нечёткого вывода."),
        fruleListToLog(FRuleList, Log),
        Log:closeLog().

class predicates
    fruleListToLog : (fuzzyRule* FVarList, logger Log) procedure (i, i).
clauses
    fruleListToLog([], _Log) :-
        !.
    fruleListToLog([FRule | OtherFRules], Log) :-
        FRuleAsString = fuzzySupport::toString_frule(FRule),
        Log:record("report", "fuzzy", FRuleAsString),
        fruleListToLog(OtherFRules, Log).

/*
%
class predicates
    dumpFuzzyInference_checked : (fuzzyInference FuzzyInferenceEngine).
clauses
    dumpFuzzyInference_checked(FInferEng) :-
        alifeSettings::isDumpFuzzyMind,
        !,
        LogType = dumpReportsLogType,
        LogFilename = alifeSettings::getFuzzyMindLogFilename()
*/

%
class predicates
    dumpFuzzyInference : (fuzzyInference FInferEngine, logger::logtype LogType, string LogFileName) procedure (i, i, i).
clauses
    dumpFuzzyInference(FInfer, LogType, LogFileName) :-
        Log = logger::new(LogType, 50, LogFileName),
        Log:record("event", "default", "Начат сброс сведений о текущем состоянии механизма нечёткого вывода в файл лога."),
        Log:record("event", "default", "Входные переменные:"),
        foreach FInVar = FInfer:getInVar_nd() do
            FInVarAsString = fuzzySupport::toString_fvar(FInVar),
            Log:record("report", "fuzzy", FInVarAsString)
        end foreach,
        Log:record("event", "default", "Правила вывода:"),
        foreach FRule = FInfer:getRule_nd() do
            FRuleAsString = fuzzySupport::toString_frule(FRule),
            Log:record("report", "fuzzy", FRuleAsString)
        end foreach,
        Log:record("event", "default", "Выходные переменные:"),
        foreach FOutVar = FInfer:getOutVar_nd() do
            FOutVarAsString = fuzzySupport::toString_fvar(FOutVar),
            Log:record("report", "fuzzy", FOutVarAsString)
        end foreach,
        Log:closeLog().
        
%
clauses
    toString_paramChangeList([]) = "" :-
        !.
    toString_paramChangeList([ParamChange | OtherParamChanges]) = string::concat(Description_Head, Description_Tail) :-
        Description_Head = toString_paramChangeList(OtherParamChanges),
        Description_Tail = toString_paramChange(ParamChange).

clauses
    toString_paramChange(core::tuple(ParamID, ParamChange)) = Desc :-
        Desc = string::format("%s: %-.2f\n", ParamID, ParamChange).
        
%
clauses
    toString_ending(ending(EndingID, FClauseList)) = string::concat(HeaderStr, RequirementsAsStr) :-
        HeaderStr = string::format("Целевое конечное состояние: ID %s", EndingID),
        RequirementsAsStr = fuzzySupport::toString_fclauseList(FClauseList).

clauses
    toString_individParams(Individ) = Description :-
        Str = outputStream_string::new(),
        foreach Individ:getParameterData_nd(ParamID, ParamVal, ParamMin, ParamMax) do
            Str:writef("%s: %.3f [%.2f..%.2f]\n", ParamID, ParamVal, ParamMin, ParamMax)
        end foreach,
        Description = Str:getString(),
        Str:close().
        
end implement alife
