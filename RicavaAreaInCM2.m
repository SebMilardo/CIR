function [AreaCM] = RicavaAreaInCM2(datimoneta,I)
    AreaPIXEL=datimoneta.Area;
    % adesso controllo qual'e' il lato + piccolo cosi' posso costruire la
    % proporzione per passare da pixel a cm
    px=RapportoDiProporzioneCmPixel(I);
    AreaCM=AreaPIXEL/px/px;
end
