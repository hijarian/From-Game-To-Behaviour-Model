/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement fmViewIndividual
    inherits formWindow
    open core, vpiDomains

constants
    className = "interface/fmViewIndividual".
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

predicates
    onShow : window::showListener.
clauses
    onShow(_Source, _Data) :-
%
        polygonalMeter_ctl:cornerCount := 8,
        polygonalMeter_ctl:steps := 4,
/*
        PolyData = [
            polygonalMeter::cornerval("Ph", 2),
            polygonalMeter::cornerval("Cg", 0),
            polygonalMeter::cornerval("Cr", 1),
            polygonalMeter::cornerval("Ms", 3),
            polygonalMeter::cornerval("Fm", 0),
            polygonalMeter::cornerval("In", 2),
            polygonalMeter::cornerval("Sx", 3),
            polygonalMeter::cornerval("Ag", 3)
            ],
        polygonalMeter_ctl:values := PolyData,
*/
        polygonalMeter_ctl:minvalue := -1,
        polygonalMeter_ctl:maxvalue := 3,
        polygonalMeter_ctl:invalidate(),
%
/*
        ParamData = [
            tuple("STR", paramMeter::pmval(0, 9, 350, 900)),
            tuple("ETH", paramMeter::pmval(0, 17, 789.32, 900)),
            tuple("MgrAtt", paramMeter::pmval(0, 3.5, 389.6753, 450))
            ],
        paramMeter_ctl:setValueList(ParamData),
*/
        paramMeter_ctl:invalidate(),
        paramMeter_ctl:initScrollControl(vertScroll_ctl).

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

clauses
    showIndivid(Phenotype, Individ) :-
        convertPhenotypeToPolygonalMeterData(Phenotype, Data),
        polygonalMeter_ctl:values := Data,
        polygonalMeter_ctl:invalidate(),
        foreach Individ:getParameterData_nd(ParamLabel, ParamValue, ParamMinValue, ParamMaxValue) do
            paramMeter_ctl:setValue(ParamLabel, paramMeter::pmval(ParamMinValue, 0, ParamValue, ParamMaxValue))
        end foreach,
        paramMeter_ctl:invalidate(),
        paramMeter_ctl:initScrollControl(vertScroll_ctl).

predicates
    onVertScrollScroll : scrollControl::scrollListener.
clauses
    onVertScrollScroll(Source, ScrollType, ThumbPosition) :-
    % ОБЯЗАТЕЛЬНО надо проинициализировать соответствующий scrollControl методом paramMeter:initScrollControl/0 !.
        paramMeter_ctl:scrollByScrollEventParameters(Source, ScrollType, ThumbPosition).
        

predicates
    onBtnOpenActionListLogClick : button::clickResponder.
clauses
    onBtnOpenActionListLogClick(_Source) = button::defaultAction.

% This code is maintained automatically, do not update it manually. 15:39:39-27.4.2009
facts
    paramMeter_ctl : parammeter.
    polygonalMeter_ctl : polygonalmeter.
    vertScroll_ctl : scrollControl.
    btnOpenActionListLog_ctl : button.
    btnOpenLifeLog_ctl : button.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setFont(vpi::fontCreateByName("MS Sans Serif", 8)),
        setText("fmViewIndividual"),
        setRect(rct(400,40,560,320)),
        setDecoration(titlebar([closebutton(),maximizebutton(),minimizebutton()])),
        setBorder(thinBorder()),
        setState([wsf_ClipSiblings,wsf_ClipChildren]),
        menuSet(noMenu),
        addShowListener(generatedOnShow),
        addShowListener(onShow),
        paramMeter_ctl := parammeter::new(This),
        paramMeter_ctl:setPosition(4, 128),
        paramMeter_ctl:setSize(144, 134),
        polygonalMeter_ctl := polygonalmeter::new(This),
        polygonalMeter_ctl:setPosition(20, 2),
        polygonalMeter_ctl:setSize(120, 120),
        vertScroll_ctl := scrollControl::newVertical(This),
        vertScroll_ctl:setPosition(148, 128),
        vertScroll_ctl:setSize(9, 134),
        vertScroll_ctl:setTabStop(true),
        vertScroll_ctl:addScrollListener(onVertScrollScroll),
        btnOpenActionListLog_ctl := button::new(This),
        btnOpenActionListLog_ctl:setText("Открыть лог действий"),
        btnOpenActionListLog_ctl:setPosition(4, 264),
        btnOpenActionListLog_ctl:setSize(80, 12),
        btnOpenActionListLog_ctl:setVisible(false),
        btnOpenActionListLog_ctl:setClickResponder(onBtnOpenActionListLogClick),
        btnOpenLifeLog_ctl := button::new(This),
        btnOpenLifeLog_ctl:setText("Открыть общий лог"),
        btnOpenLifeLog_ctl:setPosition(84, 264),
        btnOpenLifeLog_ctl:setSize(72, 12),
        btnOpenLifeLog_ctl:setVisible(false).

predicates
    generatedOnShow: window::showListener.
clauses
    generatedOnShow(_,_):-
        succeed.
% end of automatic code
end implement fmViewIndividual
