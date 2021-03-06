/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

interface polygonalMeter supports drawControlSupport
    open core

domains
    corner_value = cornerval(symbol Label, integer Value).
    corner_value_list = corner_value*.

properties
    
    %
    cornerCount : unsigned.
    
    %
    steps : unsigned.
    
    %
    values : corner_value_list.
    
    %
    minvalue : integer.
    
    %
    maxvalue : integer.

predicates
    init : (unsigned CornerCount, unsigned StepCount, corner_value_list ValueList, integer MinValue, integer MaxValue) procedure (i, i, i, i, i).

end interface polygonalMeter