/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement polygonalMeter
    inherits drawControlSupport
    open core, vpiDomains

constants
    className = "interface/polygonalMeter".
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
        init(0, 0, [], 0, 0),
        generatedInitialize().

%----------------------------------------------------------
facts
    %
    corner_count_fact : unsigned := erroneous.
    
    %
    steps_fact : unsigned := erroneous.
    
    %
    values_fact : corner_value_list := erroneous.
    
    %
    min_value_fact : integer := erroneous.
    
    %
    max_value_fact : integer := erroneous.

% Реализация свойств объекта
clauses
    cornerCount() = corner_count_fact.
    
    cornerCount(Val) :-
        corner_count_fact := Val.
    
    steps() = steps_fact.
    
    steps(Val) :-
        steps_fact := Val.
        
    values() = values_fact.
    
    values(Val) :-
        values_fact := Val.
        
    minvalue() = min_value_fact.
    
    minvalue(Val) :-
        min_value_fact := Val.

    maxvalue() = max_value_fact.
    
    maxvalue(Val) :-
        max_value_fact := Val.

clauses
    init(N, RadiusSteps, ValuesList, RadiusStart, RadiusEnd) :-
        corner_count_fact := N,
        steps_fact := RadiusSteps, 
        values_fact := ValuesList,
        min_value_fact := RadiusStart,
        max_value_fact := RadiusEnd.

class predicates
    calcCorners : (
        unsigned CornerCount, 
        unsigned Radius, 
        vpiDomains::pnt CenterPoint, 
        real AngleShift,
        unsigned CurPointNmb, 
        vpiDomains::pntlist Acc) 
            -> vpiDomains::pntlist Corners.
    
clauses
    calcCorners(_CCnt, _R, _CPnt, _AngSh, 0, Acc) = Acc :-
        !.
    calcCorners(N, R, vpiDomains::pnt(CX, CY), Sh, CN, Acc) = PointList :-
        Angle = 2 * math::pi * CN / N + Sh,
        % В следующих двух строчках можно ради шутки поставить math::round/1
        %    вокруг math::cos/1 (соответственно, math::sin/1) - прога будет вместо многоугольника рисовать квадрат. Всегда.
        X = math::round(R * math::cos(Angle) + CX),
        Y = math::round(R * math::sin(Angle) + CY),
        NewPoint = vpiDomains::pnt(X, Y),
        PointList = calcCorners(N, R, vpiDomains::pnt(CX, CY), Sh, CN - 1, [NewPoint|Acc]).

class predicates
    drawRadiuses : (windowGDI WhereToDraw, vpiDomains::pnt Center, vpiDomains::pntlist Corners) procedure (i, i, i).
clauses
    drawRadiuses(_Canvas, _Center, []) :-
        !.
    drawRadiuses(Canvas, Center, [Pnt | OtherPntList]) :-
        Canvas:drawLine(Center, Pnt),
        drawRadiuses(Canvas, Center, OtherPntList).

class predicates
    drawPolygonalGrid : (
        windowGDI WhereToDraw, 
        vpiDomains::pnt Center, 
        unsigned StepCount, 
        unsigned CurrentStepNmb, 
        vpiDomains::pntlist Corners) procedure (i, i, i, i, i).
clauses
    drawPolygonalGrid(_Canvas, _Cent, _StepCnt, 0, _Corn) :-
        !.
% ЭТО - не лучшая реализация алгоритма.        
    drawPolygonalGrid(Canvas, pnt(CX, CY), StepCount, CurStep, Corners) :-
        ShrinkRatio  = CurStep / StepCount,
        CurPoly = shrinkPolygon(pnt(CX, CY), ShrinkRatio, Corners),
        Canvas:drawPolygon(CurPoly),
        drawPolygonalGrid(Canvas, pnt(CX, CY), StepCount, CurStep - 1, Corners).

class predicates
    shrinkPolygon : (vpiDomains::pnt Center, real Ratio, vpiDomains::pntlist PolygonCorners) -> vpiDomains::pntlist ShrinkedPolygon procedure (i, i, i).
clauses
    shrinkPolygon(_Cent, _R, []) = [] :-
        !.
    shrinkPolygon(pnt(CX, CY), Ratio, [pnt(PX, PY) | OtherCorners]) = ShCorners :-
        TempCorners = shrinkPolygon(pnt(CX, CY), Ratio, OtherCorners),
        X = math::round((PX - CX) * Ratio + CX),
        Y = math::round((PY - CY) * Ratio + CY),
        NewPoint = pnt(X, Y),
        ShCorners = [NewPoint | TempCorners].

