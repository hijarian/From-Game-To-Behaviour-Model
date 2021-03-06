/***********************************************************************
Сафронов М. А. (Mark Saphronov)                           /Public domain
***********************************************************************/

interface cell 
    supports geneticCell
    open core

% Exported domains
domains
    %
    genome = unsigned.
    
    %
    phenotype = unsigned*.
    
%
predicates
    %
    setCoding : (genome GenomeCoding).
    
    %
    getCoding : () -> genome GenomeCoding.
    
    %
    getIndividual : () -> individual RaisedCell.
    
    %
    getValue : () -> phenotype CellValue.

    
end interface cell
