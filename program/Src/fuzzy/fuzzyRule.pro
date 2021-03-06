/*****************************************************************************

                         

******************************************************************************/

implement fuzzyRule
    open core, fuzzySupport

constants
    className = "fuzzy/fuzzyRule".
    classVersion = "".

clauses
    classInfo(className, classVersion).

% Конструктор по умолчанию
clauses
    new() :-
        certainty_fact := 0.0,
        firing_strength := 0.0,
        antecedentsCount := 0,
        consequencesCount := 0.

% "Определённость" правила, коэффициент, на который будет умножена firing_strength
facts 
    certainty_fact : real := erroneous.
clauses
    certainty() = certainty_fact.
    certainty(X) :-
        certainty_fact := X.

% Содержательная часть правила
facts -fRuleClauses
    % Предпосылки - левая часть правила
    antecedent : (/* id, */ fclause LHSClause).
    
    % Счётчик предпосылок, обнуляется при создании правила
    %   и инкрементируется при добавлении предпосылки
    antecedentsCount : integer := erroneous.
    
    % Последствия - правая часть правила
    consequence : (/* id, */fclause RHSClause).
    
    % Счётчик последствий, обнуляется при создании правила
    %   и инкрементируется при добавлении последствия
    consequencesCount : integer := erroneous.

clauses
    % Добавить предпосылку (предложение в левую часть правила)
    addToLHS(FC) :-
        assert(antecedent(FC)),
        antecedentsCount := antecedentsCount + 1.

    %
    addListToLHS([]) :-
        !.
    addListToLHS([FC | List]) :-
        addToLHS(FC),    % atomic-argument variant
        addListToLHS(List).
    
    % Добавить последствие (предложение в правую часть правила)
    addToRHS(FC) :-
        assert(consequence(FC)),
        consequencesCount := consequencesCount + 1.

    %
    addListToRHS([]) :-
        !.
    addListToRHS([FC | List]) :-
        addToRHS(FC),    % atomic-argument variant
        addListToRHS(List).

% Получение количества предпосылок/последствий
clauses
    getLHSCount() = antecedentsCount.
    getRHSCount() = consequencesCount.

clauses        
    % Получить какую-нибудь предпосылку
    getLHSClause_nd() = FC :-
        antecedent(FC).

    % Получить какое-нибудь последствие
    getRHSClause_nd() = FC :-
        consequence(FC).

% Firing strength правила, тот коэффициент, который будет играть роль при нечётком выводе
%   при построении результирующего нечёткого множества
facts 
    firing_strength : real := erroneous.

end implement fuzzyRule