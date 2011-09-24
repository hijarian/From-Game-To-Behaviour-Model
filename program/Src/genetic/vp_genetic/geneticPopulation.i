/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
interface geneticPopulation
    open core
    
predicates
    resetPopulation:().
    
predicates
    getBestFitness:() -> real.
    getMeanFitness:() -> real.
    getStats:(real Min, real Max, real Mean) procedure (o,o,o).
        
predicates
    addCell: (geneticCell,integer) determ (i,i).

predicates
    computeMeanFitness:()      -> real.
    findbestCell             :(geneticCell) -> real procedure (o).

predicates
    reproduction: () -> geneticPopulation.

predicates
    crossover : () -> geneticPopulation .
    
predicates
    mutation: () -> geneticPopulation.
    setMutationRate: (real).
    
predicates
    toString: () -> string.
    
predicates
    isFull: () determ.
    
end interface geneticPopulation