/*****************************************************************************

                         

******************************************************************************/

interface fuzzyRule
    open core, fuzzySupport

predicates
    % Добавить предложение к левой части правила
    addToLHS : (fclause FClause).
    
    %
    addListToLHS : (fclause* FClauseList).
    
    % Добавить предложение к правой части правила
    addToRHS : (fclause FClause).
    
    %
    addListToRHS : (fclause* FClauseList).
    
    % Получить кол-во предложений в левой части правила
    getLHSCount : () -> integer LHSCount.
    
    % Получить кол-во предложений в правой части правила
    getRHSCount : () -> integer RHSCount.
    
    % Извлечь какое-нибудь предложение из левой части правила
    getLHSClause_nd : (/* id */) -> fclause LHSClause nondeterm.
    
    % Извлечь какое-нибудь предложение из правой части правила
    getRHSClause_nd : (/* id */) -> fclause RHSClause nondeterm.
    
    % Вычислить т. н. firing strength левой части правила
%    aggregate : () -> real AggregatedValue.
    
properties
    % "Определённость" правила: коэффициент, на который будет умножена firing strength правила
    certainty : real.
    
    % Уже вычисленная firing strength правила
    firing_strength : real.
    
end interface fuzzyRule