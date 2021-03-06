/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement geneticProcess
    open core

constants
    className = "geneticProcess".
    classVersion = "".

clauses
    classInfo(className, classVersion).

class facts
    top_level_logger : logger := erroneous.
    
    log_filename_fact : string := "GA.log".

    log_type_fact : logger::logtype := logger::xhtml().

clauses
    getLogFilename() = log_filename_fact.
    
    setLogFilename(FN) :-
        log_filename_fact := FN.

    getLogType() = log_type_fact.
    
    setLogType(LT) :-
        log_type_fact := LT.
    
clauses
    run(DrawControl) = BestCell :-
        top_level_logger := logger::new(log_type_fact, 5, log_filename_fact),
        
        GA = geneticAlgorithm::new(), % creates a new Genetic Algorithm
        
        top_level_logger:record("event", "genetic", string::concat("Поиск решения генетическим алгоритмом. Цель - особь, соответствующая требованиям:\n", alife::toString_ending(alifeSettings::getTargetEnding()))),
        
        PS = geneticSettings::getPopulationSize(),
        MR = geneticSettings::getMutationRate(),
        
        top_level_logger:record("report", "genetic", string::format("Population size = %d, mutationRate = %f, max generations number = %d", PS, MR, geneticSettings::getGenerationsNumber())), 
        
        GA:setPopulationSize(PS), % size of the population
        GA:setMutationRate(MR), % mutation rate
        GA:setDrawMonitor(DrawControl), % you may provide a monitor : this should be a genDraw control
        % this control is designed to display GA fitness evolution
        % if you do not provide a control, the GA will still work, without any graphical display, but faster
        % just comment the previous line to see what happens then
        
        DrawControl:reset(), % resets/prepares the display (clears it)
        
        alife::initReality(),
        
        GA:buildGeneration(genNewRandomCell), % This registers a callback designed to create a new cell
        % (see below) This predicates will build an initial population using this predicates.
        
        InitPopStr = GA:toString(),
        stdio::write("Initial population : \n", InitPopStr), % writes the first population
        top_level_logger:record("event", "genetic", "Начато итерирование генетического алгоритма"),
        top_level_logger:record("report", "genetic", InitPopStr),

      % Начинаем итерировать
        GA:nextGenerations(genControl),
        % this runs the GA : you must provide the genControl predicate (see below) that should fail when the GA have
        % to stop.
      % Закончили итерировать

        top_level_logger:record("event", "genetic", "Итерирование генетического алгоритма успешно закончено"),
        stdio::write("Last population : \n",GA:toString()), % writes the last population

        % получаем результат
        BestCell = convert(cell, GA:getTheBestCell()),

        % показали результат в окне сообщений и записали в лог
        BestCellDescr = BestCell:toString(),
        top_level_logger:record("event", "genetic", string::concat("Найденное решение: ", BestCellDescr)),
        stdio::write("\nThe best solution is : ", BestCellDescr),
        top_level_logger:closeLog().

class predicates % This builds a new cell at random
    genNewRandomCell : geneticAlgorithm::gen_getcell_pred.
clauses
    genNewRandomCell() = Cell :- 
        Cell = cell::new(),
        Cell:random()
    .%

class predicates % This predicates controls the genetic computation
    genControl : geneticAlgorithm::gen_control_pred.
clauses
% Останавливаем ГА или когда перебрали заданное количество поколений...
    genControl(GA) :-
        GA:getGeneration() > geneticSettings::getGenerationsNumber(),
        !,
        top_level_logger:record("warning", "genetic", string::format("Итерирование закончено: достигнуто последнее допустимое поколение №%d", geneticSettings::getGenerationsNumber())),
        fail % stops the Genetic Algorithm when it fails
    .%
% ...или когда нашли клетку с приспособленностью, превышающей заданную критическую...
    genControl(GA) :-
        Pop = GA:getPopulation(),
        BF = Pop:getBestFitness(),
        BF > geneticSettings::getCriticalFitness(),
        !,
        top_level_logger:record("event", "genetic", string::format("Итерирование закончено: найдена особь с приспособленностью %.4f большей критической %.4f", BF, geneticSettings::getCriticalFitness())),
        fail % stops the Genetic Algorithm when it fails
    .%
% ...или когда средняя приспособленность по популяции, превышает заданную критическую...
    genControl(GA) :-
        Pop = GA:getPopulation(),
        MF = Pop:getMeanFitness(),
        MF > geneticSettings::getCriticalMeanFitness(),
        !,
        top_level_logger:record("event", "genetic", string::format("Итерирование закончено: достигнуто поколение со средней приспособленностью %.4f большей критической %.4f", MF, geneticSettings::getCriticalMeanFitness())),
        fail % stops the Genetic Algorithm when it fails
    .%
    genControl(GA) :-
        !,
        % , stdio::write(GA:toString()) % uncomment if you want to see each generation
        top_level_logger:record("report", "genetic", GA:toString()).


end implement geneticProcess
