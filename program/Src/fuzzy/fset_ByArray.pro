/*****************************************************************************

                         

******************************************************************************/

implement fset_ByArray
    open core

constants
    className = "fuzzy/fset_ByArray".
    classVersion = "".

clauses
    classInfo(className, classVersion).

facts
    id : symbol := erroneous.

clauses
    new(ID) :-
        id := ID.

% Множество точек, для удобства добавления/удаления реализованное базой фактов.
%   При вычислениях будет преобразовано в список точек.
facts -pointSet
    point : (real XVal, real YVal).

clauses
    setPoint(XValue, YValue) :-
        retractall(point(XValue, YValue)),
        assert(point(XValue, YValue)).
        
    getPoint(XValue, YValue) :-
        point(XValue, YValue).
        
   removePoint(XValue, YValue) :-
        retract(point(XValue, YValue)).
        
% Домен, описывающий точку
domains
    tuplePoint = core::tuple{real XValue, real YValue}.
    listPoints = tuplePoint*.

% Преобразование множества точек в список точек.
% <закончено>
facts
    tempList : listPoints := erroneous.
predicates
    getSortedPointList : () -> listPoints.
clauses
    getSortedPointList() = List :-
        tempList := [],
        foreach point(X, Y) do
            tempList := [core::tuple(X, Y)|tempList]
        end foreach,
        List = list::sortBy(compareTuples, tempList),
        tempList := [].

% Предикат сравнения пар core::tuple{real, real}
% <закончено>
predicates
    compareTuples : core::comparator{tuplePoint}.
clauses
    compareTuples(Ta, Tb) = less :-
        Ta = core::tuple(Xa, _Ya),
        Tb = core::tuple(Xb, _Yb),
        Xa < Xb,
        !.
    compareTuples(Ta, Tb) = greater :-
        Ta = core::tuple(Xa, _Ya),
        Tb = core::tuple(Xb, _Yb),
        Xa > Xb,
        !.
    compareTuples(_Ta, _Tb) = equal.

% Унаследованный от fset предикат вычисления принадлежности заданного значения этому нечёткому множеству.
% <затычка>
clauses
    % Если точка с такой абсциссой известна, извлекаем её сохранённую ординату
    get_membership(XValue) = YValue :-
        point(XValue, YValue),
        !.
    % Если функция принадлежности не определена, считаем её тождественным нулём.
    get_membership(_XValue) = 0.0 :-
        [] = getSortedPointList(), 
        !.
    % Если точка неизвестна, линейно интерполируем её, исходя из известных точек слева и справа от искомой.
    get_membership(XValue) = YValue :-
        List = getSortedPointList(), % получаем сортированный по возрастанию список искомых точек
        core::tuple(XYBefore, XYAfter) = getSurroundPoints(XValue, List), % получаем две точки по обе стороны от искомой
        YValue = interpolate(XValue, XYBefore, XYAfter). % получаем ординату точки, лежащей на линии между точками XYBefore и XYAfter, и имеющую абсциссу XValue.

% Получение пары точек, лежащих слева и справа по оси абсцисс от заданной (у заданной точки имеет значение только абсцисса).
predicates
    getSurroundPoints : (real XVal, listPoints List) -> core::tuple{tuplePoint XYBefore, tuplePoint XYAfter}.
clauses    
    % Вариант 1й: искомая точка левее всех известных. 
    %   Считаем, что левее заданных точек функция принадлежности тождественно равна нулю
    %   То, что задали значение здесь, неважно: при интерполировании получим тот же ноль.
    getSurroundPoints(XVal, [XYAfter|_OtherList]) = core::tuple(core::tuple(XVal, 0.0), XYAfter) :-
        XYAfter = core::tuple(XAfter, _YAfter),
        XAfter > XVal,
        !.
    % Вариант 4й (TIME PARADOX): искомая точка правее всех точек заданного списка 
    getSurroundPoints(XVal, [XBefore|[]]) = core::tuple(XBefore, core::tuple(XVal, 0.0)) :-
        !. % подразумевается, что эта единственная точка в списке - не правее искомой, так как обратный случай мы проверили предыдущим предложением.
    % Вариант 2й: искомая точка между первой и второй точками заданного списка
    getSurroundPoints(XVal, [XYBefore|List]) = core::tuple(XYBefore, XYAfter) :-
        XYBefore = core::tuple(XBefore, _YBefore),
        XBefore <= XVal,
        List = [XYAfter|_OtherList],
        XYAfter = core::tuple(XAfter, _YAfter),
        XAfter >= XVal,
        !.
    % Вариант 3й: искомая точка НЕ между первой и второй точками заданного списка
    getSurroundPoints(XVal, [_XYLongBefore|List]) = getSurroundPoints(XVal, List). % может быть, тогда она между 1й и 2й точками ХВОСТА заданного списка?
    % Вариант 5й: список пуст (невозможно отсечь голову) = internal runtime error.
    getSurroundPoints(_AnyXVal, []) = _DontMatter :-
        fuzzySupport::raiseWithMessage(classInfo, "fset_byArray::getSurroundPoints/2-> : Невозможно найти точки, окружающие заданную, если множество точек - пустое!").

