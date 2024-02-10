function anglesArray = getAnglesFromConfiguration(configuration, interval)
% Function used to save as array the angles desidered from the chosen
% configuration.
    if nargin < 2
        interval = 1:size(configuration,2);
    end
    
    anglesArray = zeros(1,length(interval));
    cnt = 1;
    for i = 1:size(configuration,2)
        if i == interval(cnt)
            anglesArray(cnt) = configuration(i).JointPosition;
            cnt = cnt + 1;
            if cnt > length(interval)
                cnt = length(interval);
            end
        end
    end
end