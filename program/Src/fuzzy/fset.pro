/*****************************************************************************

                         

******************************************************************************/

implement fset
    open core

constants
    className = "fuzzy/fset".
    classVersion = "".

clauses
    classInfo(className, classVersion).

facts
    ymin : real := 0.
    ymax : real := 1.
    
end implement fset
