/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement formBasic
    inherits formWindow
    open core, vpiDomains

constants
    className = "interface/formBasic".
    classVersion = "".

clauses
    classInfo(className, classVersion).

clauses
    display(Parent) = Form :-
        Form = new(Parent),
        Form:show().

clauses
    new(Parent):-
        formWindow::new(Parent),
        generatedInitialize().

class predicates
    extractFClause : (string Source) -> fuzzySupport::fClause FClause procedure (i).
clauses
    extractFClause(Str) = fuzzySupport::fclause(ParamID, ParamTermID) :-
        [ParamIDStr, ParamTermStr | _DontMatter]  = string::split(Str, ":"),
        ParamID = convert(symbol, string::trim(ParamIDStr)),
        ParamTermID = convert(symbol, string::trim(ParamTermStr)),
        !.
    extractFClause(_ErroneousStr) = _DontMatter :-
        exception::raise(classInfo, runtime_exception::invalidTermRepresentation).

class predicates
    extractFClauseList : (string* Source) -> fuzzySupport::fClause* FClauseList procedure (i).
clauses
    extractFClauseList([]) = [] :-
        !.
    extractFClauseList([ClauseStr | AccStr]) = [Clause | Acc] :-
        Acc = extractFClauseList(AccStr),
        Clause = extractFClause(ClauseStr).

class predicates
    extractEnding : (symbol EndingID, string Input) -> alifeSettings::ending EndingTerm procedure (i, i).
clauses
    extractEnding(EID, Str) = alifeSettings::ending(EID, ReqList) :-
        ReqList = extractFClauseList(string::split(Str, "\n")).

predicates
    tryGetPhenotypeFromInput : () -> cell::phenotype PhenotypeTerm determ.
clauses
    tryGetPhenotypeFromInput() = Phenotype :-
        try
            Phenotype = [
                toTerm(edPhys_ctl:getText()),
                toTerm(edCogn_ctl:getText()),
                toTerm(edCreat_ctl:getText()),
                toTerm(edMasc_ctl:getText()),
                toTerm(edFem_ctl:getText()),
                toTerm(edIntr_ctl:getText()),
                toTerm(edSex_ctl:getText()),
                toTerm(edAggr_ctl:getText())
                ]
        catch _AnyInputExceptionQueue do
            StreamE = formBasic::getOutputStream(),    % окно сообщений
            StreamE:write("Неверно заданный фенотип!\n"),
%            exceptionDump::dump(StreamE, AnyInputExceptionQueue),
            StreamE:close(),
            fail()
        end try.

predicates
    trySetMainSettingsFromInput : () determ.
clauses
    trySetMainSettingsFromInput() :-
        try
            alifeSettings::setLifeLength(toTerm(edLifeLength_ctl:getText())),
            alifeSettings::setTargetEnding(extractEnding("simple-ending", edEnding_ctl:getText())),
            alifeSettings::setMainLogType(toTerm(edLogType_ctl:getText())), % logger::xhtml()),
            alifeSettings::setFuzzyMindResolution(toTerm(edResolution_ctl:getText()))
        catch _AnyInputExceptionQueue do
            StreamE = formBasic::getOutputStream(),    % окно сообщений
            StreamE:write("Неверно заданные параметры!\n"),
%            exceptionDump::dump(StreamE, AnyInputExceptionQueue),
            StreamE:close(),
            fail()
        end try.

predicates
    tryProcessPhenotype : (cell::phenotype PhenotypeToProcess, individual ConstructedIndivid) determ (i, o).
clauses    
    tryProcessPhenotype(Phenotype, Individual) :-
        try
            alife::initReality(),
            Fitness = alife::simulateLife(Phenotype, Individual),
            PhenotypeStr = toString(Phenotype),
            Msg = string::format(
                "Fitness = %.4f, остальное в логах для фенотипа %s\n",
                Fitness, PhenotypeStr),
            Stream = formBasic::getOutputStream(),
            Stream:write(Msg)
        catch AnyExceptionQueue do
            StreamE = formBasic::getOutputStream(),
            StreamE:write("Ошибка обработки данных."),
            exceptionDump::dump(StreamE, AnyExceptionQueue),
            StreamE:close(),
            fail()
        end try.

