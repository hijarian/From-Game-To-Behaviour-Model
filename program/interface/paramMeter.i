/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

interface paramMeter supports drawControlSupport
    open core

domains
    paramMeterValue = pmval(/*symbol Label, */real MinValue, real StartValue, real EndValue, real MaxValue).
    
% Элемент управления просто выводит на экран цветные полосочки, на которых:
%   на левом краю отмечено минимальное значение параметра
%   правее отмечено начальное значение параметра
%   ещё где-то правее отмечено конечное значение параметра
%   на правом краю отмечено максимальное значение параметра

predicates
    setValue : (symbol Label, paramMeterValue ValuesTerm).
    setValueList : (core::tuple{symbol Label, paramMeterValue ValuesTerm}* ValueList) .
    
    getValue_nd : (symbol Label, real MinValue, real StartValue, real EndValue, real MaxValue) nondeterm (i, o, o, o, o) (o, o, o, o, o).

properties
    values_count : integer (o).
    
    scrolled_to_value_nmb : integer.
    
predicates
    %
    scrollByValuesCount : (integer ValuesCount).
    
    %
    scrollByScrollEventParameters : (scrollControl Sender, vpiDomains::scrollCode ScrollType, integer ThumbPosition).
    
    %
    initScrollControl : (scrollControl ScrollControlToAssociate).
    
end interface paramMeter