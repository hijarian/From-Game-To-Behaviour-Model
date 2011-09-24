/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
#requires @"vp_genetic\vp_genetic.pack"
% publicly used packages
#include @"vp_genetic\genDraw\genDraw.ph"
#include @"pfc\core.ph"

% exported interfaces
#include @"vp_genetic\geneticCell.i"
#include @"vp_genetic\geneticPopulation.i"
#include @"vp_genetic\geneticAlgorithm.i"

% exported classes
#include @"vp_genetic\geneticPopulation.cl"
#include @"vp_genetic\geneticAlgorithm.cl"
