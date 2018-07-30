%
%       
%            _____         _               _____ ___________ 
%           |_   _|       (_)             /  __ \_   _| ___ \
%             | | ___  ___ _ _ __   __ _  | /  \/ | | | |_/ /
%             | |/ _ \/ __| | '_ \ / _` | | |     | | |    / 
%             | |  __/\__ \ | | | | (_| | | \__/\_| |_| |\ \ 
%             \_/\___||___/_|_| |_|\__,_|  \____/\___/\_| \_|
%            
%  
% Progettare e simulare un sistema di riconoscimento immagini per 
% riconoscere posizione e tipo di una moneta posta su un Foglio A4. 
% Ipotizzare la telecamera posta in una posizione arbitraria rispetto 
% al foglio ed implementare una opportuna procedura d� calibrazione.
%               
%       by:  Alex Nicosia
%            Carmelo Porcelli
%            Daniele Saitta
%            Ivan Tiziano
%            Sebastiano Milardo
%
%--------------------------------------------------------------------------



function visioneCIR()

%Creo le variabili da passare al main.
CalibrationLock=0;  %due
SaveMode=0;         %tre
Debug=0;            %due
fullpath='0';       %contiene il path del file da analizzare. Se � 0, non � stato rilevato alcun path (se si preme cancel nella dialogbox).
nowebcam = 0;       %nessuna webcam collegata
    
% Creiamo la finestra, impostando l'assenza di Toolbar, MenuBar e del NumberTitle 
% (l'apertura di nuove finestre non le far� diventare numerate).
% Impostiamo con Name il nome desiderato, impostiamo la dimensione della
% finestra e togliamo il Resize per evitare problemi sulla posizione degli elementi grafici durante l'esecuzione.
hFig = figure('Toolbar','none','Menubar', 'none','NumberTitle','Off','Name','visioneCIR','units','pixels','position',[100 50 775 480],'Resize','off');

% Introduciamo i Bottoni impostando testo visualizzato, callback associati,
% dimensioni del bottone e posizione dello stesso nella finestra grafica

uicontrol(hFig,'String', 'Rileva Monete','Callback',@rileva_button,'Units','normalized','Position',[0.838 0.82 .15 .05]);
uicontrol(hFig,'String', 'Apri File','Callback',@aprifile_button,'Units','normalized','Position',[0.838 0.77 .15 .05]);
uicontrol(hFig,'String', 'About','Callback',@about_button,'Units','normalized','Position',[0.838 0.72 .15 .05]);
uicontrol(hFig,'String', 'Esci','Callback', 'close(gcf)','Units','normalized','Position',[0.838 0.02 .14 .05]);

h1 = uibuttongroup('visible','off','Position',[0.838 0.5 .15 0.20],'Title','Save Mode','TitlePosition','centertop');
% Creiamo tre radio button nel gruppo di bottoni precedentemente creato. Il
% gruppo serve per gestire i radio button.
u0 = uicontrol(h1,'Style','Radio','String','Default','Tag','Default','pos',[10 5 65 15],'HandleVisibility','off');
u1 = uicontrol(h1,'Style','Radio','String','Sostituisce','Tag','Sostituisce','pos',[10 35 75 15],'HandleVisibility','off');
u2 = uicontrol(h1,'Style','Radio','String','Media','Tag','Media','pos',[10 65 65 15],'HandleVisibility','off');
% Inizializziamo alcune propriet�
set(h1,'SelectionChangeFcn',@uibuttongroup1_SelectionChangeFcn); %impostiamo il callback per la nostra funzione.
set(h1,'SelectedObject',u0);  % Come scelta selezionata mette u0
set(h1,'Visible','on');

h2 = uibuttongroup('visible','off','Position',[0.838 0.3 .15 0.15],'Title','Calibration Lock','TitlePosition','centertop');
u0 = uicontrol(h2,'Style','Radio','String','On','Tag','On','pos',[10 5 65 15],'HandleVisibility','off');
u1 = uicontrol(h2,'Style','Radio','String','Off','Tag','Off','pos',[10 35 65 15],'HandleVisibility','off');
set(h2,'SelectionChangeFcn',@uibuttongroup2_SelectionChangeFcn); 
set(h2,'SelectedObject',u1);
set(h2,'Visible','on');


h3 = uibuttongroup('visible','off','Position',[0.838 0.1 .15 0.15],'Title','Debug Mode','TitlePosition','centertop');
u0 = uicontrol(h3,'Style','Radio','String','On','Tag','On','pos',[10 5 65 15],'HandleVisibility','off');
u1 = uicontrol(h3,'Style','Radio','String','Off','Tag','Off','pos',[10 35 65 15],'HandleVisibility','off');
set(h3,'SelectionChangeFcn',@uibuttongroup3_SelectionChangeFcn);
set(h3,'SelectedObject',u1); 
set(h3,'Visible','on');

% Creiamo l'oggetto di input video.
try
    vid = videoinput('winvideo', 1, 'YUY2_1280x1024'); %<---- IMPOSTARE I PARAMETRI DELLA PROPRIA WEBCAM: vedi imaqtool
    msgbox('Webcam winvideo-1 rilevata: 1280x1024','Visione Artificiale','help');
    vidRes = get(vid, 'VideoResolution');
    nBands = get(vid, 'NumberOfBands');
%Impostiamo il colore dell'oggetto video come RGB
    vid.ReturnedColorspace = 'rgb';
    uicontrol(hFig,'String', 'Acquisisci','Callback', @acquisisci_button,'Units','normalized','Position',[0.838 0.92 .15 .05]);
    uicontrol(hFig,'String', 'Stop','Callback',@stop_button,'Units','normalized','Position',[0.838 0.87 .15 .05]);
catch ME
    msgbox('Nessuna webcam collegata: verificare configurazione','Visione Artificiale','help');
    nowebcam = 1;
    uicontrol(hFig,'String', 'Acquisisci','Callback', @acquisisci_button,'Units','normalized','Position',[0.838 0.92 .15 .05],'Enable','off');
    uicontrol(hFig,'String', 'Stop','Callback',@stop_button,'Units','normalized','Position',[0.838 0.87 .15 .05], 'Enable','off');
    
end

% Creiamo l'oggetto immagine in cui vogliamo visualizzare dalla webcam,
% acquisendo in due variabili altezza e larghezza dell'immagine. Per
% impostare come nera l'immagine iniziale, utilizziamo una matrice di tutti
% zero con dimensione altezza, larghezza e nBands (Sarebbero il numero
% delle bande di colori utilizzate nell'immagine che vogliamo acquisire).
imWidth = 640;
imHeight = 480;

%Specifichiamo le dimensioni degli assi dell'oggetto immagine cosi che 
%l'immagine possa essere visualizzata alla giusta risoluzione e al centro
%della finestra immagine.

figSize = get(hFig,'Position');
figWidth = figSize(3);
figHeight = figSize(4);
set(gca,'unit','pixels','position',[ 0 0 imWidth imHeight ],'XTickLabel',{},'YTickLabel',{});
imshow('Foto/VisioneCIR.jpg');
text(40,40,'Benvenuto','Color',[1 1 1],'FontWeight','bold','FontSize',20);

%Creiamo le due funzioni acquisisci e stop, che cominceranno e fermeranno
%l'acquisizione da webcam.
    function acquisisci_button(hObject,eventdata) 
        fullpath = '0';
        set(gca,'unit','pixels','position',[ 0  0 imWidth imHeight ],'XTickLabel',{},'YTickLabel',{});
        hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
        drawnow;
        preview(vid,hImage);
    end
    function stop_button(hObject,eventdata)
        stoppreview(vid);
    end
    function rileva_button(hObject,eventdata)
        if (nowebcam==0)
        stoppreview(vid);
        end
        imHeight2 = round(imWidth*210/291);
        text(40,40,'Elaborazione...','Color',[1 1 1],'FontWeight','bold','FontSize',20,'BackgroundColor',[0 0 0]);
        drawnow;
        
        %main('0',1,0,0); %<-- la stringa ufficiale
        main(fullpath,CalibrationLock,SaveMode,Debug) 
        %set(gca,'unit','pixels','position',[ 0 0 imWidth imHeight2 ],'XTickLabel',{},'YTickLabel',{});
        drawnow;
    end
    function about_button(hObject,eventdata)
        intestazione=sprintf('Riconoscimento delle monete!\n\nUn programma di:\nNicosia Alex\nPorcelli Carmelo\nSaitta Daniele\nTiziano Ivan\nMilardo Sebastiano');
        msgbox(intestazione,'Visione Artificiale','help');
    end
    %la funzione aprifile_button permette di selezionare il un file
    %restituendo il pathname di questo o lo 0 se se premi Cancel.
    function aprifile_button(hObject,eventdata)
        if (nowebcam==0)
        stoppreview(vid);
        end
        [FileName,PathName] = uigetfile('*.jpg','Select the MATLAB code file');
        if FileName==0
            fullpath='0';
        else
            fullpath=sprintf('%s%s',PathName,FileName);
            set(gca,'unit','pixels','position',[ 0  0 imWidth imHeight ],'XTickLabel',{},'YTickLabel',{});
            imshow(fullpath);
        end
        
    end

    function uibuttongroup1_SelectionChangeFcn(hObject,eventdata)
        switch get(eventdata.NewValue,'Tag') % Prende il testo dell'oggetto selezionato.
            case 'Default'
                SaveMode=0;
            case 'Sostituisce'
                SaveMode=1;
            case 'Media'
                SaveMode=2;
            otherwise
                % Codice se non si ha corrispondenza.
        end
    end

    function uibuttongroup2_SelectionChangeFcn(hObject,eventdata)
        switch get(eventdata.NewValue,'Tag') % Prende il testo dell'oggetto selezionato.
            case 'Off'
                CalibrationLock=0;
            case 'On'
                CalibrationLock=1;
            otherwise
                % Codice se non si ha corrispondenza.
        end
    end

    function uibuttongroup3_SelectionChangeFcn(hObject,eventdata)
        switch get(eventdata.NewValue,'Tag') % Prende il testo dell'oggetto selezionato.
            case 'Off'
                Debug=0;
            case 'On'
                Debug=1;
            otherwise
                % Codice se non si ha corrispondenza.
        end
    end

    
end