class predicates
    getOutputStream : () -> outputStream MainMessageFormOStream.
clauses
    getOutputStream() = OStream :-
        ApplWnd = applicationWindow::get(),
        TaskWnd = convert(taskWindow, ApplWnd),
        OStream = TaskWnd:getMessageStream().
    
/*
class predicates
    showIndivid : (paramMeter DrawingControl, individual IndividualToShow).
clauses
    showIndivid(ParamMeter, Individ) :-
        foreach Individ:getParameterData_nd(ParamLabel, ParamValue, ParamMinValue, ParamMaxValue) do
            ParamMeter:setValue(ParamLabel, paramMeter::pmval(ParamMinValue, 0, ParamValue, ParamMaxValue))
        end foreach,
        ParamMeter:invalidate().
*/

predicates
    onOkClick : button::clickResponder.
clauses
    onOkClick(_Source) = button::noAction :-
        trySetMainSettingsFromInput(),
        Phenotype = tryGetPhenotypeFromInput(),
        tryProcessPhenotype(Phenotype, Individual),
        !,
/*
        showIndivid(paramMeter_ctl, Individual),
        paramMeter_ctl:initScrollControl(vertScroll_ctl).    % Чтобы можно было пользоваться прокруткой (список параметров м. б. очень длинным)
*/
        %
        TaskWnd = convert(taskWindow, applicationWindow::get()),
        Viewer = TaskWnd:individViewWindow,
        Viewer:showIndivid(Phenotype, Individual).
    onOkClick(_Source) = button::noAction.

predicates
    onSize : window::sizeListener.
clauses
    onSize(_Source) :-
/*
        This:getSize(CW, CH),
        memLog_ctl:setSize(math::floor(CW / 2), CH - 18)
*/
        succeed().    % TODO formBasic:onSize

% Кнопка "Список ID"
predicates
    onBtnHelpWndClick : button::clickResponder.
clauses
    onBtnHelpWndClick(_Source) = button::noAction :-
        TaskWin = applicationWindow::get(),
        _ = fmIDList::display(TaskWin).

predicates
    checkInputValueByControl : (editControl InputSource).
clauses
    checkInputValueByControl(Source) :-
        % поле "Количество итераций"
        Source:getCtrlId() = edLifeLength_ctl:getCtrlId(),
        !,
        CheckedValue = checkValue(Source:getText(), "unsigned", core::some(0), core::none(), stdio::getOutputStream()),
        Source:setText(CheckedValue).
    checkInputValueByControl(Source) :-
        % поле "Концовка"
        Source:getCtrlId() = edEnding_ctl:getCtrlId(),
        !,
        CheckedValue = checkValue(Source:getText(), "ending", core::none(), core::none(), stdio::getOutputStream()),
        Source:setText(CheckedValue).
    checkInputValueByControl(Source) :-
        % поле "Точность нечёткого контроллера"
        Source:getCtrlId() = edResolution_ctl:getCtrlId(),
        !,
        CheckedValue = checkValue(Source:getText(), "unsigned", core::some(10), core::none(), stdio::getOutputStream()),
        Source:setText(CheckedValue).
    checkInputValueByControl(Source) :-
        % одно из полей ввода склонностей
        isInclInputControl(Source:getCtrlId()),
        !,
        CheckedValue = checkValue(Source:getText(), "unsigned", core::some(0), core::some(3), stdio::getOutputStream()),
        Source:setText(CheckedValue).
    checkInputValueByControl(_Source).

predicates
    isInclInputControl : (integer EditControlToCheck) determ.
