function Corrispondenza = TrovaCorrispondenza(AreaCM2,H,S,HB,SB,AreaMonete,HMonete,SMonete,HBMonete,SBMonete)
    % Nota: il valore della Tonalit�(Hue) e della Saturazione(Saturation)
    % sono stati moltiplicati per due in modo da far pesare maggiormente
    % la differenza di colore tra una moneta e un'altra rispetto ai valori
    % delle aree.
    pesoArea=1;
    pesoH=1;
    pesoS=1;
    pesoHB = 1;
    pesoSB = 1;
    % Trovo il minimo come distanza euclidea tra tutte le monete
   
    DistanzaArea      = abs(AreaCM2-AreaMonete);
    DistanzaAreaNorm  = DistanzaArea/max(DistanzaArea);
    
    DistanzaH      = abs(H-HMonete);
    DistanzaHNorm  = DistanzaH/max(DistanzaH);
    
    DistanzaS      = abs(S-SMonete);
    DistanzaSNorm  = DistanzaS/max(DistanzaS);
    
    DistanzaHB     = abs(HB-HBMonete);
    DistanzaHBNorm = DistanzaHB/max(DistanzaHB);
    
    DistanzaSB     = abs(SB-SBMonete);
    DistanzaSBNorm = DistanzaSB/max(DistanzaSB);
    
    Distanza = pesoArea * DistanzaAreaNorm + pesoH * DistanzaHNorm + pesoS * DistanzaSNorm + pesoHB * DistanzaHBNorm + pesoSB * DistanzaSBNorm;
    
    [Minimo,indiceMinimo] = min(Distanza);
    Corrispondenza = struct('Indice',indiceMinimo,'Distanza',Minimo);
end

