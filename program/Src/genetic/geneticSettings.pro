/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement geneticSettings
    open core

constants
    className = "geneticSettings".
    classVersion = "".

clauses
    classInfo(className, classVersion).

class facts
    mutation_rate_fact : real := erroneous.

clauses
    setMutationRate(MR) :-
        mutation_rate_fact := MR.

    getMutationRate() = mutation_rate_fact.

class facts
    population_size_fact : unsigned := erroneous.
    
clauses
    setPopulationSize(PS) :-
        population_size_fact := PS.
    
    getPopulationSize() = population_size_fact.
    
class facts
    generations_number_fact : unsigned := erroneous.

clauses
    setGenerationsNumber(GN) :-
        generations_number_fact := GN.
    
    getGenerationsNumber() = generations_number_fact.
    
class facts
    critical_mean_fitness_fact : real := erroneous.

clauses
    setCriticalMeanFitness(MF) :-
        critical_mean_fitness_fact := MF.
    
    getCriticalMeanFitness() = critical_mean_fitness_fact.

class facts
    critical_fitness_fact : real := erroneous.

clauses
    setCriticalFitness(MF) :-
        critical_fitness_fact := MF.
    
    getCriticalFitness() = critical_fitness_fact.
    

end implement geneticSettings