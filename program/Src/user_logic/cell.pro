/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

implement cell
    open core

constants
    className = "user_logic/cell".
    classVersion = "".

clauses
    classInfo(className, classVersion).

clauses
    new() :-
        !.
        
constants
    error_signature : symbol = "User Logic Error : genetic".
    
class facts
    knownFitness : (genome CellGenome, real CellFitness, individual RaisedCell) nondeterm.

facts
    fitness_fact : real := erroneous.

clauses
    fitness() = fitness_fact.

facts
    raised_cell : individual := erroneous.

clauses
    getIndividual() = raised_cell.

clauses
    computeFitness() :-
        knownFitness(coding, AlreadyComputedFitness, AlreadyRaisedCell),
        !,
        fitness_fact := AlreadyComputedFitness,
        raised_cell := AlreadyRaisedCell.
    computeFitness() :-
% К этому моменту когда-нибудь ранее обязана быть выполнена alife::initReality() (!!!)
       CellValue = getValue(),
       fitness_fact := alife::simulateLife(CellValue/*, alifeSettings::targetEnding*/, CreatedIndividual),    % TODO error handler
       raised_cell := CreatedIndividual,
       assert(knownFitness(coding, fitness_fact, raised_cell)).

facts
    coding : genome := erroneous.

% Все дальнейшие предикаты реализованы с расчётом на то, что фенотип представлен в виде списка целых чисел,
%    каждое из которых лежит в пределах [0..3] (4 целочисленных значения).
% Геном представлен целым беззнаковым 32-разрядным числом, имитирующим список битов длиной 32 (больше, чем нужно, но это несущественно).
%  Значимая длина генома = 2 * 8 бит = 16 бит (так как 4 значения кодируются 2 битами).

constants
    genome_length : unsigned = 16.

predicates
    isIncorrectPos : (unsigned Position, string CallerPredicateName) failure (i, i).
clauses
    isIncorrectPos(Pos, Caller) :-
        Pos > genome_length - 1,
        !,
        Msg = string::concat(Caller, " : Попытка выполнить кроссовер через ген номер ", toString(Pos), " - за пределами длины генома"),
        exception::raise(
            classInfo,
            runtime_exception::internalError,
            [namedValue(error_signature, string(Msg))]).

    
predicates % Осуществляет кроссовер
    buildCross: (genome First, genome Second, unsigned Position, genome FirstDaughter, genome SecondDaughter) procedure (i,i,i,o,o).
clauses
    buildCross(_First, _Second, Position, _FD, _SD) :-
        isIncorrectPos(Position, "cell:buildCross/5").
    buildCross(First, Second, Pos, FirstD, SecondD) :-
        First_Top = bit::bitLeft(bit::bitRight(First, Pos), Pos),    % Сдвинули на Pos вправо, затем влево - заменили цифры до Pos (справа) на нули
        Second_Top = bit::bitLeft(bit::bitRight(Second, Pos), Pos),    % то же, что и предыдущий
        First_Bottom = First - First_Top,
        Second_Bottom = Second - Second_Top,
        FirstD = First_Top + Second_Bottom,
        SecondD = Second_Top + First_Bottom.
  
predicates 
    invertCodingAt: (genome Genome, unsigned Position) -> genome ResultGenome.
clauses
    invertCodingAt(_Genome, Pos) = _DontMatter :-
        isIncorrectPos(Pos, "cell:invertCodingAt/2->").
    invertCodingAt(Genome, 0) = Result :-
        Result = bit::bitXor(Genome, 1),
        !.
    invertCodingAt(Genome, Pos) = Result :-
        Flipper = bit::bitLeft(1, Pos),
        Result = bit::bitXOR(Genome, Flipper).
        
clauses
    setCoding(Coding) :- coding := Coding.
 
 clauses
    getCoding() = coding.
    
clauses
    % Оператор мутации
    mutate() :- 
        coding := invertCodingAt(coding, math::random(genome_length)). % 

clauses
    % Копирование клетки
    copy() = Res :- % makes a copy of this cell
        Res = cell::new(),    % Создаём экземпляр класса cell, наследника cell_Base - так как он является определением клетки, принадлежащем конкретизации
        Res:setcoding(coding)
    .%
    
