function [color]=RicavaColoreMedioIntorno(I,mc,index,passo,spazio,DebugMode)
   
   % La media è ottenuta come somma dei valori RGB dei pixel multipli di index fratto
   % il numero di pixel
   
    startX = mc(1)-(index/2);
    startY = mc(2)-(index/2);
    media= zeros(1,3);
    count = 0;
    for i = 1:passo:index;
        for j = 1:passo:index;
            RGBpixel = impixel(I,startX+i,startY+j);
            if (isnan(RGBpixel(1))|| isnan(RGBpixel(2))|| isnan(RGBpixel(3))) 
            else
                media = media + RGBpixel; 
                count=count+1;
            end
        end
    end
    RGB=media/count;
    % Disegno sopra la moneta un quadrato pari all'area considerata
    % e del colore ottenuto con la media 
    if (DebugMode == 1)
        rectangle('Position',[startX startY index index],'FaceColor',RGB/255);
    end
    % Passaggio dallo spazio dei colori RGB a quello HSV
    if (spazio == 1)
        color = rgb2hsv(RGB);
    else
        color = RGB;
    end
    
end