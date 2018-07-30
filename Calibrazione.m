function Calibrazione(I,SavingMode,DebugMode)

if (SavingMode ~= 0)
% Dimensioni immagini in ingresso    

Wx = 1280; % Larghezza
    
% Dimensioni foglio in uscita    

Fx = Wx; 
Fy = round(Fx*210/291);

% Posizione e Dimensione rettangolo di ricerca per correzione immagine
% distorta
Rx = round(Fx/18.28);   % Distanza dal foglio  
Ry = round(Fy/18.4);
    
Zx = round(Fx/10);      % Dimensione area di ricerca
Zy = round(Fy/10);

% Posizione e Dimensione rettangolo di ricerca per calibrazione immagine
Cx = round((Wx - 2*Rx - 2*Zx)/4);   % Distanza dal foglio  
Cy = round((Fy - 2*Ry - 2*Zy)/2);

NewAreaMonete = zeros(1,8);
NewHMonete = zeros(1,8);
NewSMonete = zeros(1,8);
NewHBMonete = zeros(1,8);
NewSBMonete = zeros(1,8);

iloop = 0;
for k = 1:4  
for i = 0:1    
  
    
subI = imcrop(I,[Fx-Rx-Zx-k*Cx Ry+Zy+i*Cy Cx Cy]);     
iloop = iloop+1;    
    [datimoneta NroOggetti]=RicavaMoneta(subI,DebugMode);
  % [datimoneta NroOggetti]=RicavaMoneta(Immagine,DebugMode) 

if (NroOggetti == 1)
    % Calcolo l'area(in CM2) dell'oggetto acquisito
    % AreaCM2=RicavaAreaInCM2(datimoneta, Immagine, indiceDidatimoneta)

    NewAreaMonete(1,iloop)=RicavaAreaInCM2(datimoneta(1), subI);

    % Recupero la posizione del centroide della moneta
    
    mc=datimoneta(1).Centroid;
           
    % RicavaColoreMedioIntorno(Immagine, centro, lato quadrato in pixel, passo)
    % La ricerca del colore viene effettuata su un area quadrata di
    % dimensione specificata, il valore passo, che DEVE essere multiplo
    % del lato in pixel, indica ogni quanto il programma prevela un
    % campione utile a calcolare la media.
    
    HSV=RicavaColoreMedioIntorno(subI,mc,40,8,1,DebugMode); 
    %Ricavo il colore medio dal centroide
    NewHMonete(1,iloop)=HSV(1);
    NewSMonete(1,iloop)=HSV(2);
    
    % Estrae il colore della moneta su quattro punti del
    % bordo (per info sul calcolo del colore vedi RicavaColoreMedioIntorno)
    % in modo da distinguere le monete in base al fatto che possono avere il
    % bordo o meno - p.e. considera i 50 c e i 2 euro)
    
    HSVB=RicavaColoreMedioBordo(subI,datimoneta(1),9,3,1,DebugMode); 
    %Ricavo il colore medio dal bordo della moneta 
    NewHBMonete(1,iloop)=HSVB(1);
    NewSBMonete(1,iloop)=HSVB(2);  
       
    % Stampa a video dei risultati calcolati
    if (DebugMode == 1)
        rectangle('Position',datimoneta(1).BoundingBox,'Curvature',[1,1]);
        text(mc(1)+60,mc(2)-20,sprintf('Centro:[%.2f %.2f %.1f]',HSV(1),HSV(2),HSV(3)),'FontSize',7,'Color',[0 0 1]);
        text(mc(1)+60,mc(2)-40,sprintf('Bordo :[%.2f %.2f %.1f]',HSVB(1),HSVB(2),HSVB(3)),'FontSize',7,'Color',[0 0 1]);
        text(mc(1)+60,mc(2)-60,sprintf('Area  :[%.4f cm^2]',NewAreaMonete(iloop)),'FontSize',7,'Color',[0 0 1]);        
    end
    
end
end
end    
end    
    switch SavingMode 
        case 0 
  %                    1c   2c   5c   10c  20c  50c   1e   2e  
       AreaMonete =  [2.07 2.76 3.55 3.03 3.89 4.62 4.25 5.21];  
       HMonete =     [0.04 0.04 0.04 0.08 0.08 0.08 0.39 0.08];     
       SMonete =     [0.85 0.85 0.85 0.77 0.77 0.77 0.12 0.85];                     
       HBMonete =    [0.04 0.04 0.04 0.08 0.08 0.08 0.08 0.39];     
       SBMonete =    [0.85 0.85 0.85 0.77 0.77 0.77 0.77 0.12];       
        case 1
       AreaMonete = NewAreaMonete;
       HMonete =    NewHMonete;
       SMonete =    NewSMonete;
       HBMonete =   NewHBMonete;
       SBMonete =   NewSBMonete;
        case 2
       load('riferimenti','AreaMonete','HMonete','SMonete','HBMonete','SBMonete');     
       AreaMonete = (AreaMonete+NewAreaMonete)/2;
       HMonete =    (HMonete+NewHMonete)/2;
       SMonete =    (SMonete+NewSMonete)/2;
       HBMonete =   (HBMonete+NewHBMonete)/2;
       SBMonete =   (SBMonete+NewSBMonete)/2; 
    end
    save('riferimenti','AreaMonete','HMonete','SMonete','HBMonete','SBMonete');
end