% Интерполирование значения функции, заданной отрезком, заданным двумя точками, в точке XValue.
predicates
    interpolate : (real XValue, tuplePoint XYBefore, tuplePoint XYAfter) -> real YValue.
clauses
    % Вариант 4й (TIME PARADOX): заданные точки совпадают, искомая точка - не результат совпадения
    interpolate(X, tuple(X1, Y1), tuple(X1, Y1)) = _DontMatter :-
       X <> X1,
       fuzzySupport::raiseWithMessage(classInfo, "fset_byArray::interpolate/3-> : Невозможно интерполировать вырожденную прямую.").
    % Вариант 5й (TIME PARADOX): заданные точки совпадают, искомая точка - результат совпадения.
    % Ещё менее реальный вариант, чем 4й.
    interpolate(X, tuple(X, Y), tuple(X, Y)) = Y :-
        !.
    % Вариант 1й: искомая точка - левая из заданных двух.
    interpolate(X, tuple(X, Y), _XYAfter) = Y :-
        !.
    % Вариант 2й: искомая точка - правая из заданных двух.
    interpolate(X, _XYAfter, tuple(X, Y)) = Y :-
        !.
    % Вариант 3й: общий случай.
    % Работает и в том случае, если искомая точка НЕ МЕЖДУ двумя заданными, но тогда получается не интерполяция, а экстраполяция.
    interpolate(X, tuple(X1, Y1), tuple(X2, Y2)) = Y :-
        Y = Y1 + ((Y2 - Y1) * (X - X1)) / (X2 - X1).
    
% Унаследованный от fset предикат вычисления абсциссы центра тяжести этого нечёткого множества.
clauses
    center_of_gravity(_A, _B) = SumInNumerator/SumInDenominator :-
        calcSums(getSortedPointList(), SumInNumerator, SumInDenominator).

% Вычисление сумм, необходимых для определения абсциссы центра тяжести фигуры под функцией принадлежности, определённой списком точек
predicates
    calcSums : (listPoints PointList, real SumInNumerator, real SumInDenominator) procedure (i, o, o).
clauses
% Вариант 1й: список пуст (точек нет).
    calcSums([], _DontMatter1, _DontMatter2) :-
        fuzzySupport::raiseWithMessage(classInfo, "fset_byArray::calcSums/3 : Невозможно вычислить абсциссу центра тяжести несуществующей фигуры!").
% Вариант 2й: в списке ровно одна точка (изначально!) - множество имитирует fuzzy singleton
    calcSums([tuple(X, _Y)|[]], X, 1) :-
        !.
% Вариант 3й: в списке 2 точки, и они совпадают (! ошибка логики, такого произойти не должно, об этом должен позаботиться предикат setPoint/2)
    calcSums([XYBefore, XYAfter|[]], X, 1) :- % X/1 = X, и это прокатит, если все точки совпадают по абсциссе (получаем fuzzy singleton). Но это становится неверным, если есть не совпадающие точки.
        XYBefore = tuple(X, _Y1),
        XYAfter = tuple(X, _Y2),
        !.
% Вариант 4й: в списке 2 точки
    calcSums([XYBefore, XYAfter|[]], SIN, SID) :-
        XYBefore = tuple(X1, Y1),
        XYAfter = tuple(X2, Y2),
        Dy = Y2-Y1,
        Dx = X2-X1,
        SIN = Y1 * (X2*X2 - X1*X1)/2 + ((X2*X2*X2 - X1*X1*X1)/3 - (X2*X2 - X1*X1)*X1/2) * Dy/Dx,
        SID = Dx * (Y2 + Y1)/2,
        !.
% Вариант 5й: в списке 2 точки, и ещё остались
    calcSums([XYBefore, XYAfter|List], SIN, SID) :-
        calcSums([XYAfter|List], TempSIN1, TempSID1), % Вычисляем суммы для хвоста списка
        calcSums([XYBefore|[XYAfter|[]]], TempSIN2, TempSID2), % И вычисляем сумму для первых двух элементов.
        SIN = TempSIN1 + TempSIN2,
        SID = TempSID1 + TempSID2.

end implement fset_ByArray
