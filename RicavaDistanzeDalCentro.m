function [Alto Basso Sx Dx PtAlto PtBasso PtSx PtDx] = RicavaDistanzeDalCentro(datimoneta, I, visualizzaOutput)
    px=RapportoDiProporzioneCmPixel(I);
    dimI=size(I);
    X=datimoneta.Centroid(1);
    Y=datimoneta.Centroid(2);
    
    % dimI(1) ALTEZZA
    % dimI(2) LARGHEZZA
    
    if(visualizzaOutput==1)
        % Costruisco gli assi per individuare il centroide
        asseVERTICALE=0:1:(dimI(1)-1);
        asseORIZZONTALE=0:1:(dimI(2)-1);
        hold on;
        v1=linspace(X,X,dimI(1));
        v2=linspace(Y,Y,dimI(2));
        h = plot(v1,asseVERTICALE,asseORIZZONTALE,v2);      
        set(h,'LineWidth',1,{'LineStyle'},{':';':'})
        set(h,{'Color'},{[.9 .9 .9];[.9 .9 .9]})
        plot(X,Y,'r*');
        text(X-10,Y-15,datimoneta.Valore,'FontSize',11,'Color','w','BackgroundColor',[0 .5 1]);
    end
    
    % Per indicare in cm le coordinate del punto
    % è stato aggiunto un +1 alle coordinate in pixel
    % visto che i pixel sono numerati da 0 a maxDim-1.
    Sx=(X+1)/px;    %Ovest
    Alto=(Y+1)/px;  %Nord

    % Per le differenze l'aggiunta di +1 sarebbe stata
    % fatta sia per dimI che per X... quindi gli 1 si
    % annullerebbero per la differenza.
    Dx=((dimI(2)-X))/px;      %Est
    Basso=((dimI(1)-Y))/px;   %Sud
    
    if(visualizzaOutput==1)
        % Visualizzo il risultato sovrapponendolo all'immagine
        text(X-100,Y,sprintf('%.1f cm',Sx),'FontSize',7,'Color',[.5 .5 .5]);
        text(X+60,Y,sprintf('%.1f cm',Dx),'FontSize',7,'Color',[.5 .5 .5]);
        text(X,Y-60,sprintf('%.1f cm',Alto),'FontSize',7,'Color',[.5 .5 .5]);
        text(X,Y+60,sprintf('%.1f cm',Basso),'FontSize',7,'Color',[.5 .5 .5]);
    end
    PtAlto=[X 0]; 
    PtBasso=[X dimI(1)-1];  
    PtSx=[0 Y];  
    PtDx=[dimI(2)-1 Y]; 
end