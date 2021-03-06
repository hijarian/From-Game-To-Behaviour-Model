/*****************************************************************************

                         

******************************************************************************/

#requires @"fuzzy\fuzzy.pack"
% publicly used packages
#include @"pfc\core.ph"

% exported interfaces
#include @"fuzzy\fuzzyInference.i"
#include @"fuzzy\fuzzyRule.i"
#include @"fuzzy\fset_ByArray.i"
#include @"fuzzy\fset_LR.i"
#include @"fuzzy\fvar.i"
#include @"fuzzy\fset.i"

% exported classes
#include @"fuzzy\fuzzyInference.cl"
#include @"fuzzy\fuzzyRule.cl"
#include @"fuzzy\fset_ByArray.cl"
#include @"fuzzy\fuzzySupport.cl"
#include @"fuzzy\fset_LR.cl"
#include @"fuzzy\fvar.cl"
