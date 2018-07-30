function [color]=RicavaColoreMedioBordo(I,datimoneta,index,passo,spazio,DebugMode)
   
    % Ricavo a partire dal BoundingBox della moneta 4 punti
    % di controllo (up,down,dx,sx) per verificare il colore
    % del bordo e successivamente medio queste 4 misure
   
    % Punti di controllo UP
    mbUPX=(datimoneta.BoundingBox(3)/2)+datimoneta.BoundingBox(1);
    mbUPY=datimoneta.BoundingBox(2)+index;
    mbUP=[mbUPX mbUPY];
    
    colorup = RicavaColoreMedioIntorno(I,mbUP,index,passo,spazio,DebugMode);
   
    % Punti di controllo DOWN
    mbDWX=(datimoneta.BoundingBox(3)/2)+datimoneta.BoundingBox(1);
    mbDWY=datimoneta.BoundingBox(4)+ datimoneta.BoundingBox(2) - index;
    mbDW=[mbDWX mbDWY];
    
    colordw = RicavaColoreMedioIntorno(I,mbDW,index,passo,spazio,DebugMode);
    
    % Punti di controllo DX
    mbDXX= datimoneta.BoundingBox(3)+datimoneta.BoundingBox(1)-index;
    mbDXY= datimoneta.BoundingBox(2)+datimoneta.BoundingBox(4)/2;
    mbDX=[mbDXX mbDXY];
    
    colordx = RicavaColoreMedioIntorno(I,mbDX,index,passo,spazio,DebugMode);
    
    % Punti di controllo SX
    mbSXX= datimoneta.BoundingBox(1) + index;
    mbSXY= datimoneta.BoundingBox(2)+ datimoneta.BoundingBox(4)/2;
    mbSX=[mbSXX mbSXY];
    
    colorsx = RicavaColoreMedioIntorno(I,mbSX,index,passo,spazio,DebugMode);
    
  
    % Passaggio dallo spazio dei colori RGB a quello HSV
    color=(colorsx+colordx+colorup+colordw)/4;
    
    
end