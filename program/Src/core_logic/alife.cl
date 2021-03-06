/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class alife
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

constants
    actionlist_log_filename : string = @"actionlist.log".
    
    realityState_log_filename : string = @"reality state.log".
    
predicates
    % Создаём сущность, которая будет оценивать пригодность особей и централизованно хранить в себе правила нечёткого вывода
    %   для оценки особями приоритета действий
    initReality : () procedure.
    
    % Обрабатываем существование особи, и получаем её оценку пригодности
    simulateLife : (cell::phenotype CellPhenotype/*, alifeSettings::ending TargetEnding*/, individual ReturnedIndividual) -> real Fitness procedure (i/*, i*/, o).

predicates
    %
    toString_ending : (alifeSettings::ending EndingObject) -> string Description procedure (i).

    %
    toString_paramChangeList : (individual::paramChangeList IndividParameterChanges) -> string Description procedure (i).
    
    %
    toString_paramChange : (individual::paramChange IndividParameterChange) -> string Description procedure (i).
    
    %
    toString_individParams : (individual Individ) -> string IndividParamsBriefly procedure (i).
    
end class alife