/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
interface genDraw supports drawControlSupport%userControlSupport
    open core


predicates
    reset:().

predicates
    updateGraph:().
    
predicates
        bestFitness: (geneticCell Cell, real Fit, real Mean, real FitMin, unsigned Gen).

end interface genDraw