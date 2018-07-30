function Analisi(I, DebugMode )

% Carico i valori di riferimento delle aree e del colore delle monete
load('riferimenti.mat','AreaMonete','HMonete','SMonete','HBMonete','SBMonete');
    
  [datimoneta NroOggetti]=RicavaMoneta(I,DebugMode);
% [datimoneta NroOggetti]=RicavaMoneta(Immagine,DebugMode) 

iloop=1;
ValoreTotale=0;
while(iloop <= NroOggetti)
    % Calcolo l'area(in CM2) dell'oggetto acquisito
    % AreaCM2=RicavaAreaInCM2(datimoneta, Immagine, indiceDidatimoneta)

    AreaCM2=RicavaAreaInCM2(datimoneta(iloop), I);

    % Recupero la posizione del centroide della moneta
    
    mc=datimoneta(iloop).Centroid;
           
    % RicavaColoreMedioIntorno(Immagine, centro, lato quadrato in pixel, passo)
    % La ricerca del colore viene effettuata su un area quadrata di
    % dimensione specificata, il valore passo, che DEVE essere multiplo
    % del lato in pixel, indica ogni quanto il programma prevela un
    % campione utile a calcolare la media.
    
    HSV=RicavaColoreMedioIntorno(I,mc,40,8,1,DebugMode); 
    %Ricavo il colore medio dal centroide
    H=HSV(1);
    S=HSV(2);
    
    % Estrae il colore della moneta su quattro punti del
    % bordo (per info sul calcolo del colore vedi RicavaColoreMedioIntorno)
    % in modo da distinguere le monete in base al fatto che possono avere il
    % bordo o meno - p.e. considera i 50 c e i 2 euro)
    
    HSVB=RicavaColoreMedioBordo(I,datimoneta(iloop),9,3,1,DebugMode); 
    %Ricavo il colore medio dal bordo della moneta 
    HB=HSVB(1);
    SB=HSVB(2);
    
    % Creazione del descrittore
    Corrispondenza = TrovaCorrispondenza(AreaCM2,H,S,HB,SB,AreaMonete,HMonete,SMonete,HBMonete,SBMonete);
    
    
    % Stampa a video dei risultati calcolati
    if (DebugMode == 1)
        rectangle('Position',datimoneta(iloop).BoundingBox,'Curvature',[1,1]);
        text(mc(1)+60,mc(2)-20,sprintf('Centro:[%.2f %.2f %.1f]',HSV(1),HSV(2),HSV(3)),'FontSize',7,'Color',[0 0 1]);
        text(mc(1)+60,mc(2)-40,sprintf('Bordo :[%.2f %.2f %.1f]',HSVB(1),HSVB(2),HSVB(3)),'FontSize',7,'Color',[0 0 1]);
        text(mc(1)+60,mc(2)-60,sprintf('Area  :[%.4f cm^2]',AreaCM2),'FontSize',7,'Color',[0 0 1]);
        text(mc(1)+60,mc(2)-80,sprintf('Dist. :[%.5f]',Corrispondenza.Distanza),'FontSize',7,'Color',[1 0 0]);
        
    end
    
    datimoneta(iloop).Valore = DimmiLaMoneta(Corrispondenza.Indice);
    ValoreTotale = ValoreTotale + DimmiValoreMoneta(Corrispondenza.Indice);
    RicavaDistanzeDalCentro(datimoneta(iloop), I,1);
    
    
    iloop=iloop+1;
end
text(60,60,sprintf('Totale: %.2f €',ValoreTotale),'FontSize',11,'Color','w','BackgroundColor',[0 .5 1],'FontWeight','bold');
end

