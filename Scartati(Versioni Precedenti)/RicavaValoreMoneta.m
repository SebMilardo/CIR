function [valore] = RicavaValoreMoneta(AreaCM2)
    if(AreaCM2<=2.4) && (AreaCM2>1.8)
        valore=1;
    end
    if(AreaCM2<=2.9) && (AreaCM2>2.4)
        valore=2;
    end
    if(AreaCM2<=3.3) && (AreaCM2>2.9)
        valore=10;
    end
    if(AreaCM2<=3.7) && (AreaCM2>3.3)
        valore=5;
    end
    if(AreaCM2<=4.0) && (AreaCM2>3.7)
        valore=20;
    end
    if(AreaCM2<=4.4) && (AreaCM2>4.0)
        valore=100;
    end
    if(AreaCM2<=4.9) && (AreaCM2>4.4)
        valore=50;
    end
    if(AreaCM2<=5.4) && (AreaCM2>4.9)
        valore=200;    
    end
end