function estrai_foglio()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

vidobj = videoinput('winvideo');
triggerconfig(vidobj, 'manual');
start(vidobj);
for i = 1:100
    snapshot = getsnapshot(vidobj);
end
stop(vidobj);

%--------------------------------------------------------------------------


f = snapshot;
%imshow(f);
%CORREGGE L'ERRORE PROSPETTICO 
   %%
    Wy = 288; % Risoluzione WebCam in ingresso
    Wx = 352;
    
    Fx = 352; % Dimensioni in pixel del foglio (<= risoluzione della Webcam)
    Fy = 180;

    
   %% 
try
    B = f;
    J = f;
    figure;
    subplot(4,6,[1 2 7 8]), imshow(f), axis on;
    
    level = graythresh(J);
    bw = im2bw(J,level);
    bw = imfill(bw,'holes');
    bw = bwareaopen(bw, ((Wx*Wy)/16));
    cc = bwconncomp(bw, 8);
    paper = false(size(bw));
    paper(cc.PixelIdxList{1}) = true;
    BW = edge(paper);
    se = strel('square',3);
    BW = imdilate(BW,se);
    [H,T,R] = hough(BW);   
    subplot(4,6,[3 4 9 10]), imshow(imadjust(mat2gray(H))), axis on;
    colormap(bone);
    hold on;
    P = houghpeaks(H, 4, 'Threshold', 0, 'NhoodSize', [51 21]);
    plot(P(:,2),P(:,1),'s','color','white');
    hold off
    lines = houghlines(BW,T,R,P,'FillGap',20,'MinLength',40);
    subplot(4,6,[5 6 11 12]), imshow(f), axis on;
    hold on
if (length(lines) == 4 )
        rette = [];

        for k = 1:length(lines)

           xy = [lines(k).point1; lines(k).point2];
           ab = polyfit(xy(:,1), xy(:,2), 1);
           plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
           rette = [rette ; ab];

        end
        
        
        
        vertici = [];
        
        for k = 1:4
            for j = 1:4
                if (j<k) 
                trovato = 0;
                inter_x = -(rette(k,2)- rette(j,2))/(rette(k,1)- rette(j,1));
                inter_y = (inter_x * rette(k,1))+(rette(k,2));
                    if (inter_x>-100)&& (inter_x<(Wx+100)) && (inter_y>-100) && (inter_y<(Wy+100)) && (inter_y ~= NaN) && (inter_x ~= NaN)
                            plot(inter_x,inter_y,'x','LineWidth',2,'Color','yellow')
                            vertici = [vertici; inter_x,inter_y];
                    end
                end
            end
        end
        
        if (length(vertici) == 4)
          
            min_x = min(vertici(:,1));
            max_x = max(vertici(:,1));
            larghezza = max_x-min_x;

            min_y = min(vertici(:,2));
            max_y = max(vertici(:,2));
            altezza = max_y-min_y;

            B = imcrop(B,[min_x min_y larghezza altezza]);
            
            
            for k = 1:4
                vertici(k,1) = vertici(k,1) - min_x;
                vertici(k,2) = vertici(k,2) - min_y;
            end      
            
            
            tform = maketform('projective',vertici,[ 0 0; 0 Fy ; Fx 0 ; Fx Fy]);
            B = imtransform(B, tform, 'bicubic','fill', 0,'XData',[0 Fx],'YData',[0 Fy],'XYScale',1);
            
            B = imcrop(B, [0 0 Fx Fy]);
            By = size(B,1);
            Bx = size(B,2);
            Cy = uint8(zeros(Wy-By,Bx,3));
            
            subplot(4,6,[13 14 19 20]), imshow(B), axis on; 
            
            %%
            %controllo sul flip???
            
            ok = 0;
            
            %%
            NO = imcrop(B, [round(Fx/30),... 
                            round(Fy/15),... 
                            round(Fy/10),...
                            round(Fy/10)]);
                        
            
            bwNO = im2bw(NO);
            bwNO = imcomplement(bwNO);
            punto = bwconncomp(bwNO, 8);
            if punto.NumObjects >= 1;
                B = flipdim(B,1);
                ok = 1;
            end    
            subplot(4,6,15), imshow(bwNO), axis on;
            %%
            if ok == 0;
            NE = imcrop(B, [Fx - round(Fx/30) - round(Fy/10),...
                            round(Fy/15),...
                            round(Fy/10),...
                            round(Fy/10)]);
                        
            
            bwNE = im2bw(NE);
            bwNE = imcomplement(bwNE);
            punto = bwconncomp(bwNE, 8);
            if punto.NumObjects >= 1;
                B = imrotate(B,-180);
                ok = 1;
            end 
            subplot(4,6,16), imshow(bwNE), axis on;
            end
            %%
            if ok == 0;
            SO = imcrop(B, [Fx - round(Fx/30) - round(Fy/10),...
                            Fy - round(Fy/15) - round(Fy/10),...
                            round(Fy/10),...
                            round(Fy/10)]);
                        
            
            bwSO = im2bw(SO);
            bwSO = imcomplement(bwSO);
            punto = bwconncomp(bwSO, 8);
            if punto.NumObjects >= 1;
                B = flipdim(B,2);
            end 
            subplot(4,6,22), imshow(bwSO), axis on;
            end
            
            %%
            
            
            B = cat(1,B,Cy);
               
            
            
            
        end
        
end
catch 
    B = f;
    subplot(4,6,[17 18 23 24]), imshow(B), axis on;   
      
end

subplot(4,6,[17 18 23 24]), imshow(B), axis on;
end