clauses
    crossoverWith(C,C1,C2) :- % two points crossover : this x C -> C1 and C2
        % logically, this should have been a class predicate (C1,C2,COut1,Cout2) - but this way, all the predicates remain in one file
        Point = 1+math::random(genome_length - 1), % where to cut
        % Point in [1..15]  // так как [0, 15) + 1 = [1, 16) = [1, 15]
        CBinCell = convert(cell,C), % convert has to be performed here because the type is not known at compile time
        Coding = CBinCell:getCoding(), % retrieves the coding
        buildCross(coding, Coding, Point, C1L, C2L),
        C1b = cell::new(), C1b:setCoding(C1L), C1 = convert(geneticCell,C1b),
        C2b = cell::new(), C2b:setCoding(C2L), C2 = convert(geneticCell, C2b)
    .%
    
 clauses
    equals(Cell) :- % true if equals to This
        CBinCell = convert(cell,Cell), % again, seems that a convert is necessary there
        coding = CBinCell:getCoding()
    .%

 clauses
    draw(GDI,vpiDomains::rct(LX,LY,_,_)) :- % use this with the control (but you don't have to)
        GDI:setfont(vpi::fontCreateByName("Times New Roman", 10)),
        GDI:setForeColor(vpiDomains::color_Black),
        GDI:drawText(vpiDomains::pnt(LX+4,LY+20), This:toString())
    .%

clauses
    toString() = String :-
        Value = This:getValue(),
        Value = [Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr | _ErroneousValues],
        !,
        String = string::format("[%d, %d, %d, %d, %d, %d, %d, %d]", Phys, Cogn, Creat, Masc, Fem, Intr, Sex, Aggr).
/*
       String = string::concatList([
            "----Inclinations:\n",
            "Physical: ", toString(Phys), "\n",
            "Cognitive: ", toString(Cogn), "\n",
            "Creative: ", toString(Creat), "\n",
            "Masculine: ", toString(Masc), "\n",
            "Feminine: ", toString(Fem), "\n",
            "Introvertive: ", toString(Intr), "\n",
            "Sexual: ", toString(Sex), "\n",
            "Aggressive: ", toString(Aggr), "\n"]).
*/
    toString() = _String :-
        Msg = string::concat("cell:toString/0-> : Не удалось вывести клетку на печать: неверно извлекается значение из генома: This:getValue() = ", toString(This:getvalue())),
        exception::raise(
            classInfo,
            runtime_exception::internalError,
            [namedValue(error_signature, string(Msg))]).
        
clauses
    random() :-
        % не забыть вызвать в каком-нибудь из инициализаторов math::randomInit/1 !!
        This:setCoding(math::random(2^16)).

% Делит беззнаковое целое Input, рассматриваемое в виде строки битов, на кусочки длины ChunkSize, начиная от бита номер Position
%   и заканчивая крайним правым битом (счёт битов справа налево, крайний левый - 31й). Возвращает список целых чисел Output - список десятичных значений каждого отсечённого кусочка
%   исходной битовой строки.
%   При Position = 31 и ChunkSize = 1 делит Input на биты, и Output будет содержать побитовое представление Input
class predicates
    partUnsignedToUList : (unsigned Input, unsigned* Accumulator, unsigned Position, unsigned ChunkSize) -> unsigned* Output.
clauses
    partUnsignedToUList(_Input, Acc, Pos, ChSize) = list::reverse(Acc) :-
        Pos < ChSize,
        !.
    partUnsignedToUList(Input, Acc, Pos, ChSize) = Res :-
        NewPos = Pos - ChSize,
        Chunk = bit::bitRight(Input, NewPos),
        NextInput = Input - bit::bitLeft(Chunk, NewPos),
        NewAcc = [Chunk | Acc],
        Res = partUnsignedToUList(NextInput, NewAcc, NewPos, ChSize).

clauses
    getValue() = CellValue :-
        CellValue = partUnsignedToUList(coding, [], genome_length, 2).

end implement cell
