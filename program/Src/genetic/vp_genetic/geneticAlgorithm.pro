/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
implement geneticAlgorithm
    open core, rnd

constants
    className = "vp_genetic/geneticAlgorithm".
    classVersion = "".

clauses
    classInfo(className, classVersion).

constants
    defaultPopulationSize = 100.
    defaultMutationRate   = 0.1.

    
facts
    currentGeneration   : unsigned                := erroneous. % number of the current Gen
    populationSize        : unsigned                := erroneous. % current Population size
    
    currentPop             : geneticPopulation     := erroneous. %
    drawMonitor           : gendraw                 := erroneous. % drawmonitor
        
clauses
    new() :-
        rnd::seed(), % initialize the random generator
        setPopulationSize(defaultPopulationSize),
        setMutationRate(defaultMutationRate)
    .%
    
clauses
    setPopulationSize(N) :- (N mod 2) = 0, !, % because of the 2 points crossover
        populationSize := N, resetPopulation(), resetGeneration().
        
    setPopulationSize(N) :- 
        populationSize := N+1, resetPopulation(), resetGeneration().
        
    setMutationRate(N)   :- currentPop:setMutationRate(N).
    
    setDrawMonitor(Dm) :- % sets a draw monitor 
        drawMonitor := DM
    .%

clauses
    getSize() = populationSize.
        
clauses
    getTheBestCell() = Res:-
        _ = currentPop:findbestCell(Res)
    .%
        
clauses
    resetPopulation() :- 
        currentPop := geneticPopulation::new(populationSize)
    .%

clauses % adds a cell in the current Population
    addCell(Cell, Nb) :-
        currentPop:addCell(Cell,Nb)
    .%
 

predicates
    drawFitness: ().
    clauses
        drawFitness() :-
            currentPop:getStats(FMin, FMax, FMean),
            _ = currentPop:findbestCell(Cell),
            drawMonitor:bestFitness(Cell,FMax,FMean,FMin, currentGeneration),
            drawMonitor:updateGraph()
        .%
 
    
clauses
    nextGeneration() :- % computes the next generation
        Pop0                      = currentPop:crossover(),
        Pop1                      = Pop0:mutation(),
        currentPop            := Pop1:reproduction(),
        if not(isErroneous(drawMonitor)) then
            drawFitness()
        end if, 
        currentGeneration := currentGeneration+1
    .%

   nextNGenerations(N) :- % compute the N next generations
        R =  std::fromTo(1,N), 
            nextGeneration(),
        R = N,!
   .%
   nextNGenerations(_).
   
   nextGenerations(Callback) :- % callback function : sends the current GA and go on if the callback doesn't fail
            std::repeat(),
               nextGeneration(),
            not(Callback(This)) ,!
   .%
   nextGenerations(_).
   
   
   
clauses
    buildGeneration(GetACell) :-
        F =  std::fromTo(1,convert(integer,getSize())), 
            C = GetACell(),
            C:computeFitness(),
            addCell(C,1),
        F = getSize(),!
    .%
    buildGeneration(_).



    
predicates % resets generation's counter
    resetGeneration: ().
clauses
    resetGeneration() :-
        currentGeneration := 0
    .%
    
clauses
    getGeneration() = currentGeneration.
    
clauses
    getPopulation() = currentPop.
    
clauses
   toString() = Res :-
        MeanFitness = currentPop:getMeanFitness(),
        Res = string::format("Generation :%d\n----------------------------\n    MeanFitness %.2f   PopulationSize : %d\n    Fitness     n    String\n%s\n",currentGeneration,MeanFitness, populationSize,currentPop:toString())
   .%

end implement geneticAlgorithm
