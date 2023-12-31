function results = plothfeIc(Vce,Icset,VceTopBreachAction,pathsNconsts,simulationVariables)
    arguments
        Vce                     double      {mustBeInRange(Vce,0,10)}
        Icset                   double      {mustBeNonempty, mustBePositive}
        VceTopBreachAction      string      {mustBeMember(VceTopBreachAction,["error", "return", "notice"])}
        pathsNconsts            struct
        simulationVariables     struct
    end
    Ibset = Icset/10;
    
    informLog(["starting [hfe - Ic](NPN) graph for Vce=" num2str(Vce)]);
    results = {};
    setCRes(0);
    setBRes(0);
    BResNum = 0;
    CResNum = 0;
    setDAC0(4095);
    
    for ib=Ibset
        Ibmsg = tuneToIb(ib);
        if Ibmsg ~= "SUCCESS"
            error("TOP BREACH occured while tuning Ib to %d",ib);
        end
        Vcmsg = tuneToVce();
        if Vcmsg ~= "SUCCESS"
            if VceTopBreachAction == "error"
                informLog("FATAL ERROR: TOP BREACH occured while tuning Vce in [hfe - Ic](NPN) plot");
                informLog("***");
                informProgress("[hfe - Ic](NPN) graph could not finish. Simulation stopped");
                error("TOP BREACH occured while tuning Vce to %d",Vce);
            end
            if VceTopBreachAction == "return"
                results = cell2mat(results);
                informLog("ERROR: [hfe - Ic](NPN) plot was ended prematurely because a TOP BREACH occured" + ...
                    "while tuning Vce. The program will continue to run");
                informProgress("[hfe - Ic](NPN) successufully finished");
                return;
            end
            if VceTopBreachAction == "notice"
                results = cell2mat(results);
                informLog("ERROR: [hfe - Ic](NPN) plot was ended prematurely because a TOP BREACH occured" + ...
                    "while tuning Vce. The program will continue to run");
                informLog("the option VceTopBreachAction=notice is not defined yet");
                return;
            end
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    informProgress("[hfe - Ic](NPN) graph successufully finished");
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

    function result = tuneToVce()
        result = "SUCCESS";
        msg = tuneBy("Vc","DAC0",Vce,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && CResNum < 2
            informLog(['TOP BREACH occured while trying to tune DAC0 for Vc=' num2str(Vce) ...
                '.Switching to Rc=' num2str(10^(2-CResNum)) 'Ohm']);
            setCRes(CResNum + 1);
            CResNum = CResNum + 1;
            msg = tuneToVce();
        end
        if msg == "TOP BREACH" && CResNum == 2
            informLog(['the TOP BREACH for Vc=' num2str(Vce) ' repeated when Rc=10 Ohm']);
            result = "TOP BREACH";
            return;
        end
    end
end
