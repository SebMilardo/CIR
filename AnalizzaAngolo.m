function result = AnalizzaAngolo(B,BW,POS)
    % Ricavo le immagini di un angolo date le posizioni
    % Sia in bianco e nero che a colori
    AngoloBW = imcrop(BW, [POS(1),POS(2),POS(3),POS(4)]);
    AngoloColor = imcrop(B, [POS(1),POS(2),POS(3),POS(4)]);
    AngoloWB = imcomplement(AngoloBW);
                
    % Cerco gli oggetti connessi
    punto = bwconncomp(AngoloWB, 8);
                                
    % Correggo la gamma del colore per rendere il foglio bianco
    if (punto.NumObjects >= 1)
        RGBfoglio = RicavaColoreMedioIntorno(AngoloColor,[55,50],10,5,0,0);
        B=imadjust(B,[0.0 0.0 0.0; RGBfoglio/255],[]);
    end
    result = struct('B',B,'punto',punto,'angolo',AngoloWB);
end