% Поправляет положение подписи к параметру в зависимости от того, который по счёту угол занимает параметр
%   (чтобы надписи не налезали на сам многоугольник).
%  Предикат настроен на поворот многоугольника на math::pi - math::pi / corner_count 
%   (углы отчитываются против часовой стрелки от верхнего из крайних левых углов).
%  Если повернуть многоугольник на другой угол, сдвиги (после cut'ов в каждом предложении) 
%    придётся поменять местами везде в предикате!
% TODO очевидно, тупанская реализация предиката 
class predicates
    calcTextPos : (
        unsigned CornerCount, 
        unsigned CurrentCornerNmb, 
        core::tuple{positive Width, positive Height} TextWidth,
        vpiDomains::pnt BasePoint) 
            -> vpiDomains::pnt ShiftedBasePoint.
clauses
    calcTextPos(N, CurN, tuple(W, _H), pnt(BX, BY)) = pnt(X, Y) :-
        CurN > 0,
        CurN <= N / 4,    % 4я четверть
        !,    % 
        X = BX - W - 1,
        Y = BY - 1.
    calcTextPos(N, CurN, tuple(_W, _H), pnt(BX, BY)) = pnt(X, Y) :-
        CurN > N / 4,
        CurN <= N / 2,    % 1я четверть
        !,    % 
        X = BX + 1,
        Y = BY - 1.
    calcTextPos(N, CurN, tuple(_W, H), pnt(BX, BY)) = pnt(X, Y) :-
        CurN > N / 2,
        CurN <= N * 3 / 4,    % 2я четверть
        !,    % 
        X = BX + 2,
        Y = BY + H + 1.
    calcTextPos(_N, _CurN, tuple(W, H), pnt(BX, BY)) = pnt(X, Y) :-
        succeed(),    % 3я четверть
        !,    % 
        X = BX - W - 1,
        Y = BY + H + 1.

class predicates
    drawValueData : (
        windowGDI WhereToDraw, 
        unsigned CornersCount, 
        unsigned CurrentCorner, 
        corner_value_list ValueList,
        vpiDomains::pntlist CornerList).
clauses
    % Если кончился счётчик (нормальное завершение)
    drawValueData(_Cv, _N, 0, _Val, _Cr) :-
        !.
    % Если кончились значения, записанные для control'а (=> список значений короче списка углов)
    drawValueData(_Cv, _N, _CurN, [], _Cr) :-
        !.
    % Если кончились углы многоугольника (=> длина списка углов меньше кол-ва точек, которые хотели вывести, вообще страшная жесть, т. к. это кол-во предполагается брать из corner_count_fact)
    drawValueData(_Cv, _N, _CurN, _Val, []) :-
        !.
    drawValueData(Canvas, N, CurN, [cornerval(Label, Val) | OtherValues], [CurCorner | OtherCorners]) :-
        Text = string::format("%s %u", Label, Val),
        Canvas:getTextExtent(Text, W, H),
        PointNum = N - CurN + 1,
        TextPos = calcTextPos(N, PointNum, tuple(W, H), CurCorner),    % Получаем координаты наиболее уместного расположения надписи
        Canvas:drawText(TextPos, Text),
        drawValueData(Canvas, N, CurN - 1, OtherValues, OtherCorners).

%
class predicates
    drawValuePolygon : (
        windowGDI WhereToDraw, 
        vpiDomains::pnt Center,
        integer MinValue,
        integer MaxValue,
        corner_value_list ValueList,
        vpiDomains::pntlist CornerList).
clauses
    drawValuePolygon(Canvas, Center, MinVal, MaxVal, ValList, CornerList) :-
        ValuesPolygon = calcValuePolygon(Center, MinVal, MaxVal, ValList, CornerList, []),
        ValuesPolygon <> [],
        !,
        Canvas:drawPolygon(ValuesPolygon).
    drawValuePolygon(_Canvas, _Center, _MinVal, _MaxVal, _EmptyValList, _CornerList).

%
class predicates
    calcValuePolygon : (
        vpiDomains::pnt Center,
        integer MinValue,
        integer MaxValue,
        corner_value_list ValueList,
        vpiDomains::pntlist CornerList,
        vpiDomains::pntlist Accumulator)
            -> vpiDomains::pntlist ValuePolygon.
clauses
    calcValuePolygon(_Cent, _MinV, _MaxV, [], _CL, Acc) = Acc :-
        !.
    calcValuePolygon(_Cent, _MinV, _MaxV, _VL, [], Acc) = Acc :-
        !.
    calcValuePolygon(pnt(CX, CY), MinVal, MaxVal, [cornerval(_Lb, Val) | OtherValues], [pnt(PX, PY) | OtherCorners], Acc) = ShiftedPoints :-
        Ratio = math::abs(Val - MinVal) / math::abs(MaxVal - MinVal),
        X = math::round((PX - CX) * Ratio + CX),
        Y = math::round((PY - CY) * Ratio + CY),
        ShiftedPoints = calcValuePolygon(pnt(CX, CY), MinVal, MaxVal, OtherValues, OtherCorners, [pnt(X, Y) | Acc]).

%----------------------------------------------------------
predicates
    onPaint : drawWindow::paintResponder.
clauses
    onPaint(_Source, _Rectangle, _GDIObject) :-
% Если углов нет (их количество не инициализировано) - не жрём себе мозги и ничего не делаем
        corner_count_fact < 1,
        !.
    onPaint(_Source, Rectangle, GDIObject) :-
% Создаём полотно, на котором будем пока чертить, а потом нарисуем его на GDIObject'е. 
%   Так не будет лишнего мерцания (Windows GDI произведёт только один вывод изображения на экран)
        rct(L, T, R, B) = Rectangle,
        Height = B - T,
        Width = R - L,
        PC = pictureCanvas::new(Width, Height),
        Center = pnt(math::ceil(Height / 2), math::ceil(Width / 2)),
        Radius = math::abs(math::ceil(Height * 0.35)),
% Получили основные данные - координаты углов внешнего многоугольника. % Тут же его нарисовали.
        OuterCorners = calcCorners(    % Вычисляем координаты углов внешнего многоугольника
                corner_count_fact,    % Сколько вообще углов
                Radius,    % Расстояние от центра control'а до каждого угла
                Center,    % Координаты центра многоугольника
                math::pi - math::pi / corner_count_fact,    % Поворот многоугольника (мн-ки с чётным кол-вом углов будут опираться на ребро, а не вершину - выглядит симпатичнее)
                corner_count_fact,    % Счётчик инициируем кол-вом углов
                []),    % Аккумулятор инициируем пустым списком.
% Радиальные линии
        PC:setPen(pen(1, ps_Dot, color_Silver)),
        drawRadiuses(PC, Center, OuterCorners),
%        PC:drawPolygon(OuterCorners),
% Чертим многоугольники сетки
        PC:setPen(pen(1, ps_Solid, color_Aqua)),
        PC:setBrush(brush(pat_Hollow, color_White)),
        drawPolygonalGrid(PC, Center, steps_fact, steps_fact, OuterCorners),
% Выводим данные в текстовом виде
        PC:setFont(vpi::fontCreateByName("Helvetica", 8)),    % Здесь возможны ошибки, если этого шрифта в системе нет!
        PC:setForeColor(color_DarkOrchid),
        drawValueData(PC, corner_count_fact, corner_count_fact, values_fact, OuterCorners),
% Чертим многоугольник, отображающий данные
        PC:setPen(pen(1, ps_Solid, color_DarkOrchid)),
        PC:setBrush(brush(pat_Solid, color_Orchid)),
        drawValuePolygon(PC, Center, min_value_fact, max_value_fact, values_fact, OuterCorners),
        Bitmap = PC:getPicture(),
        GDIObject:pictDraw(Bitmap, pnt(0, 0), rop_SrcCopy).

%
predicates
    onSize : window::sizeListener.
clauses
    onSize(_Source) :-
        invalidate().

predicates
    onEraseBackground : drawWindow::eraseBackgroundResponder.
clauses
    onEraseBackground(_Source, _GDIObject) = drawWindow::noEraseBackground().

% This code is maintained automatically, do not update it manually. 00:41:46-19.4.2009
facts

predicates
    generatedInitialize : ().
clauses
    generatedInitialize():-
        setText("polygonalMeter"),
        This:setSize(120, 120),
        addSizeListener(onSize),
        setEraseBackgroundResponder(onEraseBackground),
        setPaintResponder(onPaint).
% end of automatic code
end implement polygonalMeter
