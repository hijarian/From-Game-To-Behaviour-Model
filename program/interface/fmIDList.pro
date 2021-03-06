/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement fmIDList
    inherits formWindow
    open core, vpiDomains

constants
    className = "interface/fmIDList".
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
% Заполняем списки идентификаторов; пока что хард-кодинг 
        Params = memParams_ctl:getOutputStream(),
        Params:write("attrSTR\nattrCON\nattrINT\nattrREF\nattrCHA\nattrETH\nattrAMR\nattrSEN\n"),
        Params:write("skillDec\nskillArt\nskillConv\nskillCook\nskillCombSkl\nskillCombAtt\nskillCombDef\nskillMgrSkl\nskillMgrAtt\nskillMgrDef\n"),
        Params:write("stressLv\nmoneyQt\n"),
        Params:close(),
        Terms = memTerms_ctl:getOutputStream(),
        Terms:write("minimal\nlow\nmedium\nhigh\noverpower"),
        Terms:close().
        
% This code is maintained automatically, do not update it manually. 15:06:38-27.4.2009
facts
    ok_ctl : button.
    memParams_ctl : messagecontrol.
    memTerms_ctl : messagecontrol.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setFont(vpi::fontCreateByName("MS Sans Serif", 8)),
        setText("fmIDList"),
        setRect(rct(50,40,186,188)),
        setDecoration(titlebar([closebutton(),maximizebutton(),minimizebutton()])),
        setBorder(sizeBorder()),
        setState([wsf_ClipSiblings,wsf_ClipChildren]),
        menuSet(noMenu),
        addShowListener(generatedOnShow),
        addShowListener(onShow),
        ok_ctl := button::newOk(This),
        ok_ctl:setText("&OK"),
        ok_ctl:setPosition(84, 134),
        ok_ctl:setAnchors([control::right,control::bottom]),
        memParams_ctl := messagecontrol::new(This),
        memParams_ctl:setPosition(4, 18),
        memParams_ctl:setSize(60, 128),
        memTerms_ctl := messagecontrol::new(This),
        memTerms_ctl:setPosition(72, 34),
        memTerms_ctl:setSize(60, 96),
        StaticText2_ctl = textControl::new(This),
        StaticText2_ctl:setText("Нечёткие значения (оценки)"),
        StaticText2_ctl:setPosition(72, 4),
        StaticText2_ctl:setSize(60, 28),
        StaticText2_ctl:setAlignment(alignCenter),
        StaticText1_ctl = textControl::new(This),
        StaticText1_ctl:setText("Параметры"),
        StaticText1_ctl:setPosition(4, 4),
        StaticText1_ctl:setSize(60, 10),
        StaticText1_ctl:setAlignment(alignCenter).

predicates
    generatedOnShow: window::showListener.
clauses
    generatedOnShow(_,_):-
        succeed.
% end of automatic code
end implement fmIDList
