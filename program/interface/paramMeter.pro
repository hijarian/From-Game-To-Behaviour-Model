/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement paramMeter
    inherits drawControlSupport
    open core, vpiDomains

constants
    className = "interface/paramMeter".
    classVersion = "".

clauses
    classInfo(className, classVersion).

clauses
    new(Parent):-
        new(),
        setContainer(Parent).

clauses
    new():-
        drawControlSupport::new(),
        generatedInitialize(),
        init().

predicates
    init : ().
clauses
    init() :-
        values_count := 0,
        scrolled_to_value_nmb := 1.
        
%---------------------------------------------------------------
facts
    %
    value_fact : (symbol Label, paramMeterValue ValuesTerm).
    %
    values_count : integer := erroneous.
    
clauses
    setValue(Label, Value) :-
        foreach retract(value_fact(Label, _)) do    % удаляем все возможные вхождения параметра с тем же id
            values_count := values_count - 1
        end foreach,
        assert(value_fact(Label, Value)),
        values_count := values_count + 1.
    
    setValueList([]) :-
        scrolled_to_value_nmb := 1,
        !.
    setValueList([core::tuple(Label, Value) | OtherParams]) :-
        setValue(Label, Value),
        setValueList(OtherParams).

    getValue_nd(Label, MinValue, StartValue, EndValue, MaxValue) :-
        value_fact(Label, pmval(MinValue, StartValue, EndValue, MaxValue)).

facts
% Номер параметра, до которого докрутили, пользуясь полосой прокрутки
%   (полоса прокрутки прокручивает изображение не попиксельно, а построчно)
    scrolled_to_value_nmb : integer := erroneous.

clauses
    initScrollControl(ScrollControl) :-
        values_count > 0,
        !,
        ScrollControl:setRange(1, values_count),
        ScrollControl:setProportion(convert(unsigned, math::round(1 / values_count))),
        ScrollControl:setThumbPosition(scrolled_to_value_nmb).
    initScrollControl(_DontMatter).

clauses
    scrollByValuesCount(Nmb) :-
        scrolled_to_value_nmb + Nmb > values_count,
        !,
        scrolled_to_value_nmb := values_count.
    scrollByValuesCount(Nmb) :-
        scrolled_to_value_nmb + Nmb < 1,
        !,
        scrolled_to_value_nmb := 1.
    scrollByValuesCount(Nmb) :-
        scrolled_to_value_nmb := scrolled_to_value_nmb + Nmb.

clauses
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_LineDown, _ThumbPosition) :-
        !,
        scrollByValuesCount(1),
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_LineUp, _ThumbPosition) :-
        !,
        scrollByValuesCount(-1),
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_PageDown, _ThumbPosition) :-
        !,
        scrollByValuesCount(3),
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_PageUp, _ThumbPosition) :-
        !,
        scrollByValuesCount(-3),
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
/* прога ловит переполнение стека из-за непрерывной обработки этого события, если фокус ввода остаётся на Scroller'е после любого вида прокрутки. Удалил на всякий случай.
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_ThumbTrack, ThumbPosition) :-
        ThumbPosition < values_count and ThumbPosition > 1,    % чтобы не словить разрыв мозга, если Scroller не был инициализирован методом initScrollControl
        !,
        scrolled_to_value_nmb := ThumbPosition,
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
*/
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_Thumb, ThumbPosition) :-
        ThumbPosition <= values_count and ThumbPosition >= 1,    % тоже чтобы не словить разрыв мозга, если Scroller не был инициализирован методом initScrollControl
        !,
        scrolled_to_value_nmb := ThumbPosition,
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_Top, _ThumbPosition) :-
        !,
        scrolled_to_value_nmb := 1,
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
    scrollByScrollEventParameters(Scroller, vpiDomains:: sc_Bottom, _ThumbPosition) :-
        !,
        scrolled_to_value_nmb := values_count,    % лучше не пользовать это предложение, если список параметров пуст
        invalidate(),
        Scroller:setThumbPosition(scrolled_to_value_nmb).
    scrollByScrollEventParameters(_Scroller, _StrangeScrollType, _ThumbPosition).

