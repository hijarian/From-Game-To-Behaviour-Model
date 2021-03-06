/*****************************************************************************

                         

******************************************************************************/

interface fset
    open core

properties
    % Идентификатор нечёткого множества
    id : symbol.
    
predicates
    % Получение значения принадлежности заданного чёткого числа этому нечёткому множеству
    get_membership : (real CrispXValue) -> real MembershipValue.
    % Вычисление абсциссы центра тяжести области, очерченной нечётким множеством
    center_of_gravity : (real Min, real Max) -> real COG_XCoord.
    
end interface fset