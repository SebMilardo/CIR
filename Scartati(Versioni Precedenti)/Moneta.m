function [res] = Moneta(Valore,w1,w2,w3)
    res=0;
    H=0;
    S=0;
    switch Valore
        case 1 % 1 centesimo
            Area=2.07;
            HS=[0.06  0.8598];
        case 2 % 2 centesimi
            Area=2.76;
            HS=[0.06  0.8598];
        case 3 % 5 centesimi
            Area=3.55;
            HS=[0.06  0.8598];
        case 4 % 10 centesimi
            Area=3.06;
            HS=[0.1243 0.7729];
        case 5 % 20 centesimi
            Area=3.89;
            HS=[0.1243 0.7729];
        case 6 % 50 centesimi
            Area=4.62;
            HS=[0.1243 0.7729];
        case 7 % 1 euro
            Area=4.25;
            HS=[0.3953 0.1249];
        case 8 % 2 euro
            Area=5.21;
            HS=[0.1088  0.8026];
        otherwise
            Area=0;
            HS=[0 0];
    end
    H=HS(1);
    S=HS(2);
    res=[Area*w1 H*w2 S*w3];
end