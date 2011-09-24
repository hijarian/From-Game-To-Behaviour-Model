/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
implement geneticPopulation
    open core, rnd

constants
    className = "vp_genetic/geneticPopulation".
    classVersion = "".

clauses
    classInfo(className, classVersion).
    
constants
    defaultPopulationSize = 100.
    defaultMutationRate   = 0.1.


facts
    currentSize     : unsigned := erroneous. % current size of the pop, always <= populationSize
    currentNbDiff  : unsigned := erroneous. % number of different cells in the population
    populationSize : unsigned := erroneous. % this is the maximum size of the population
    mutationRate   : real      := erroneous. 


facts - dbpopulation
    individual: (geneticCell, integer). % a Cell, N x
    
clauses
    new(N) :-
        populationSize := N,
        setMutationRate(defaultMutationRate),
        resetPopulation()
    .%
    
clauses
    setMutationrate(N) :- mutationRate := N.
    
clauses
    resetPopulation() :- 
        retractFactDB(dbpopulation),
        currentSize    := 0,
        currentNbDiff := 0
    .%
    
clauses
    addCell(_, 0) :- !. % don't add zero cell
    addCell(_, _) :- currentSize >= populationSize, !, fail. % fail if you try to add an extra cell to the population
    addCell(Cell, Nb) :-
        individual(CellR, N), % try to find if an analog cell is already in the population
        Cell:equals(CellR), % yes : complete the set of similar cells
        retract(individual(CellR,N)), assert(individual(CellR,Nb+N)), !, % changes its number
        currentSize := currentSize+Nb % stdio::writef("add %d %d\n", Nb, currentSize)
    .%
    addCell(Cell,Nb) :- % if not, add it
        assert(individual(Cell,Nb)),
        currentNbDiff := currentNbDiff+1, % one new cell (that is, different from the other cells)
        currentSize := currentSize+Nb  % stdio::writef("add %d %d\n", Nb, currentSize)
    .%
    
    
    
clauses
    computeMeanFitness() = Res :-
        LN = [Fk*Nk || individual(Cell2,Nk), Fk = Cell2:fitness()],
        Mean = listSum(LN)/populationSize,
        if math::abs(Mean) < 0.000001 then Res = 0.000001
        else Res = Mean end if
    .%
     
clauses
    getMeanFitness() = computeMeanFitness().
    
clauses
    getStats(FMin, FMax, FMean) :-
        L   = [F     || individual(Cell,_N), F = Cell:fitness()],
        FMean = computeMeanFitness(),
        FMin = list::minimum(L),
        FMax = list::maximum(L)
    .%
    

predicates % compute the sum of reals in a list
    listSum: (real *) -> real procedure (i).
      clauses
        listSum([]) = 0.
        listSum([Nb | Q]) = Nb+listSum(Q).
    
    
clauses
    findbestCell(BestCell)= BestFitness :-
        ListOfCell = [  soluce(Fitn, N, CellR) || individual(CellR, N), Fitn = CellR:fitness()  ],
        ListOfCellSorted = list::sort(ListOfCell,descending()),
        ListOfCellSorted = [ soluce(BestFitness,_,BestCell) | _], !
    .%
    findbestCell(BestCell)= 0 :- BestCell = cellAtRandom().

    
facts
    newGen : geneticPopulation := erroneous.
clauses
    reproduction() = _ :-
        LN = [Fk*Nk || individual(Cell2,Nk), Cell2:computeFitness(), Fk = Cell2:fitness()],
        SFitness = listSum(LN), % sum of fitness
        newGen := geneticPopulation::new(populationSize),
            individual(Cell,N), % Brindle scheme
            Repr = math::trunc(populationSize*(N*Cell:fitness()/SFitness)),
            newGen:addCell(Cell,Repr),
        fail    
    .%
    reproduction() = NewGen :- % Complete the Brindle scheme
        std::repeat(), 
        not(newGen:addCell(cellAtRandom(),1)), % add until the population is full
        !,
        NewGen = newGen, newGen := erroneous
    .%
    reproduction()=newGen.
    
 facts
    resCell : geneticCell := erroneous.
 predicates
     cellAtRandom: () -> geneticCell.
 clauses
     cellAtRandom() = _ :-
        Random =rnd(currentNbDiff), 
        _ = std::fromTo(0,convert(integer,Random)),
        individual(Cell,_),
        resCell := Cell,
     fail.%
     cellAtRandom() = resCell.
     
     
 %                                                                        Mutation    
 clauses
    mutation()= This :- % performs a mutation
          foreach individual(Cell,_N) do
                  mutateCellWithProba(Cell)
          end foreach
    .%
    
    
 predicates
    mutateCellWithProba: (geneticCell) procedure (i).
 clauses
    mutateCellWithProba(Cell) :-
        rnd() < mutationRate,
        extract(Cell), 
        CellMutated = Cell:copy(), CellMutated:mutate(),
        addCell(CellMutated ,1),
    !.%
    mutateCellWithProba(_).
    
    
 predicates
    extract: (geneticCell) procedure (i).
 clauses
    extract(Cell) :-
        individual(Cell,N), 
        retract(individual(Cell,N)),
        currentSize := currentSize -1, 
        currentNbDiff := currentNbDiff-1,         
        N>1,!,
        assert(individual(Cell,N-1)),
        currentNbDiff := currentNbDiff+1
    .%
    extract(_).
    
    
 clauses
    isFull() :- currentSize>= (populationSize-1).
 
 %                                                                      Crossover
 
 clauses
    crossover() = NewGen :-
        newGen := geneticPopulation::new(populationSize),
        performsCrossover(),    
        NewGen = newGen, newGen := erroneous
    .%
    
    
 predicates
    performsCrossover: () .
 clauses
    performsCrossover() :-
        std::repeat(),
           C1= cellAtRandom(), extract(C1),
           C2= cellAtRandom(), extract(C2),
           C1:crossoverWith(C2,CC1,CC2), % two points cross over
           newGen:addCell(CC1,1),
           newGen:addCell(CC2,1),
        newGen:isFull(),!
    .%
    performsCrossover().
    
    


clauses
    getBestFitness() = Res :- % gets the best fitness in the pop
       L = [ F || individual(CellR,_), F = CellR:fitness()],
       Res = list::maximum(L), !
    .%
 
 
domains
    d_soluce= soluce(real Fitness, integer Nb, geneticCell Cell).
        
clauses
    toString() = Res :-
        ListOfCell = [  soluce(Fitn, N, CellR) || individual(CellR, N), Fitn = CellR:fitness()  ],
        ListOfCellSorted = list::sort(ListOfCell,descending()),
        Res = lsToString(ListOfCellSorted)
    .%
    predicates
        lsToString: (d_soluce *)-> string.
    clauses
        lsToString([])="".
        lsToString([soluce(Fit,N,CellR) | Q]) = string::concat(Info,"\n",QRes):-
            Info = string::format("    %4.3f       %d x  %s",Fit, N,CellR:toString()),        
            QRes = lsToString(Q)
        .%
 

end implement geneticPopulation
