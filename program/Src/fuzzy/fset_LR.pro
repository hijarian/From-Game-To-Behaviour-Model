/*****************************************************************************

                         

******************************************************************************/

implement fset_LR
    open core, fuzzySupport

constants
    className = "fuzzy/fset_LR".
    classVersion = "".

clauses
    classInfo(className, classVersion).

clauses    
    new(ID) :-
        id := ID.
        
facts
    id : symbol := erroneous.

facts
    mfunc : mf_stored := erroneous.

clauses
    membership_function() = mfunc.
    membership_function(MF) :-
        mfunc := MF.

clauses
    center_of_gravity(_XMin, _XMax) = COG :-
        mfunc = mff(triangleMF, [X1, X2, X3| _]),
        !,
        COG = (X1 + X2 + X3) / 3.
/*
Следующая формула - упрощение из следующей (записываем на бумажке и разбираем самостоятельно):
  ((x1 + 2 * x2)/3 + (x2 + (x3 - x2)/2) + (2 * x3 + x4)/3) / 3
Подразумевается, что находим абсциссу центра масс (центроида) трапеции, построенной на точках (x1, 0), (x2, 1), (x3, 1), (x4, 0),
  ординаты имеют значение!
*/        
    center_of_gravity(_XMin, _XMax) = COG :-
        mfunc = mff(trapezoidMF, [X1, X2, X3, X4| _]),
        !,
        COG = (2 * (X1 + X4) + 7 * (X2 + X3)) / 18.
/*
    triangleLMF(x1, x2) описывает прямоугольную трапецию (xmin, 0), (xmin, 1), (x1, 1), (x2, 0), где xmin - минимум универсума дискурса
      (не забываем, что рассматриваем функцию принадлежности нечёткому множеству)
*/
    center_of_gravity(XMin, _XMax) = COG :-
        mfunc = mff(triangleLMF, [X1, X2| _]),
        !,
        COG = (2 * (XMin + X2) + 7 * (XMin + X1)) / 18.
/*
    triangleRMF(x1, x2) описывает прямоугольную трапецию (x1, 0), (x2, 1), (xmax, 1), (xmax, 0), где xmax - максимум универсума дискурса
      (не забываем, что рассматриваем функцию принадлежности нечёткому множеству)
*/
    center_of_gravity(_XMin, XMax) = COG :-
        mfunc = mff(triangleRMF, [X1, X2| _]),
        !,
        COG = (2 * (X1 + XMax) + 7 * (X2 + XMax)) / 18.
% для произвольных функций принадлежности формула определения центра масс выглядит как частное интегралов, 
%  так что реализации пока нет
    center_of_gravity(_AnyArg1, _AnyArg2) = _AnyRes :-
        Msg = string::concat("Вычисление центра тяжести для произвольно",
                       " определённого нечёткого множества ещё не реализовано"),
        exception::raise(
            classInfo,
            runtime_exception::internalError,
            [namedValue("DN", string(Msg))]).

clauses
% Получение значения функции принадлежности для заданного чёткого значения
% <закончено>
    get_membership(XVal) = MVal :-
        try
            mfunc = mff(MF, Args)
        catch ErroneusValueException do
            EVMsg = "Не инициализированная функция принадлежности для нечёткого множества",
            continueWithMessage(classInfo, ErroneusValueException, EVMsg)
        end try,    
        try
            MVal = MF(XVal, Args)
        catch BadFunctionException do
            BFMsg = string::concat("fset_LR::get_membership/1-> : Не удалось корректно вычислить принадлежность: ",
                    "Выполнение функции принадлежности завершилось аварийно."),
            continueWithMessage(classInfo, BadFunctionException, BFMsg)
        end try.
           
    
end implement fset_LR