facts
    %
    heightMeter : integer := erroneous. 
    %
    paramBarCounter : integer := erroneous.
    
predicates
    onPaint : drawWindow::paintResponder.
clauses
    onPaint(_Source, Rectangle, GDI) :-
        rct(L, T, R, B) = Rectangle,
        Height = B - T,
        Width = R - L,
        PC = pictureCanvas::new(Width, Height),
        heightMeter := 2,
        paramBarCounter := 1,
        foreach value_fact(Label, Value) do
            ((
                paramBarCounter < scrolled_to_value_nmb,
                !,
                paramBarCounter := paramBarCounter + 1)
                    or
               (!,
                Shift = drawParamBar(PC, Label, Value, heightMeter),    % чертим надпись и полосочку для текущего найденного параметра
                heightMeter := heightMeter + Shift + 2    % 2 пикселя промежуток между полосочками
            ))
        end foreach,
        Bitmap = PC:getPicture(),
        GDI:pictDraw(Bitmap, pnt(0, 0), rop_srcCopy).

constants
    fontSize : positive = 8.
    fontName : string = "Helvetica".
    paramBarHeight : integer = 10.
    paramBarWidth : integer = 160.
    
% рисуем низкий широкий прямоугольник, на которой отмечены две полоски - StartValue и EndValue
class predicates
    drawParamBar : (windowGDI GDIObject, symbol Label, paramMeterValue ParamValue, integer VerticalPosition) -> integer DrawnBarHeight.
clauses
    drawParamBar(GDI, Label, pmval(MinValue, StartValue, EndValue, MaxValue), VerticalPos) = Shift:-
        LeftBound = 2,
        StartValPos = LeftBound + math::round(((StartValue - MinValue) / (MaxValue - StartValue)) * paramBarWidth),
        EndValPos = LeftBound + math::round(((EndValue - MinValue) / (MaxValue - StartValue)) * paramBarWidth),
        RightBound = LeftBound + paramBarWidth,
        GDI:setForeColor(color_DarkOrchid),
        GDI:setFont(vpi::fontCreateByName(fontName, fontSize)),
        GDI:getTextExtent(Label, _TopLabelWidth, TopLabelHeight),
        Y0 = VerticalPos + TopLabelHeight,
        GDI:drawText(pnt(2, Y0), Label), 
        Y = Y0 + 2,
        Y2 = Y + paramBarHeight,
        BorderColor = color_Black,
        GDI:setPen(pen(1, ps_Solid, BorderColor)),
        GDI:drawRect(rct(LeftBound, Y, RightBound, Y2)),
        SVLT = pnt(StartValPos, Y),    % Start Value (marker) Left Top (point)
        SVRB = pnt(StartValPos, Y2),    % Start Value (marker) Right Bottom (point)
        GDI:drawLine(SVLT, SVRB),
        EVLT = pnt(EndValPos, Y),    % End Value (marker) Left Top (point)
        EVRB = pnt(EndValPos, Y2),    % End Value (marker) Right Bottom (point)
        GDI:drawLine(EVLT, EVRB),
        % заливаем цветами, в зависимости от взаимного положения маркеров StartValue и EndValue.
        checkedFillBarRegion_unchanged(GDI, pnt(LeftBound, Y), SVRB, BorderColor),
        checkedFillBarRegion_change(GDI, SVLT, EVRB, BorderColor),
        checkedFillBarRegion_background(GDI, EVLT, pnt(RightBound, Y2), BorderColor),    % кусок полоски от конечного значения параметра до максимального вообще не закрашиваем
        % ставим подписи под маркерами MinValue, EndValue и MaxValue
        MinValLabel = string::format("%.0f", MinValue),
        EndValLabel = string::format("%.3f", EndValue),
        MaxValLabel = string::format("%.0f", MaxValue),
        GDI:setForeColor(color_Magenta),
        ValLbPosX = LeftBound + math::round((RightBound - LeftBound) / 2),
        ValLbPosY = Y0,
        GDI:drawText(pnt(ValLbPosX, ValLbPosY),  EndValLabel),
        GDI:setFont(vpi::fontCreateByName(fontName, math::round(fontSize * 0.8))),
        GDI:setForeColor(color_Black),
        GDI:getTextExtent(MinValLabel, _BottomLabelWidth, BottomLabelHeight),
        Y3 = Y2 + BottomLabelHeight - 2,
        GDI:drawText(pnt(LeftBound, Y3), MinValLabel),
        GDI:drawText(pnt(RightBound, Y3), MaxValLabel),
        Shift = TopLabelHeight + paramBarHeight + BottomLabelHeight.

