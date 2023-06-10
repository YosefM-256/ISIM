close all; clear all;
global DAC1 DAC0 BRes CRes;
DAC1 = 3600; DAC0 = 4095; BRes = 1; CRes = 2;
pathsNconsts = struct(  'simulationCommand',    'XVIIx64.exe -b -ascii', ...
                        'homePath',             'U:\ISIM\PMOS_NX3008PBKW', ...
                        'cirFileName',          'ISIMcir_PMOS_NX3008PBKW.cir', ...
                        'rawFileName',          'ISIMcir_PMOS_NX3008PBKW.raw', ...
                        'variablesFile',        'variables_PMOS_NX3008PBKW.txt', ...
                        'LTSpicePath',          'C:\Program Files\LTC\LTspiceXVII', ...
                        'databasePath',         'database_PMOS_NX3008PBKW.mat');

simulationVariables = getSimulationVariables(pathsNconsts);
global app; app = ISIMapp;
% q = simulate(pathsNconsts,simulationVariables);
% u = plotIdVgs(5,[50:50:1700],"return",pathsNconsts,simulationVariables);
% p = plotIdVgsPMOS(5,[50:50:4000],"return",pathsNconsts,simulationVariables);
% doubleTuning("Vc",'Ib',5,1e-3,'direct','direct',pathsNconsts,simulationVariables)
% p = plothfeIc(5,[50:50:4000],"return",pathsNconsts,simulationVariables);
% x = sweepDAC0VgsPMOS([1 2 3],[200:200:4000],pathsNconsts,simulationVariables);
% r = sweepDAC0Vgs([2 3.5 4 4.5],[100:100:4000],pathsNconsts,simulationVariables);
% p = plotIdVds([1 2 3 4],[100:100:4000],pathsNconsts,simulationVariables);
% i = plotRdsonVgs(0.1,[100:100:4000],pathsNconsts,simulationVariables);
% l = plotRdsonVgsPMOS(0.1,[200:200:4000],pathsNconsts,simulationVariables);
% q = simulate(pathsNconsts,simulationVariables);
a = plotIdVdsPMOS([2 3 3.5 4],[100:100:4000],pathsNconsts,simulationVariables);
% if i('app') app.delete; end
% %%
% icset = 10.^[-4:0.2:-1];
% k = plotIcVce([1 2 4 8 16 32]*1e-4,[100:100:4000],pathsNconsts,simulationVariables);
% t = plothfeIc(5,icset,"return",pathsNconsts,simulationVariables);
% r = plotIcVcePNP([[-5]*1e-4 [-1 -2 -4]*1e-3],[100:100:4000],pathsNconsts,simulationVariables);
% y = plotVsatIc(10,[[1:9]*1e-3 [1:9]*1e-2 [1:4]*1e-1],pathsNconsts,simulationVariables);
% % % y = plotVsatIc(10,[[1:9]*1e-3 [1:9]*1e-2
% [1:4]*1e-1],pathsNconsts,simulationVariables);
% o = plothfeIcPNP(5,[25:25:4000],"return",pathsNconsts,simulationVariables);
% app.addPlot(r,"Ic - Vce","Ic - Vce");
% app.addPlot(t,"hfe - Ic","hfe - Ic");
% app.addPlot(y,"Vcesat - Ic","Vcesat - Ic");
% app.addPlot(y,"Vbesat - Ic","Vbesat - Ic");
% % pause(1000);
% % delete(app);
% r = {};
% 
% for j = 200:200:4000
%     setDAC1(j);
%     r{end + 1}= simulate(pathsNconsts,simulationVariables);
% end
% r = cell2mat(r);
% hfe needs to work dependently on Ic (not Ib)
saveDatabase(pathsNconsts)