/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement fmMain
    inherits formWindow
    open core, vpiDomains

constants
    className = "interface/fmMain".
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
        
%        
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

%
class predicates
    extractFClauseList : (string* Source) -> fuzzySupport::fClause* FClauseList procedure (i).
clauses
    extractFClauseList([]) = [] :-
        !.
    extractFClauseList([ClauseStr | AccStr]) = [Clause | Acc] :-
        Acc = extractFClauseList(AccStr),
        Clause = extractFClause(ClauseStr).

%
class predicates
    extractEnding : (symbol EndingID, string Input) -> alifeSettings::ending EndingTerm procedure (i, i).
clauses
    extractEnding(EID, Str) = alifeSettings::ending(EID, ReqList) :-
        ReqList = extractFClauseList(string::split(Str, "\n")).

%
predicates
    tryGetData : () determ.
clauses
    tryGetData() :-
        try
            alifeSettings::setLifeLength(toTerm(edLifeLength_ctl:getText())),
            alifeSettings::setTargetEnding(extractEnding("simple-ending", edEnding_ctl:getText())),
            %alifeSettings::setMainLogType(toTerm(edLogType_ctl:getText())), % logger::xhtml()),
            alifeSettings::setMainLogType(logger::xhtml()),
            alifeSettings::setFuzzyMindResolution(toTerm(edFuzzyResolution_ctl:getText())),
            geneticSettings::setPopulationSize(toTerm(edPopulationSize_ctl:getText())),
            geneticSettings::setMutationRate(toTerm(edMutationRate_ctl:getText())),
            geneticSettings::setGenerationsNumber(toTerm(edGenerationsNmb_ctl:getText())),
            geneticSettings::setCriticalMeanFitness(0.75),
            geneticSettings::setCriticalFitness(0.9)
        catch AnyInputExceptionQueue do
            StreamI = stdio::getOutputStream(),
            exceptionDump::dump(StreamI, AnyInputExceptionQueue),
            StreamI:close(),
            fail()
        end try.

predicates
    onBtnProcessClick : button::clickResponder.
clauses
    onBtnProcessClick(_Source) = button::noAction :-
        tryGetData(),
        !,
        BestCell = geneticProcess::run(genDraw_ctl),
        %
        TaskWnd = convert(taskWindow, applicationWindow::get()),
        Viewer = TaskWnd:individViewWindow,
        Viewer:showIndivid(BestCell:getValue(), BestCell:getIndividual()).
    onBtnProcessClick(_Source) = button::noAction.
        

% This code is maintained automatically, do not update it manually. 15:39:03-27.4.2009
facts
    btnProcess_ctl : button.
    genDraw_ctl : gendraw.
    edLifeLength_ctl : editControl.
    edFuzzyResolution_ctl : editControl.
    edEnding_ctl : editControl.
    edPopulationSize_ctl : editControl.
    edMutationRate_ctl : editControl.
    edGenerationsNmb_ctl : editControl.
    pushButton_ctl : button.
    help_ctl : button.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setFont(vpi::fontCreateByName("MS Sans Serif", 8)),
        setText("fmMain"),
        setRect(rct(50,40,342,280)),
        setDecoration(titlebar([closebutton(),maximizebutton(),minimizebutton()])),
        setBorder(sizeBorder()),
        setState([wsf_ClipSiblings,wsf_ClipChildren]),
        menuSet(noMenu),
        addShowListener(generatedOnShow),
        btnProcess_ctl := button::new(This),
        btnProcess_ctl:setText("&Process"),
        btnProcess_ctl:setPosition(148, 28),
        btnProcess_ctl:setSize(68, 12),
        btnProcess_ctl:setAnchors([control::right,control::bottom]),
        btnProcess_ctl:setClickResponder(onBtnProcessClick),
        genDraw_ctl := gendraw::new(This),
        genDraw_ctl:setPosition(4, 42),
        genDraw_ctl:setSize(284, 196),
        edLifeLength_ctl := editControl::new(This),
        edLifeLength_ctl:setText("1000"),
        edLifeLength_ctl:setPosition(72, 0),
        edLifeLength_ctl:setWidth(24),
        edFuzzyResolution_ctl := editControl::new(This),
        edFuzzyResolution_ctl:setText("75"),
        edFuzzyResolution_ctl:setPosition(124, 28),
        edFuzzyResolution_ctl:setWidth(20),
        edEnding_ctl := editControl::new(This),
        edEnding_ctl:setText("attrREF:high"),
        edEnding_ctl:setPosition(228, 12),
        edEnding_ctl:setWidth(60),
        edEnding_ctl:setHeight(28),
        edEnding_ctl:setMultiLine(),
        edEnding_ctl:setWantReturn(),
        edEnding_ctl:setAutoVScroll(true),
        edPopulationSize_ctl := editControl::new(This),
        edPopulationSize_ctl:setText("50"),
        edPopulationSize_ctl:setPosition(72, 14),
        edPopulationSize_ctl:setWidth(32),
        edMutationRate_ctl := editControl::new(This),
        edMutationRate_ctl:setText("0.1"),
        edMutationRate_ctl:setPosition(192, 14),
        edMutationRate_ctl:setWidth(24),
        edGenerationsNmb_ctl := editControl::new(This),
        edGenerationsNmb_ctl:setText("250"),
        edGenerationsNmb_ctl:setPosition(196, 0),
        edGenerationsNmb_ctl:setWidth(20),
        pushButton_ctl := button::new(This),
        pushButton_ctl:setText("Настройки лог-файла"),
        pushButton_ctl:setPosition(120, 202),
        pushButton_ctl:setSize(84, 12),
        help_ctl := button::new(This),
        help_ctl:setText("WTF?!! &Help!"),
        help_ctl:setPosition(232, 192),
        help_ctl:setAnchors([control::right,control::bottom]),
        help_ctl:setVisible(false),
        StaticText_ctl = textControl::new(This),
        StaticText_ctl:setText("Итераций выбора"),
        StaticText_ctl:setPosition(4, 0),
        StaticText_ctl:setSize(64, 10),
        StaticText5_ctl = textControl::new(This),
        StaticText5_ctl:setText("Точность нечёткого контроллера"),
        StaticText5_ctl:setPosition(4, 29),
        StaticText5_ctl:setSize(116, 10),
        StaticText6_ctl = textControl::new(This),
        StaticText6_ctl:setText("Концовка"),
        StaticText6_ctl:setPosition(228, 2),
        StaticText1_ctl = textControl::new(This),
        StaticText1_ctl:setText("Размер популяции"),
        StaticText1_ctl:setPosition(4, 14),
        StaticText1_ctl:setSize(64, 10),
        StaticText2_ctl = textControl::new(This),
        StaticText2_ctl:setText("Вероятность мутации"),
        StaticText2_ctl:setPosition(112, 15),
        StaticText2_ctl:setSize(76, 10),
        StaticText4_ctl = textControl::new(This),
        StaticText4_ctl:setText("Количество поколений"),
        StaticText4_ctl:setPosition(112, 0),
        StaticText4_ctl:setSize(80, 10).

predicates
    generatedOnShow: window::showListener.
clauses
    generatedOnShow(_,_):-
        succeed.
% end of automatic code
end implement fmMain