domains
    fillRegionPredicate = (windowGDI, vpiDomains::pnt LeftTopPoint, vpiDomains::pnt RightBottomPoint, vpiDomains::color BorderColor).

class predicates
    checkedFillBarRegion_unchanged : fillRegionPredicate.
clauses
    checkedFillBarRegion_unchanged(_GDI, pnt(X1, _Y1), pnt(X2, _Y2), _BorderColor) :-
        X1 >= X2,
        !.
    checkedFillBarRegion_unchanged(GDI, pnt(X1, Y1), pnt(X2, Y2), BorderColor) :-
        X = X1 + math::round(math::abs(X2 - X1) / 2),
        Y = Y1 + math::round(math::abs(Y2 - Y1) / 2),
        GDI:setBrush(brush(pat_Solid, color_Blue)),
        GDI:drawFloodFill(pnt(X, Y), BorderColor).
    
class predicates
    checkedFillBarRegion_background : fillRegionPredicate.
clauses
    checkedFillBarRegion_background(_GDI, pnt(X1, _Y1), pnt(X2, _Y2), _BorderColor) :-
        X1 >= X2,
        !.
    checkedFillBarRegion_background(GDI, pnt(X1, Y1), pnt(X2, Y2), BorderColor) :-
        X = X1 + math::round(math::abs(X2 - X1) / 2),
        Y = Y1 + math::round(math::abs(Y2 - Y1) / 2),
        GDI:setBrush(brush(pat_Solid, color_White)),
        GDI:drawFloodFill(pnt(X, Y), BorderColor).
    
class predicates
    checkedFillBarRegion_change : fillRegionPredicate.
clauses
    checkedFillBarRegion_change(GDI, pnt(X1, Y1), pnt(X2, Y2), BorderColor) :-
        X1 >= X2,    % Значение параметра уменьшилось (0_o OMG WTF ?!!)
        X = X2 + math::round(math::abs(X2 - X1) / 2),
        Y = Y1 + math::round(math::abs(Y2 - Y1) / 2),
        GDI:setBrush(brush(pat_Solid, color_Red)),
        GDI:drawFloodFill(pnt(X, Y), BorderColor),
        !.
    checkedFillBarRegion_change(GDI, pnt(X1, Y1), pnt(X2, Y2), BorderColor) :-
        X = X1 + math::round(math::abs(X2 - X1) / 2),
        Y = Y1 + math::round(math::abs(Y2 - Y1) / 2),
        GDI:setBrush(brush(pat_Solid, color_Green)),
        GDI:drawFloodFill(pnt(X, Y), BorderColor).
    
predicates
    onSize : window::sizeListener.
clauses
    onSize(_Source) :-
        This:invalidate().

predicates
    onEraseBackground : drawWindow::eraseBackgroundResponder.
clauses
    onEraseBackground(_Source, _GDIObject) = drawWindow::eraseBackground().

% This code is maintained automatically, do not update it manually. 21:05:45-24.4.2009
facts

predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setText("paramMeter"),
        This:setSize(140, 200),
        addSizeListener(onSize),
        setEraseBackgroundResponder(onEraseBackground),
        setPaintResponder(onPaint).
% end of automatic code
end implement paramMeter
