


function estrai_foglio2(block)
  setup(block);
%endfunction

function setup(block)
  
  block.NumDialogPrms = 1;
  block.DialogPrmsTunable = {'Tunable'};
  block.AllowSignalsWithMoreThan2D = true;
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 2;
  
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
  
  block.InputPort(1).DatatypeID   = 3;
  block.InputPort(1).Dimensions   = [1024 1280 3]; %per cambiare risoluzione...
  block.InputPort(1).Complexity   = 'Real';
  block.InputPort(1).SamplingMode = 'Sample';
  block.InputPort(1).Overwritable = false; % No in-place operation
  
  block.OutputPort(1).DatatypeID   = 3;
  block.OutputPort(1).Dimensions   = [905 1280 3]; %per cambiare risoluzione...
  block.OutputPort(1).Complexity   = 'Real';
  block.OutputPort(1).SamplingMode = 'Sample';
  
  block.OutputPort(2).DatatypeID   = 0;
  block.OutputPort(2).Dimensions   = 1; %per cambiare risoluzione...
  block.OutputPort(2).Complexity   = 'Real';
  block.OutputPort(2).SamplingMode = 'Sample';
  
   
  block.SimStateCompliance = 'DefaultSimState';

  block.RegBlockMethod('Outputs', @Output);
  block.RegBlockMethod('WriteRTW',@WriteRTW);

  block.SetAccelRunOnTLC(true);

%endfunction

  

  
%%
%% Block Output method: Perform Estrai Foglio
%%
function Output(block)
  dir = block.DialogPrm(1).Data;
  input = local_estrai_foglio(block.InputPort(1).Data, dir);
  block.OutputPort(1).Data = input.image;
  block.OutputPort(2).Data = input.status;
  
%endfunction

function WriteRTW(block)

  dir = sprintf('%d',block.DialogPrm(1).Data);
  
  block.WriteRTWParam('string', 'Direction', dir);

%endfunction

function input = local_estrai_foglio(f, dir)

%CORREGGE L'ERRORE PROSPETTICO 
   %%
    Wy = 1024; % Risoluzione WebCam in ingresso
    Wx = 1280;
    
    
    Fx = Wx; % Dimensioni in pixel del foglio (<= risoluzione della Webcam)
    Fy = 905;

    Rx = round(Fx/30);  %bordi ricerca orientamento
    Ry = round(Fy/15);
    
    Z = round(Fy/10); %dim. zona di ricerca
    
    
   %% 
   
  
     input = struct('image',imcrop(f, [0 0 Fx Fy]),'status',0);
    
try
    
    B = input.image; 
    J = f;
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
    P = houghpeaks(H, 4, 'Threshold', 0, 'NhoodSize', [51 21]);
    lines = houghlines(BW,T,R,P,'FillGap',20,'MinLength',40);
   
if (length(lines) == 4 )
        rette = [];

        for k = 1:length(lines)

           xy = [lines(k).point1; lines(k).point2];
           ab = polyfit(xy(:,1), xy(:,2), 1);
           %plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
           rette = [rette ; ab];

        end

        vertici = zeros(4,2);
        i = 0;
        for k = 1:4
            for j = 1:4
                if (j<k) 
                inter_x = -(rette(k,2)- rette(j,2))/(rette(k,1)- rette(j,1));
                inter_y = (inter_x * rette(k,1))+(rette(k,2));
                    if (inter_x>-100)&& (inter_x<(Wx+100)) && (inter_y>-100) && (inter_y<(Wy+100)) && (inter_y ~= NaN) && (inter_x ~= NaN) 
                        i = i + 1;    
                        vertici(i,1) = inter_x;
                        vertici(i,2) = inter_y;
                    end
                end
            end
        end
        
        if (i == 4)
          
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
            %By = size(B,1);
            %Bx = size(B,2);
            %Cy = uint8(zeros(Wy-By,Bx,3));
            
            %%
            ok = 0;
            
            
            %%
            NO = imcrop(B, [Rx,Ry,Z,Z]);
                        
            bwNO = im2bw(NO);
            bwNO = imcomplement(bwNO);
            punto = bwconncomp(bwNO, 8);
            if punto.NumObjects >= 1;
                B = flipdim(B,1);
                ok = 1;
            end    
            
            %%
            if ok == 0;
            NE = imcrop(B, [Fx - Rx - Z,Ry,Z,Z]);
                        
            bwNE = im2bw(NE);
            bwNE = imcomplement(bwNE);
            punto = bwconncomp(bwNE, 8);
            if punto.NumObjects >= 1;
                B = imrotate(B,-180);
                ok = 1;
            end 
            end
            %%
            if ok == 0;
            SE = imcrop(B, [Fx - Rx - Z,Fy - Ry - Z,Z,Z]);
                        
            bwSE = im2bw(SE);
            bwSE = imcomplement(bwSE);
            punto = bwconncomp(bwSE, 8);
            if punto.NumObjects >= 1;
                B = flipdim(B,2);
                ok =1;
            end 
            end
            %%
            if ok == 0;
            SO = imcrop(B, [Rx, Fy - Ry - Z,Z,Z]);
                        
            bwSO = im2bw(SO);
            bwSO = imcomplement(bwSO);
            punto = bwconncomp(bwSO, 8);
            if punto.NumObjects >= 1;
                ok = 1;
            end 
            end            
                        
            %B = cat(1,B,Cy);
            input.image = B;
            input.status = ok;
        end  
end
 
   

catch
    input.status = 0;
end 
%endfunction

