/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement taskWindow
    inherits applicationWindow
    open core, vpiDomains

constants
    className = "TaskWindow/taskWindow".
    classVersion = "".

clauses
    classInfo(className, classVersion).

constants
    mdiProperty : boolean = true.
clauses
    new():-
        applicationWindow::new(),
        generatedInitialize().

facts
    messageWindow_fact : messageForm := erroneous.

clauses
    getMessageStream() = OStream :-
        messageWindow_fact:isShown(),
        !,
        OStream = messageWindow_fact:getOutputStream().
    getMessageStream() = OStream :-
        messageWindow_fact := messageForm::display(This),
        OStream = messageWindow_fact:getOutputStream().

facts
    individViewWindow_fact : fmViewIndividual := erroneous.

clauses
    individViewWindow() = individViewWindow_fact :-
        individViewWindow_fact:isShown(),
        !.
    individViewWindow() = individViewWindow_fact :-
        individViewWindow_fact := fmViewIndividual::display(This).

predicates
    onShow : window::showListener.
clauses
    onShow(_, _CreationData):-
        messageWindow_fact := messageForm::display(This),
        _TestWindow = formBasic::display(This),
        individViewWindow_fact := fmViewIndividual::display(This).
%        layoutBasic()

/*
predicates
    layoutBasic : ().
clauses
    layoutBasic() :-
        This:getClientSize(Width, Height),
        IndividView_W = 160,
        Msg_H = 70,
%        individViewWindow:setRect(rct(1, 1, IndividView_W - 1, Height - 1)).
        individViewWindow:setRect(rct(math::round(Width * 0.75) - IndividView_W - 1, math::round(Height * 0.25), IndividView_W - 1, math::round(Height * 0.75) - 1)),
        messageWindow:setRect(rct(1, math::round(Height * 0.75) - Msg_H - 1, 1, math::round(Height * 0.75))).
*/        

predicates
    onDestroy : window::destroyListener.
clauses
    onDestroy(_).

predicates
    onHelpAbout : window::menuItemListener.
clauses
    onHelpAbout(TaskWin, _MenuTag):-
        _AboutDialog = aboutDialog::display(TaskWin).

predicates
    onFileExit : window::menuItemListener.
clauses
    onFileExit(_, _MenuTag):-
        close().

predicates
    onSizeChanged : window::sizeListener.
clauses
    onSizeChanged(_):-
        vpiToolbar::resize(getVPIWindow()).

predicates
    onTestFormsBasicForm : window::menuItemListener.
clauses
    onTestFormsBasicForm(Source, _MenuTag) :-
        _ = formBasic::display(Source).

predicates
    onTestFormsMainForm : window::menuItemListener.
clauses
    onTestFormsMainForm(Source, _MenuTag) :-
        _ = fmMain::display(Source).

predicates
    onРазноеОкноСообщений : window::menuItemListener.
clauses
    onРазноеОкноСообщений(_Source, _MenuTag) :-
        messageWindow_fact:isShown(),
        !.
    onРазноеОкноСообщений(_Source, _MenuTag) :-
        messageWindow_fact := messageForm::display(This).

predicates
    onРазноеОкноОсоби : window::menuItemListener.
clauses
    onРазноеОкноОсоби(_Source, _MenuTag) :-
        individViewWindow_fact:isShown(),
        !.
    onРазноеОкноОсоби(_Source, _MenuTag) :-
        individViewWindow_fact := fmViewIndividual::display(This).
        
% This code is maintained automatically, do not update it manually. 14:45:54-27.4.2009
predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setText("Victoria"),
        setDecoration(titlebar([closebutton(),maximizebutton(),minimizebutton()])),
        setBorder(sizeBorder()),
        setState([wsf_ClipSiblings]),
        setMdiProperty(mdiProperty),
        menuSet(resMenu(resourceIdentifiers::id_mnumain)),
        addShowListener(generatedOnShow),
        addShowListener(onShow),
        addSizeListener(onSizeChanged),
        addDestroyListener(onDestroy),
        addMenuItemListener(resourceIdentifiers::id_test_forms_basic_form, onTestFormsBasicForm),
        addMenuItemListener(resourceIdentifiers::id_test_forms_main_form, onTestFormsMainForm),
        addMenuItemListener(resourceIdentifiers::id_разное_окно_сообщений, onРазноеОкноСообщений),
        addMenuItemListener(resourceIdentifiers::id_разное_окно_особи, onРазноеОкноОсоби).

predicates
    generatedOnShow: window::showListener.
clauses
    generatedOnShow(_,_):-
        succeed.
% end of automatic code
end implement taskWindow
