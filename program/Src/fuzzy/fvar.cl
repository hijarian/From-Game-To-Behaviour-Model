/*****************************************************************************

                         

******************************************************************************/
class fvar : fvar
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

constructors
% Конструктор по умолчанию требует установить для нечёткой переменной имя и границы дискурса
    new : (symbol Name, real XMin, real XMax).

end class fvar