clauses
    isInclInputControl(EdCtlID) :-
        (
        EdCtlID = edPhys_ctl:getCtrlID() 
        or EdCtlID = edCogn_ctl:getCtrlID()
        or EdCtlID = edCreat_ctl:getCtrlID()
        or EdCtlID = edMasc_ctl:getCtrlID()
        or EdCtlID = edFem_ctl:getCtrlID()
        or EdCtlID = edIntr_ctl:getCtrlID()
        or EdCtlID = edSex_ctl:getCtrlID()
        or EdCtlID = edAggr_ctl:getCtrlID()
        ),
        !.

class predicates
    constructResponceString_minmaxvalues : (optional{integer} ExpectedMinValue, optional{integer} ExpectedMaxValue) -> string TextualRepresentation.
clauses
    constructResponceString_minmaxvalues(core::some(MinVal), core::some(MaxVal)) = Response :-
        Response = string::format(", большее %d и меньшее %d", MinVal, MaxVal).
    constructResponceString_minmaxvalues(core::none(), core::some(MaxVal)) = Response :-
        Response = string::format(", меньшее %d", MaxVal).
    constructResponceString_minmaxvalues(core::some(MinVal), core::none()) = Response :-
        Response = string::format(", большее %d", MinVal).
    constructResponceString_minmaxvalues(core::none(), core::none()) = "".
        
        
class predicates
    checkValue : (
        string EditControlText, 
        symbol ExpectedType, 
        optional{integer} MinValueIfNumber, 
        optional{integer} MaxValueIfNumber, 
        outputStream StreamForErrorMessages) 
            -> string CheckedValue.
clauses
    checkValue(InputText, "unsigned", _Min, _Max, OStream) = MarkedValue :-
        % если текст - не беззнаковое целое
        hasDomain(unsigned, _TestUnsigned),
        not(_TestUnsigned = tryToTerm(InputText)),
        % то если ранее не пометили, помечаем текст символами "**" в конце строки
        ((
            _ = string::search(InputText, "**"),
            MarkedValue = InputText)
                or
           (MarkedValue = string::concat(InputText, "**")
        )),
        !,
        OStream:write("Неверное значение - помечено \"**\". Ожидалось беззнаковое целое\n").
    checkValue(InputText, "unsigned", Min, Max, OStream) = CheckedValue :-
        hasDomain(unsigned, Value),
        Value = toTerm(InputText),    % если какой баг в предыдущем предложении - будет runtime error!
        % если текст и вправду беззнаковое целое, то проверяем, попадает ли оно в установленные рамки
        ((
            core::some(MinVal) = Min,
            Value < convert(unsigned, MinVal), 
            CheckedValue = toString(MinVal))
                or
           (core::some(MaxVal) = Max,
            Value > convert(unsigned, MaxVal),
            CheckedValue = toString(MaxVal)
        )),
        % Теперь конструируем строку отзыва о проверке
        !,
        RespStr = constructResponceString_minmaxvalues(Min, Max),
        OStream:write(string::format("Неверное число: %s. Ожидалось беззнаковое целое%s.\nЗаменено на %s\n", 
            InputText, RespStr, CheckedValue)).
    checkValue(InputText, _UnrecognizedType, _DontMatter1, _DontMatter2, _NothingToWrite) = InputText.
        
%
predicates
    convertPhenotypeToPolygonalMeterData : (cell::phenotype, polygonalMeter::corner_value_list) procedure (i, o).
