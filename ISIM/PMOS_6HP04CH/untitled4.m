k = {};

for i = 100:100:4000
    setDAC0(i);
    k{end+1} = simulate(pathsNconsts,simulationVariables);
end

k = cell2mat(k);
