function indiceMinimo = TrovaCorrispondenza(AreaCM2,H,S)
    % Nota: il valore della Tonalità(Hue) e della Saturazione(Saturation)
    % sono stati moltiplicati per due in modo da far pesare maggiormente
    % la differenza di colore tra una moneta e un'altra rispetto ai valori
    % delle aree.
    pesoArea=2;
    pesoH=1;
    pesoS=0.1;

    Descrittore=[AreaCM2*pesoArea H*pesoH S*pesoS];

    % Trovo il minimo come distanza euclidea tra tutte le monete

    indiceMinimo=1;
    % IMPORTANTE: la funzione Moneta è così strutturata
    % descrittore=Moneta(idMoneta,pesoArea,pesoHS)
    minore=norm(Descrittore-Moneta(1,pesoArea,pesoH,pesoS));
    i=2;
    while i<=8
        m_temp=norm(Descrittore-Moneta(i,pesoArea,pesoH,pesoS));
        if m_temp<minore
            minore=m_temp;
            indiceMinimo=i;
        end
        i=i+1;
    end

end

