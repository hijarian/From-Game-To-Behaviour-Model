/*****************************************************************************
Genetic Algorithm Toolbox
(c) Gildas Ménier 2006-2007  http://www.arsaniit.com
V1.3 : Added GenDraw control to spy the GA
V1.2 : Added a computeFitness scheme to avoid unnecessary fitness computations 
V1.1 : Changed many parts to conform to 7.02 + faster 
V1.0 : Brindle scheme (6.3) 
******************************************************************************/
#requires @"vp_genetic\genDraw\genDraw.pack"
% publicly used packages
#include @"vp_genetic\vp_genetic.ph"
#include @"pfc\gui\controls\controlSupport\controlSupport.ph"
#include @"pfc\gui\gui.ph"
#include @"pfc\core.ph"

% exported interfaces
#include @"vp_genetic\genDraw\genDraw.i"

% exported classes
#include @"vp_genetic\genDraw\genDraw.cl"
