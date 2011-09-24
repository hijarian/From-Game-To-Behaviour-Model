/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
interface geneticAlgorithm
    open core
    
predicates
    setPopulationSize: (unsigned) procedure (i).
    setMutationRate : (real) procedure (i).
    setDrawMonitor: (genDraw) procedure (i).
    
predicates
    resetPopulation:().
    
predicates
    addCell: (geneticCell, integer) determ (i,i).
    
predicates
    getGeneration: () -> unsigned.
    getTheBestCell:() -> geneticCell.
    getPopulation: () -> geneticPopulation.
    getSize: () -> unsigned .

domains
    gen_control_pred = (geneticAlgorithm) determ (i). % call back function

predicates
    nextGeneration: () .
    nextNGenerations: (integer N) procedure (i).
    nextGenerations: (geneticAlgorithm::gen_control_pred) procedure.
    
domains
    gen_getcell_pred = () -> geneticCell  . % get a new cell 

predicates
    buildGeneration: (geneticAlgorithm::gen_getcell_pred) procedure (i).
    
predicates
    toString: () -> string.
    

end interface geneticAlgorithm
