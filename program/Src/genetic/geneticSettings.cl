/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/
class geneticSettings
    open core

predicates
    classInfo : core::classInfo.
    % @short Class information  predicate. 
    % @detail This predicate represents information predicate of this class.
    % @end

predicates
    %
    setMutationRate : (real MutationRate).
    
    %
    getMutationRate : () -> real MutationRate.
    
    %
    setPopulationSize : (unsigned PopulationSize).
    
    %
    getPopulationSize : () -> unsigned PopulationSize.
    
    %
    setGenerationsNumber : (unsigned GenerationsNumber).
    
    %
    getGenerationsNumber : () -> unsigned GenerationsNumber.
    
    %
    setCriticalMeanFitness : (real CriticalMeanFitness).
    
    %
    getCriticalMeanFitness : () -> real CriticalMeanFitness.

    %
    setCriticalFitness : (real CriticalFitness).
    
    %
    getCriticalFitness : () -> real CriticalFitness.

end class geneticSettings