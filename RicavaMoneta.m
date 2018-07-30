function [datimoneta NroOggetti] = RicavaMoneta(I,DebugMode)
    
    IBN = rgb2gray(I);   
    level = graythresh(IBN);
    IBN = im2bw(IBN,level);
    IBNn = imcomplement(IBN);
    BWdfill = imfill(IBNn, 'holes');
    background = imopen(BWdfill,strel('disk',100));
    BWdfill = BWdfill - background;
    BWnobord = imclearborder(BWdfill, 4);
    %bwareaopen rimuove gli oggetti connessi che hanno meno di tot pixel
    BWfinal = bwareaopen(BWnobord, 1100, 4); 
    
    
    if(DebugMode==1)
       figure; 
       subplot(2,3,1), imshow(I);       title('Foglio corretto');
       subplot(2,3,2), imshow(IBN),     title('Bianco e Nero');
       subplot(2,3,3), imshow(IBNn),    title('Complementare');
       subplot(2,3,4), imshow(BWdfill),  title('Buchi riempiti');
       subplot(2,3,5), imshow(BWnobord), title('Bordi ripuliti');
       subplot(2,3,6), imshow(BWfinal),  title('Punti eliminati');
    end
        
    BWoutline = bwperim(BWfinal);
    Segout = I;
    Segout(BWoutline) = 255;
    %figure, 
    imshow(Segout);%, title('Immagine finale');
    
    cc = bwconncomp(BWfinal, 8); 
    NroOggetti=cc.NumObjects;

    datimonetaTemp = regionprops(cc,'Centroid','MinorAxisLength','MajorAxisLength','BoundingBox');
    datimoneta = [];
    for k = 1:NroOggetti
            area = (round((datimonetaTemp(k).MinorAxisLength/2)^2)*3.14);
            datimoneta = [datimoneta ; struct('Area',area,'Centroid',datimonetaTemp(k).Centroid,'Valore',0,'BoundingBox',datimonetaTemp(k).BoundingBox)];
    end
end