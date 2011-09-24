/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
interface geneticCell
    open core
  
    %                                                         Fitness Access and computation
    predicates 
       fitness: () -> real.       % gets the fitness of a cell
       computeFitness : ().    % computes the cell fitness

    %                                                         Genetic operators 
       mutate : (). % performs a mutation
       crossoverWith: (geneticCell With, geneticCell Daughter1, geneticCell Daughter2) procedure (i,o,o).  % performs a 2-crossover between two cells
       % as for V1.x the reproduction is built-in
        
    %                                                          Output Predicates 
    predicates
        toString: () -> string.
        draw:( windowGDI, vpiDomains::rct) procedure (i,i). % use it with genDraw control
     
    %                                                          Utils   
    predicates        
        random: ().                          % sets the cell state at random
        equals: (geneticCell) determ. % fails if the two cells are different
        copy : () -> geneticCell.        % duplicates a cell
       
end interface geneticCell
