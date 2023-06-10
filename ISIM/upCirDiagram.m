function upCirDiagram(result)
    arguments
        result     struct
    end
    global DAC0 DAC1 CRes BRes circuitDiagram;
    mustBeNonempty(DAC0);
    mustBeNonempty(DAC1);
    mustBeNonempty(CRes);
    mustBeNonempty(BRes);
    mustBeNonempty(circuitDiagram);
    
    updateVI();
    updateDAC(0); updateDAC(1);
    if (circuitDiagram.RBnum) ~= BRes 
        updateRes("B",BRes); 
        circuitDiagram.RBnum = BRes;
    end
    if (circuitDiagram.RCnum) ~= CRes 
        updateRes("C",CRes); 
        circuitDiagram.RCnum = CRes;
    end
    % checks if the direction of Ib has changed. If it has, it updates the
    % Ib arrow (swaps it's direction) and saves the new direction in the
    % IbArrowDirection property of circuitDiagram
    if (result.Ib*circuitDiagram.IbArrowDirection < 0) 
        temp = circuitDiagram.Ib.Position;
        circuitDiagram.Ib.Position = [(temp(1)+temp(3)) temp(2) -1*temp(3) temp(4)];
        circuitDiagram.IbArrowDirection = -1*circuitDiagram.IbArrowDirection;
    end
    drawnow limitrate;

    function updateVI
        for i = ["Vb" "Vc" "Ib" "Ic"]
            circuitDiagram.(strjoin([i "text"],'')).String = num2str(result.(i),5);
        end
    end

    function updateDAC(DACnum)
        mustBeMember(DACnum,[0 1]);
        if DACnum==1 DACvalue = DAC1; else DACvalue = DAC0; end;
        circuitDiagram.(strjoin(["DAC" num2str(DACnum)],'')).String = [strjoin([num2str(2*DACbinToVolt(DACvalue),5) "V"],'') DACvalue];
    end

    function updateRes(res,ResNum)
        mustBeMember(res,["C" "B"]);
        if res=='B' N = 1; else N=2; end;
        for i= 0:N
            resistor = strjoin(["R" res num2str(i) "branch"], '');
            if ResNum==i
                set(struct2array(circuitDiagram.(resistor)),'Color','g','LineWidth',2,'LineStyle','-');
                circuitDiagram.(resistor).(strjoin(["R" res num2str(i)], '')).EdgeColor = 'g';
            else
                set(struct2array(circuitDiagram.(resistor)),'Color','black','LineWidth',0.5,'LineStyle',':');
                circuitDiagram.(resistor).(strjoin(["R" res num2str(i)], '')).EdgeColor = 'b';
            end
        end
    end
end