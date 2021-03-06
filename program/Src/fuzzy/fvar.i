/*****************************************************************************

                         

******************************************************************************/

interface fvar
    open core

properties
    % Идентификатор (имя) нечёткой переменной
    id : symbol.
    
    % Чёткое значение
    xvalue : real.
    
    % Нечёткое значение (присваивается при нечётком логическом выводе)
    fvalue : fset.
    
    % Нижняя (левая) граница универсума дискурса
    xmin : real.
    
    % Верхняя (правая) граница универсума дискурса
    xmax : real.
    
predicates
    % Добавить терм в термсет
    addTerm : (symbol TermName, fset TermFuzzySet).

    %
    addTermList : (core::tuple{symbol TermName, fset TermFuzzySet}*).
    
    % Попробовать получить нечёткое множество, связанное с термом, обладающим заданным идентификатором
    tryGetTerm : (symbol SetId) -> fset ReturnSet determ.
    
    % Получить нечёткое множество, связанное с термом, обладающим заданным идентификатором.
    %    Если такой терм не определён для данной переменной, runtime error.
    getTerm : (symbol SetID) -> fset ReturnSet.
    
    %
    getTerm_nd : (symbol TermID, fset TermFSet) nondeterm (o, o) (i, o).
    
    % Попробовать получить значение принадлежности чёткого значения переменной заданному терму (лингвистическому значению)
    tryGetMembership : (symbol SetId) -> real MembershipValue determ.
    
end interface fvar