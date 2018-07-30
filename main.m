function main(Origine,CalibrationLock,SaveMode,DebugMode)
                      
%Origine                % Tipo String. Origine delle immagini. 
                        % '0' -> Webcam
                        % 'Percorso/immagine.jpg ' -> File
                        
%CalibrationLock        % Rende insensibile ai fogli di calibrazione
                        % 0 -> off 1 -> On
                        
%SaveMode               % Come vengono aggiornati i valori di riferimento
                        % 0 -> ripristina i default
                        % 1 -> sostituisce i valori
                        % 2 -> media con il precedente set

%DebugMode              % Abilita la generazione di output intermedi
                        % 0 -> off 1 -> On
                        
Input = RicavaFoglio(Origine,DebugMode);  
% Input contiene due campi: image con il foglio corretto e status che
% indica se la ricerca di un foglio e' andata a buon fine
% 1 -> foglio trovato, 0 -> foglio non trovato

    if (Input.status == 1)
        % Se ho trovato un foglio
        if (Input.tipo == 1) && (CalibrationLock ==0)
           % Determino il tipo di foglio e se sono abilitato effetto la calibrazione 
           text(40,120,'Calibrazione...','Color',[1 1 1],'FontWeight','bold','FontSize',20,'BackgroundColor',[0 0 0]);
           drawnow;
           Calibrazione(Input.image,SaveMode,0); 
        end
           % In ogni caso effettuo l'analisi del foglio
           Analisi(Input.image,DebugMode);     
    else
           % Se non ho trovato alcun foglio scrivo un messaggio di errore 
           text(40,40,'    Nessun foglio    ','Color',[1 1 1],'FontWeight','bold','FontSize',20,'BackgroundColor',[0 0 0]);

    end

end