clauses
    convertPhenotypeToPolygonalMeterData([Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr | _], Data) :-
        Data = [
            polygonalMeter::cornerval("Ph", convert(integer, Phys)),
            polygonalMeter::cornerval("Cg", convert(integer, Cogn)),
            polygonalMeter::cornerval("Cr", convert(integer, Creat)),
            polygonalMeter::cornerval("Ms", convert(integer, Masc)),
            polygonalMeter::cornerval("Fm", convert(integer, Fem)),
            polygonalMeter::cornerval("In", convert(integer, Intr)),
            polygonalMeter::cornerval("Sx", convert(integer, Sex)),
            polygonalMeter::cornerval("Ag", convert(integer, Aggr))
            ],
        !.
    convertPhenotypeToPolygonalMeterData(_ErroneousPhenotype, Data) :-
        Data = [
            polygonalMeter::cornerval("Ph", 0),
            polygonalMeter::cornerval("Cg", 0),
            polygonalMeter::cornerval("Cr", 0),
            polygonalMeter::cornerval("Ms", 0),
            polygonalMeter::cornerval("Fm", 0),
            polygonalMeter::cornerval("In", 0),
            polygonalMeter::cornerval("Sx", 0),
            polygonalMeter::cornerval("Ag", 0)
            ].

%
predicates
    randomizeInclInputFields : ().
clauses
    randomizeInclInputFields() :-
        Phys = math::random(4),
        edPhys_ctl:setText(toString(Phys)),
        Cogn = math::random(4),
        edCogn_ctl:setText(toString(Cogn)),
        Creat = math::random(4),
        edCreat_ctl:setText(toString(Creat)),
        Masc = math::random(4),
        edMasc_ctl:setText(toString(Masc)),
        Fem = math::random(4),
        edFem_ctl:setText(toString(Fem)),
        Intr = math::random(4),
        edIntr_ctl:setText(toString(Intr)),
        Sex = math::random(4),
        edSex_ctl:setText(toString(Sex)),
        Aggr = math::random(4),
        edAggr_ctl:setText(toString(Aggr)).

predicates
    onShow : window::showListener.
clauses
    onShow(_Source, _Data) :-
        %
        randomizeInclInputFields(),
        ((
            Phenotype = tryGetPhenotypeFromInput())
                or
           (Phenotype = [0, 0, 0, 0, 0, 0, 0, 0]
        )),
        !,
        polygonalMeter_ctl:cornerCount := 8,
        polygonalMeter_ctl:steps := 4,
        convertPhenotypeToPolygonalMeterData(Phenotype, Data),
        polygonalMeter_ctl:values := Data,
        polygonalMeter_ctl:minvalue := -1,
        polygonalMeter_ctl:maxvalue := 3,
        polygonalMeter_ctl:invalidate(),
        OStream = memLog_ctl:getOutputStream(),
        OStream:write("Конечное состояние вводится в формате: ID_параметра:ID_нечёткого_значения\n"),
        Ostream:write("Список идентификаторов под кнопкой с соответствующим названием\n"),
        OStream:write("Тип отчёта ожидается xhtml(), xml() или txt()\n"),
        Ostream:write("Склонности варьируются от 0 до 3."),
        OStream:close().

% 
predicates
    onEditLoseFocus : window::loseFocusListener.
clauses
    onEditLoseFocus(Source) :-
        checkInputValueByControl(convert(editControl, Source)),
        fail().
    onEditLoseFocus(Source) :-    % U R DOING IT WRONG!
        SourceAsControl = convert(control, Source),
        isInclInputControl(SourceAsControl:getCtrlId()),
        Phenotype = tryGetPhenotypeFromInput(),
        !,
        convertPhenotypeToPolygonalMeterData(Phenotype, Data),
        polygonalMeter_ctl:values := Data,
        polygonalMeter_ctl:invalidate().
    onEditLoseFocus(_Source).

/*
predicates
    onVertScrollScroll : scrollControl::scrollListener.
clauses
    onVertScrollScroll(Source, ScrollType, ThumbPosition) :-
    % ОБЯЗАТЕЛЬНО надо проинициализировать соответствующий scrollControl методом paramMeter:initScrollControl/0 !.
        paramMeter_ctl:scrollByScrollEventParameters(Source, ScrollType, ThumbPosition).
*/

