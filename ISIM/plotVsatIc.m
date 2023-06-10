function results = plotVsatIc(beta,Icset,pathsNconsts,simulationVariables)
    arguments                             
        beta                    double      {mustBePositive}
        Icset                   double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    Ibset = Icset/beta;

    informLog(["starting [Vsat - Ic](NPN) graph for beta=" num2str(beta)]);

    results = {};
    setCRes(0);
    setBRes(0);
    BResNum = 0;
    CResNum = 0;
    setDAC0(4095);

    for ib = Ibset
        Ibmsg = tuneToIb(ib);
        if Ibmsg ~= "SUCCESS"
            error("TOP BREACH occured while tuning Ib to %d",ib);
        end
        betamsg = tuneToBeta();
        if betamsg ~= "SUCCESS"
            error("TOP BREACH occured while tuning beta to %d",beta);
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    informProgress("[Vsat - Ic](NPN) graph successufully finished");
    results = cell2mat(results);
    
    function result = tuneToIb(ib)
        result = "SUCCESS";
        msg = tuneBy("Ib","DAC1",ib,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && BResNum == 0
            informLog(['TOP BREACH occured while trying to tune DAC1 for Ib=' num2str(ib) ...
                '.Switching to Rb=100 Ohm']);
            setBRes(1);
            BResNum = 1;
            msg = tuneToIb(ib);
        end
        if msg == "TOP BREACH" && BResNum == 1
            informLog(['the TOP BREACH for Ib=' num2str(ib) ' repeated when Rb=100 Ohm']);
            result = "TOP BREACH";
            return;
        end
    end
        
    function result = tuneToBeta
        result = "SUCCESS";
        msg = tuneBy("beta","DAC0",beta,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && CResNum < 2
            informLog(['TOP BREACH occured while trying to tune DAC0 for beta=' num2str(beta) ...
                '.Switching to Rc=' num2str(10^(2-CResNum)) 'Ohm']);
            setCRes(CResNum + 1);
            CResNum = CResNum + 1;
            msg = tuneToBeta();
        end
        if msg == "TOP BREACH" && CResNum == 2
            informLog(['the TOP BREACH for beta=' num2str(beta) ' repeated when Rc=10 Ohm']);
            result = "TOP BREACH";
            return;
        end
    end
end