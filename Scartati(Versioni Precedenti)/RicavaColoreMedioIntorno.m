function [HSV]=RicavaColoreMedioIntorno(I,mc,index)
    if index<1 || mod(index,2)==0
        err = MException('ResultChk:IndexNonValido', 'Indice deve essere un valore positivo dispari');
        throw(err)
    end
    i=1;
    j=1;
    k=index*index; % regola l'area in pixel del quadrato da cui si calcoler� la media dei
    % colori RGB
    emptyV1 = zeros(1, k);
    emptyV2 = zeros(1, k);
    Red=emptyV2'*emptyV1;
    Green=emptyV2'*emptyV1;
    Blue=emptyV2'*emptyV1;
    while i<=k;
        while j<=k;
            c = improfile(I,mc(1)+(-1)*(k-1)/2+i,mc(2)+(-1)*(k-1)/2+j);
            Red(i,j)=c(:,:,1);
            Green(i,j)=c(:,:,2);
            Blue(i,j)=c(:,:,3);
            j=j+1;
        end
        j=1;
        i=i+1;
    end
    RMedio=mean(mean((Red)));
    GMedio=mean(mean((Green)));
    BMedio=mean(mean((Blue)));

    RGB=[RMedio GMedio BMedio];
    HSV=rgb2hsv(RGB);
end