% This code is maintained automatically, do not update it manually. 15:31:53-27.4.2009
facts
    ok_ctl : button.
    cancel_ctl : button.
    memLog_ctl : messagecontrol.
    edLifeLength_ctl : editControl.
    edLogType_ctl : editControl.
    btnHelpWnd_ctl : button.
    edPhys_ctl : editControl.
    edCogn_ctl : editControl.
    edCreat_ctl : editControl.
    edMasc_ctl : editControl.
    edFem_ctl : editControl.
    edIntr_ctl : editControl.
    edSex_ctl : editControl.
    edAggr_ctl : editControl.
    edResolution_ctl : editControl.
    edEnding_ctl : editControl.
    polygonalMeter_ctl : polygonalmeter.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setFont(vpi::fontCreateByName("MS Sans Serif", 8)),
        setText("formBasic"),
        setRect(rct(50,40,362,236)),
        setDecoration(titlebar([closebutton(),maximizebutton(),minimizebutton()])),
        setBorder(thinBorder()),
        setState([wsf_ClipSiblings,wsf_ClipChildren]),
        menuSet(noMenu),
        addShowListener(generatedOnShow),
        addShowListener(onShow),
        addSizeListener(onSize),
        ok_ctl := button::newOk(This),
        ok_ctl:setText("&Process"),
        ok_ctl:setPosition(208, 182),
        ok_ctl:setAnchors([control::right,control::bottom]),
        ok_ctl:setClickResponder(onOkClick),
        cancel_ctl := button::newCancel(This),
        cancel_ctl:setText("&Close"),
        cancel_ctl:setPosition(260, 182),
        cancel_ctl:setAnchors([control::right,control::bottom]),
        memLog_ctl := messagecontrol::new(This),
        memLog_ctl:setPosition(4, 128),
        memLog_ctl:setSize(304, 52),
        edLifeLength_ctl := editControl::new(This),
        edLifeLength_ctl:setText("10"),
        edLifeLength_ctl:setPosition(4, 14),
        edLifeLength_ctl:addLoseFocusListener(onEditLoseFocus),
        edLogType_ctl := editControl::new(This),
        edLogType_ctl:setText("xhtml()"),
        edLogType_ctl:setPosition(4, 44),
        edLogType_ctl:setHeight(12),
        edLogType_ctl:setMultiLine(),
        edLogType_ctl:addLoseFocusListener(onEditLoseFocus),
        btnHelpWnd_ctl := button::new(This),
        btnHelpWnd_ctl:setText("Список ID"),
        btnHelpWnd_ctl:setPosition(4, 100),
        btnHelpWnd_ctl:setSize(64, 12),
        btnHelpWnd_ctl:setClickResponder(onBtnHelpWndClick),
        edPhys_ctl := editControl::new(This),
        edPhys_ctl:setText("2"),
        edPhys_ctl:setPosition(136, 12),
        edPhys_ctl:addLoseFocusListener(onEditLoseFocus),
        edCogn_ctl := editControl::new(This),
        edCogn_ctl:setText("3"),
        edCogn_ctl:setPosition(136, 28),
        edCogn_ctl:addLoseFocusListener(onEditLoseFocus),
        edCreat_ctl := editControl::new(This),
        edCreat_ctl:setText("2"),
        edCreat_ctl:setPosition(136, 42),
        edCreat_ctl:addLoseFocusListener(onEditLoseFocus),
        edMasc_ctl := editControl::new(This),
        edMasc_ctl:setText("0"),
        edMasc_ctl:setPosition(136, 56),
        edMasc_ctl:addLoseFocusListener(onEditLoseFocus),
        edFem_ctl := editControl::new(This),
        edFem_ctl:setText("1"),
        edFem_ctl:setPosition(136, 70),
        edFem_ctl:addLoseFocusListener(onEditLoseFocus),
        edIntr_ctl := editControl::new(This),
        edIntr_ctl:setText("1"),
        edIntr_ctl:setPosition(136, 84),
        edIntr_ctl:addLoseFocusListener(onEditLoseFocus),
        edSex_ctl := editControl::new(This),
        edSex_ctl:setText("1"),
        edSex_ctl:setPosition(136, 98),
        edSex_ctl:addLoseFocusListener(onEditLoseFocus),
        edAggr_ctl := editControl::new(This),
        edAggr_ctl:setText("2"),
        edAggr_ctl:setPosition(136, 112),
        edAggr_ctl:addLoseFocusListener(onEditLoseFocus),
        edResolution_ctl := editControl::new(This),
        edResolution_ctl:setText("50"),
        edResolution_ctl:setPosition(128, 182),
        edResolution_ctl:addLoseFocusListener(onEditLoseFocus),
        edEnding_ctl := editControl::new(This),
        edEnding_ctl:setText("attrSTR:low"),
        edEnding_ctl:setPosition(4, 70),
        edEnding_ctl:setWidth(64),
        edEnding_ctl:setHeight(28),
        edEnding_ctl:setMultiLine(),
        edEnding_ctl:setWantReturn(),
        edEnding_ctl:addLoseFocusListener(onEditLoseFocus),
        polygonalMeter_ctl := polygonalmeter::new(This),
        polygonalMeter_ctl:setPosition(188, 2),
        polygonalMeter_ctl:setSize(120, 120),
        StaticText_ctl = textControl::new(This),
        StaticText_ctl:setText("Итераций выбора"),
        StaticText_ctl:setPosition(4, 2),
        StaticText_ctl:setSize(64, 10),
        StaticText2_ctl = textControl::new(This),
        StaticText2_ctl:setText("Тип отчёта"),
        StaticText2_ctl:setPosition(4, 30),
        StaticText1_ctl = textControl::new(This),
        StaticText1_ctl:setText("Конечное состояние"),
        StaticText1_ctl:setPosition(4, 58),
        StaticText1_ctl:setSize(72, 10),
        StaticText3_ctl = textControl::new(This),
        StaticText3_ctl:setText("Physical"),
        StaticText3_ctl:setPosition(84, 14),
        StaticText4_ctl = textControl::new(This),
        StaticText4_ctl:setText("Cognitive"),
        StaticText4_ctl:setPosition(84, 28),
        StaticText5_ctl = textControl::new(This),
        StaticText5_ctl:setText("Creative"),
        StaticText5_ctl:setPosition(84, 42),
        StaticText6_ctl = textControl::new(This),
        StaticText6_ctl:setText("Masculine"),
        StaticText6_ctl:setPosition(84, 56),
        StaticText7_ctl = textControl::new(This),
        StaticText7_ctl:setText("Feminine"),
        StaticText7_ctl:setPosition(84, 70),
        StaticText8_ctl = textControl::new(This),
        StaticText8_ctl:setText("Introvertive"),
        StaticText8_ctl:setPosition(84, 84),
        StaticText9_ctl = textControl::new(This),
        StaticText9_ctl:setText("Sexual"),
        StaticText9_ctl:setPosition(84, 98),
        StaticText10_ctl = textControl::new(This),
        StaticText10_ctl:setText("Aggressive"),
        StaticText10_ctl:setPosition(84, 112),
        StaticText11_ctl = textControl::new(This),
        StaticText11_ctl:setText("Точность нечёткого контроллера"),
        StaticText11_ctl:setPosition(4, 184),
        StaticText11_ctl:setSize(120, 10),
        StaticText12_ctl = textControl::new(This),
        StaticText12_ctl:setText("Склонности [0..3]"),
        StaticText12_ctl:setPosition(84, 0),
        StaticText12_ctl:setSize(100, 8).

predicates
    generatedOnShow: window::showListener.
clauses
    generatedOnShow(_,_):-
        succeed.
% end of automatic code
end implement formBasic
