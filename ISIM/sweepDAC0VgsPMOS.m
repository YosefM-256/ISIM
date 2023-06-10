function results = sweepDAC0VgsPMOS(VgsList,DAC0set,pathsNconsts,simulationVariables)
    arguments
        VgsList                 double      {mustBePositive}
        DAC0set                 double      {mustBeNonempty, mustBePositive}
        pathsNconsts            struct
        simulationVariables     struct
    end
    assert(issorted(VgsList), "The Vgs set must be in ascending order");

    informProgress("Starting DAC0 sweep for fixed values of Vgs for PMOS");
    addProgressIndent();

    setBRes(1);
    setCRes(2);
    results = {};
    
    for Vgs=VgsList
        result = struct();
        [VgsResult,msg] = IdVds(Vgs,DAC0set,pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            informLog(['abandoning Vgs plot with Vgs=' num2str(VgsList) '. A TOP BREACH occured']);
            informProgress(['DAC0 sweep for Vgs=' num2str(VgsList) ' was abandoned'])
            results = cell2mat(results);
            return;
        end
        result.data = VgsResult;
        result.Vgs = Vgs;
        results{end+1} = result;
    end

    removeProgressIndent();
    results = cell2mat(results);
end

function [VgsResult, msg] = IdVds(Vgs,DAC0set,pathsNconsts,simulationVariables)
    informLog(["** starting PMOS DAC0 sweep for Vgs=" num2str(Vgs) " **"]);

    setBRes(1);
    setCRes(2);

    setDAC1(0);
    findInitialDAC0;
    DAC0set = cutDAC0set(DAC0set);

    VgsResult = {};
    msg = "SUCCESS";

    for i=DAC0set
        setDAC0(i);
        msg = tuneBy("Vcb","DAC1",Vgs,"inverse",pathsNconsts,simulationVariables);
        if msg ~= "SUCCESS"
            VgsResult = 0;
            return;
        end
        VgsResult{end+1} = simulate(pathsNconsts,simulationVariables);
    end
    informProgress(["finished DAC0 sweep for Vgs=" num2str(Vgs)])
    VgsResult = cell2mat(VgsResult);

    function findInitialDAC0
        msg = tuneBy("Vcb","DAC0",Vgs,"direct",pathsNconsts,simulationVariables);
    end
end

function DAC0set = cutDAC0set(DAC0set)
    arguments
        DAC0set                 double      {mustBeNonempty, mustBePositive}
    end
    global DAC0;
    minIndex = find(DAC0set > DAC0);
    informLog(['the DAC0set will start from ' num2str(DAC0set(minIndex(1)))]);
    DAC0set = DAC0set(minIndex:end);
end