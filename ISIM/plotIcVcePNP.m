function results = plotIcVcePNP(Ibs,DAC0set,pathsNconsts,simulationVariables)
    arguments
        Ibs                     double      {mustBeNonempty, mustBeNegative}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(Ibs,"descend"),"The 'Ibs' argument must be in ascending order");
    
    informLog("starting [Ic - Vce](PNP) graph");
    informProgress("starting [Ic - Vce](PNP) plot");
    addProgressIndent;

    results = {};
    for Ib = Ibs
        informLog(['starting plot for Ib=' num2str(Ib)]);
        result = struct();
        [IbResult, msg] = IcVce(Ib,DAC0set,pathsNconsts,simulationVariables);
        if msg == "TOP BREACH"
            informLog(['abandoning Ib plot with Ib=' num2str(Ib) '. A TOP BREACH occured']);
            return;
        end
        result.data = IbResult;
        result.Ib = Ib;
        results{end+1} = result;
    end
    results = cell2mat(results);
    removeProgressIndent;

end

function [results,msg] = IcVce(Ib,DAC0set,pathsNconsts,simulationVariables)
    arguments 
        Ib                      double      {mustBeNegative}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    BResNum = 1;
    CResNum = 2;
    setBRes(BResNum);
    setCRes(CResNum);
    setDAC1(0);
    findInitialDAC0();
    DAC0set = cutDAC0set(DAC0set);

    results = {}; 
    for i=DAC0set
        setDAC0(i);
        msg = tuneBy("Ib","DAC1",Ib,"direct",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && BResNum == 1
            informLog(['TOP BREACH occured while trying to tune DAC1 for Ib=' num2str(Ib) '.Switching to Rb=1k Ohm']);
            setBRes(0);
            BResNum = 0;
            msg = tuneBy("Ib","DAC1",Ib,"direct",pathsNconsts,simulationVariables);
        end
        if msg == "TOP BREACH" && BResNum == 0
            informLog(['the TOP BREACH for Ib=' num2str(Ib) ' repeated when Rb=1k Ohm']);
            results = "TOP BREACH";
            return;
        end
        results{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    results = cell2mat(results);
    informProgress(['[Ic - Vce](PNP) plot completed for Ib=' num2str(Ib)]);

    function findInitialDAC0()
        setCRes(CResNum);
        msg = tuneBy("Ib","DAC0",Ib,"inverse",pathsNconsts,simulationVariables);
        if msg == "TOP BREACH" && CResNum < 2
            CResNum = CResNum + 1;
            findInitialDAC0();
        end
    end
end

function DAC0set = cutDAC0set(DAC0set)
    arguments
        DAC0set                 double      {mustBeNonempty, mustBePositive}
    end
    global DAC0;
    minIndex = find(DAC0set > DAC0);
    informLog(['the DACset will start from ' num2str(DAC0set(minIndex(1)))]);
    DAC0set = DAC0set(minIndex:end);
end