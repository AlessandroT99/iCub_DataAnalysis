function [EA_i, EA_m, EA_f] = adaptive_analysis()
    d = dir("..\iCub_ProcessedData\AbsoluteRelativeVelocity\DifferenceDerivative\*.mat");
    n = length(d);
    
    removedMaterial = [13.3003802281369,42.3269961977186,78.0722433460076,17.0114068441065, ...
        15.9011406844106,7.36882129277567,11.2205323193916,11.0228136882129,16.361216730038, ...
        27.6920152091255,75.3992395437262,29,20.3905109489051,15.5583941605839,3.48540145985402, ...
        56.1532846715328,24.1423357664234,13.7518248175183,30.8430656934307,11.5,17.2810218978102, ...
        30.485401459854,18.4343065693431,29.9049429657795,43.2433460076046,32.5656934306569,100,27.3065693430657];
    
    v_h = [];
    a_h = [];
    v_r = [];
    a_r = [];
    v_h = cell(1,n);
    v_r = cell(1,n);
    a_h = cell(1,n);
    a_r = cell(1,n);
    EA_i = [];
    EA_m = [];
    EA_f = [];
    
    fig1A = figure('Name',"Adaptive dv"); hold on, grid on 
    ylim([0,3.5].*10e-2), xlim([0,4])
    xlabel("Time [min]"), title ("Adaptive dv")
    fig2A = figure('Name',"Adaptive ddv"); hold on, grid on
    ylim([0,1.5].*10e-1), xlim([0,4])
    xlabel("Time [min]"), title ("Adaptive ddv")
    
    for i = 1:n
        load(strjoin(["..\iCub_ProcessedData\AbsoluteRelativeVelocity\DifferenceDerivative\",d(i).name],""));
        v_h{i} = abs(RtoH_relativeVelocity(1:min(length(RtoH_relativeVelocity),length(HtoR_relativeVelocity))));
        v_r{i} = abs(HtoR_relativeVelocity(1:min(length(RtoH_relativeVelocity),length(HtoR_relativeVelocity))));
        a_h{i} = RtoH_relativeAcceleration;
        a_r{i} = HtoR_relativeAcceleration;
        
        meanTime = [];
        meanTime = (HtoR_time(1:length(v_h{i}))+RtoH_time(1:length(v_h{i})))./(100*2); %in sec
        dv = [];
        ddv = [];
        Time = meanTime(1);
        for j = 1:length(v_r{i})-1
            dv(j) = ((v_h{i}(j+1)-v_r{i}(j+1))-(v_h{i}(j)-v_r{i}(j)))/meanTime(j);
            if j > 1
                Time = [Time,Time(j-1)+meanTime(j)];
            end
        end
        for j = 1:length(dv)-1
            ddv(j) = (dv(j+1)-dv(j))/meanTime(j);
        end
        EA_i(i) = sum(ddv(1:round(end/8)).^2);
        EA_m(i) = sum(ddv(round(end/8):round(end*7/8)).^2);
        EA_f(i) = sum(ddv(round(end*7/8):end).^2);
        EA(i) = EA_i(i)+EA_m(i)+EA_f(i);
    
        figure(fig1A)
        plot(Time(1:length(dv))./60.*2,abs(dv))
    
        figure(fig2A)
        plot(Time(1:length(ddv))./60.*2,abs(ddv))
    end
    
    % EA'
end