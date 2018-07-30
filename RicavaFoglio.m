function input = RicavaFoglio(Origine,DebugMode)

% Variabili di sistema    

tentativi = 0;  
status = 0;
    
% Dimensioni immagini in ingresso    

Wy = 1024; % Altezza   
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

% Margine oltre il quale continuo a cercare i vertici
% serve a trovare eventuali vertici del foglio non
% inquadrati nell'immagine
M = 200;
M2 = M*2;

while (status == 0) && (tentativi < 3) % prova 3 volte prima di lanciare un errore    
    try
        tentativi = tentativi +1;
        if (strcmp(Origine,'0'))                       % scelta tipo di input
            vidobj = videoinput('winvideo',1);         % Webcam
            triggerconfig(vidobj, 'manual');
            vidobj.ReturnedColorspace = 'rgb';
            start(vidobj);
            snapshot = getsnapshot(vidobj);
            stop(vidobj);

            f = snapshot;
        else
            f = imread(Origine);            % File
        end

        B = f; 
        input = struct('image',imcrop(f, [0 0 Fx Fy]),'status',status,'tipo',0);   
        J = f;
        level = graythresh(J);
        bw1 = im2bw(J,level);                   % Converto in Bianco e Nero
        bw = imfill(bw1,'holes');               % Riempio i buchi nell'immagine
        bw = bwareaopen(bw, round((Wx*Wy)/16));
        cc = bwconncomp(bw, 8);                 % Ricerco le aree connesse
        numPixels = cellfun(@numel,cc.PixelIdxList);
        [biggest,idx] = max(numPixels);         
        paper = false(size(bw));
        paper(cc.PixelIdxList{idx}) = true;     % Seleziono quella con area max
        BW = edge(paper);                       % estraggo i contormi
        se = strel('square',3);                 % e li rafforzo
        BW = imdilate(BW,se);
        [H,T,R] = hough(BW);                    % trasformata di Hough 
        P = houghpeaks(H, 4, 'Threshold', 0, 'NhoodSize', [51 21]);
        % trovo i primi 4 picchi della trasformata di Hough... 
        lines = houghlines(BW,T,R,P,'FillGap',200,'MinLength',80);
        %...e scelgo altrettante rette

        % Output di Debug
        if(DebugMode==1)
        figure;
        subplot(4,6,[1 2 7 8]), imshow(f),title('Immagine iniziale');
        subplot(4,6,[3 4 9 10]), imshow(imadjust(mat2gray(H)),'XData',T,'YData',R),axis normal,title('T. Hough');
        colormap(bone);
        hold on;
        plot(T(P(:,2)),R(P(:,1)),'s','color','white');
        hold off
        subplot(4,6,[5 6 11 12]), imshow(f),title('Rette e vertici');
        hold on
        end



    if (length(lines) >= 4 )
            rette = [];

            % Interpolo i punti delle rette per ovviare a imprecisioni
            for k = 1:4

               xy = [lines(k).point1; lines(k).point2];

               % evito casi di stessa ascissa
               if (xy(1,1) == xy (2,1));
                  xy(1,1) = xy(1,1)+1; 
               end    

                % evito casi di stessa ordinata 
               if (xy(1,2) == xy (2,2));
                  xy(1,2) = xy(1,2)+1; 
               end    

               ab = polyfit(xy(:,1), xy(:,2), 1);
               if (DebugMode == 1)
                plot(xy(:,1),xy(:,2),'LineWidth',1,'Color','green');
               end
               rette = [rette ; ab];

            end
            
            % Trovo i vertici come intersezioni tra le rette
            vertici = zeros(4,2);
            i = 0;
            for k = 1:4
                for j = 1:4
                    if (j<k) 
                    inter_x = -(rette(k,2)- rette(j,2))/(rette(k,1)- rette(j,1));
                    inter_y = (inter_x * rette(k,1))+(rette(k,2));
                        if (inter_x>-M)&& (inter_x<(Wx+M)) && (inter_y>-M) && (inter_y<(Wy+M)) && (~isnan(inter_y)) && (~isnan(inter_x)) 
                            i = i + 1;
                            if(DebugMode==1)
                            plot(inter_x,inter_y,'x','LineWidth',2,'Color','yellow')
                            end
                            vertici(i,1) = inter_x;
                            vertici(i,2) = inter_y;
                        end
                    end
                end
            end

            % Se ho trovato 4 vertici ritaglio l'immagine ottenuta
            if (i == 4)
                
                min_x = min(vertici(:,1));
                min_x2 = 0;
                max_x = max(vertici(:,1));
                larghezza = max_x-min_x;

                min_y = min(vertici(:,2));
                min_y2 = 0;
                max_y = max(vertici(:,2));
                altezza = max_y-min_y;
                
                % Considero il caso in cui i vertici sono al di fuori del
                % foglio
                
                if (min_x < 0)
                    min_x2 = min_x;
                end
                if (min_y < 0)
                    min_y2 = min_y;
                end
                
                % Ritaglio l'immagine 
                B = imcrop(B,[min_x min_y larghezza altezza]);
                
                larghezza2 = size(B,2);
                altezza2 = size(B,1);            
                
                B = [255*ones(M,larghezza2+M2,3);[255*ones(altezza2,M,3) B 255*ones(altezza2,M,3)];255*ones(M,larghezza2+M2,3)];
                B = imcrop(B,[M+(min_x2) M+(min_y2) larghezza altezza]);
                
                for k = 1:4
                    vertici(k,1) = vertici(k,1) - min_x;
                    vertici(k,2) = vertici(k,2) - min_y;
                end      

            % Utilizzo una trasformazione prospettrica per rendere il foglio
            % rettangolare e adattarlo alle dimensioni desiderate in uscita
                tform = maketform('projective',vertici,[ 0 0; 0 Fy ; Fx 0 ; Fx Fy]);
                B = imtransform(B, tform, 'bicubic','fill', 255,'XData',[0 Fx],'YData',[0 Fy],'XYScale',1);
                bw1 = im2bw(B,level);
                B = imcrop(B, [0 0 Fx Fy]);
                bw1 = imcrop(bw1, [0 0 Fx Fy]);
                if(DebugMode==1)
                    subplot(4,6,[13 14 19 20]), imshow(B),title('Correzione Prospettiva');            
                end

            % ok indica se ho trovato o meno il quadrato di controllo    
                ok = 0;

            % Miglioro i contorni dell'immagine
                %H = fspecial('unsharp');
                %B = imfilter(B,H,'replicate');

            % Ricerca del quadrato di controllo ed effettuo correzioni se il quadrato non
            % � presente nel rettangolo di ricerca Sud - Ovest
                               
                result = AnalizzaAngolo(B,bw1,[Rx,Ry,Zx,Zy]);
                punto = result.punto;
                B = result.B;
                if punto.NumObjects >= 1;
                    B = flipdim(B,1);
                    ok = 1;
                end
                if(DebugMode==1)
                    subplot(4,6,15), imshow(result.angolo);
                end
                
                
                result = AnalizzaAngolo(B,bw1,[Fx - Rx - Zx,Ry,Zx,Zy]);
                B = result.B;
                if ok == 0;
                    punto = result.punto;
                    if punto.NumObjects >= 1;
                        B = imrotate(B,-180);
                        ok = 1;
                    end
                end    
                    if(DebugMode==1)
                        subplot(4,6,16), imshow(result.angolo);
                    end
                
                
                result = AnalizzaAngolo(B,bw1,[Fx - Rx - Zx,Fy - Ry - Zy,Zx,Zy]);
                B = result.B;
                if ok == 0;
                    punto = result.punto;
                    if punto.NumObjects >= 1;
                        B = flipdim(B,2);
                        ok =1;
                    end
                end    
                    if(DebugMode==1)
                        subplot(4,6,22), imshow(result.angolo);
                    end
               
                
                result = AnalizzaAngolo(B,bw1,[Rx, Fy - Ry - Zy,Zx,Zy]);
                B = result.B;
                
                if ok == 0;
                    punto = result.punto;
                    if punto.NumObjects >= 1;
                        ok = 1;
                    end
                end    
                    if(DebugMode==1)
                        subplot(4,6,21), imshow(result.angolo);
                    end
                            

            % Controllo se le correzioni prospettriche hanno alterato le proporzioni dell'immagine
            % confrontando le dimensioni del quadrato di controllo

                if (ok == 1) 
                    datiControllo = regionprops(punto,'MinorAxisLength','MajorAxisLength','Area');

                    if datiControllo(1).MajorAxisLength > datiControllo(1).MinorAxisLength*1.4
                        tform = maketform('projective',[ 0 0; 0 Fy ; Fx 0 ; Fx Fy],[ 0 Fy; Fx Fy ; 0 0 ; Fx 0]);
                        B = imtransform(B, tform, 'bicubic','fill', 255,'XData',[0 Fx],'YData',[0 Fy],'XYScale',1);
                        B = flipdim(B,2);

                    end    
                end

                % Aggiorno lo stato e ritorno l'immagine corretta
                
                if (punto.NumObjects == 2)
                    input.tipo = 1;
                else
                    input.tipo = 0;
                end
                input.image = B;
                status = ok;
                input.status = status;

            end  
    end
    if(DebugMode==1)
    subplot(4,6,[17 18 23 24]), imshow(input.image),title('Orientamento e colore'); 
    end
    catch ME
       ME 
       status = 0;
       input.status = status;
       if(DebugMode==1)
        subplot(4,6,[17 18 23 24]), imshow(input.image); 
       end
    end
end


