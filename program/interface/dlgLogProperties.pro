/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement dlgLogProperties
    inherits dialog
    open core, vpiDomains

constants
    className = "interface/dlgLogProperties".
    classVersion = "".

clauses
    classInfo(className, classVersion).

clauses
    display(Parent) = Dialog :-
        Dialog = new(Parent),
        Dialog:show().

clauses
    new(Parent) :-
        dialog::new(Parent),
        generatedInitialize().

% This code is maintained automatically, do not update it manually. 20:42:19-8.3.2009
facts
    ok_ctl : button.
    cancel_ctl : button.
    help_ctl : button.
    edLogType_ctl : editControl.

predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setFont(vpi::fontCreateByName("MS Sans Serif", 8)),
        setText("dlgLogProperties"),
        setRect(rct(50,40,290,160)),
        setModal(true),
        setDecoration(titlebar([closebutton()])),
        setState([wsf_NoClipSiblings]),
        ok_ctl := button::newOk(This),
        ok_ctl:setText("&OK"),
        ok_ctl:setPosition(72, 102),
        ok_ctl:setAnchors([control::right,control::bottom]),
        cancel_ctl := button::newCancel(This),
        cancel_ctl:setText("Cancel"),
        cancel_ctl:setPosition(128, 102),
        cancel_ctl:setAnchors([control::right,control::bottom]),
        help_ctl := button::new(This),
        help_ctl:setText("&Help"),
        help_ctl:setPosition(184, 102),
        help_ctl:setAnchors([control::right,control::bottom]),
        edLogType_ctl := editControl::new(This),
        edLogType_ctl:setText("xhtml()"),
        edLogType_ctl:setPosition(4, 14),
        StaticText3_ctl = textControl::new(This),
        StaticText3_ctl:setText("simulateLife log type"),
        StaticText3_ctl:setPosition(4, 2),
        StaticText3_ctl:setSize(72, 10).
% end of automatic code
end implement dlgLogProperties
