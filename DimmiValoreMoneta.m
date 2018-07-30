function [Tipo] = DimmiValoreMoneta(id)
%Analogo a dimmi valore moneta ma ritorna interi 
%serve a calcolare la somma di tutte le monete
switch id
    case 1
        Tipo=0.01;
    case 2
        Tipo=0.02;
    case 3
        Tipo=0.05;
    case 4
        Tipo=0.10;
    case 5
        Tipo=0.20;
    case 6
        Tipo=0.50;
    case 7
        Tipo=1;
    case 8
        Tipo=2;
end
